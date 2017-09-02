//
//  ViewController.swift
//  scenekit test
//
//  Created by Harry Merzin on 9/1/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // And the floor
        let floor = SCNBox(width: 1, height: 0.09, length: 1, chamferRadius: 0.3)
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -2
        translation.columns.3.y = -0.3
        floorNode.simdTransform = matrix_multiply(matrix_identity_float4x4, translation)
        floor.firstMaterial?.diffuse.contents = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
        floorNode.physicsBody?.type = .kinematic
        // Make a cube to sit on the "floor"
        let cubeGeo = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        var cubetranslation = matrix_identity_float4x4
        cubetranslation.columns.3.y = 1
        cubetranslation.columns.3.z = -2
        
        
        //let verybottom = SCNBox(width: 1000, height: 0.09, length: 1000, chamferRadius: 0)
        //verybottom.firstMaterial?.diffuse.contents = UIColor.init(red: 1, green: 0, blue: 1, alpha: 0.5)
        //var btranslation = matrix_identity_float4x4
        //btranslation.columns.3.y = -3
        //let bnode = SCNNode(geometry: verybottom)
        //bnode.simdTransform = matrix_multiply(matrix_identity_float4x4, btranslation)
        //bnode.physicsBody?.type = .kinematic
        //scene.rootNode.addChildNode(bnode)
        
        
        let cubeNode = SCNNode(geometry: cubeGeo)
        cubeNode.simdTransform = matrix_multiply(matrix_identity_float4x4, cubetranslation)
        let cubebody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cubeGeo, options: nil))
        cubebody.collisionBitMask = 0b0001
        cubeNode.physicsBody = cubebody
    

        let floorbody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: floor, options: nil))
        floorbody.categoryBitMask = 0b0001
        floorNode.physicsBody = floorbody
        
        //physicsBody.restitution = 0.25
        //physicsBody.friction = 0.75
        //physicsBody.categoryBitMask = CollisionTypes.shape.rawValue
        
        //scene.rootNode.addChildNode(makeFloor())

        scene.rootNode.addChildNode(cubeNode)
        
        // Set the scene to the view
        //sceneView.scene.physicsWorld.gravity = SCNVector3(0.0,-9.8,0.0)
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeFloor()
        blocksOnFloor()
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //configuration.worldAlignment = .gravity
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let camerapos = sceneView.scene
        let newSphere = SCNSphere(radius: 0.1)
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        var sphereNode = SCNNode(geometry: newSphere)
        var newBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: newSphere, options: nil))
        newBody.collisionBitMask = 0b0001
        sphereNode.physicsBody = newBody
        newSphere.firstMaterial?.diffuse.contents = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.5
        //\translation.columns.3.x = -1
        //translation.columns.3.y = 1
        sphereNode.simdTransform = matrix_multiply(cameraTransform!, translation)
        let angles = sceneView.session.currentFrame?.camera.eulerAngles
        let mat = SCNMatrix4(cameraTransform!) // 4x4 transform matrix describing camera in world space
        // orientation of camera in world space, transform for in front of camera
        let dir = SCNVector3(-10 * mat.m31, -10 * mat.m32, -10 * mat.m33)
        /*
         * direction vector help from repo: https://github.com/farice/ARShooter/blob/master/ARViewer/ViewController.swift
         * Apple seriously needs better docs for that
         */

        sphereNode.physicsBody?.applyForce(dir, asImpulse: true)
    }
    
    func scale(_ vector: SCNVector3, by float: Float) -> SCNVector3 {
        var newVector = SCNVector3()
        newVector.x *= float
        newVector.y *= float
        newVector.z *= float
        return newVector
    }
    
    func blocksOnFloor() {
        for i in 1...15 {
            let cubeGeo = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            var cubetranslation = matrix_identity_float4x4
            cubetranslation.columns.3.y = -1
            cubetranslation.columns.3.z = -2
            let cubeNode = SCNNode(geometry: cubeGeo)
            cubeNode.simdTransform = matrix_multiply(matrix_identity_float4x4, cubetranslation)
            let cubebody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cubeGeo, options: nil))
            cubebody.collisionBitMask = 0b0001
            cubeNode.physicsBody = cubebody
            self.sceneView.scene.rootNode.addChildNode(cubeNode)
        }
    }
    
    func makeFloor() -> SCNNode {
        let floorgeo = SCNBox(width: 10, height: 0.05, length: 10, chamferRadius: 0)
        floorgeo.firstMaterial?.diffuse.contents = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.0)
        let floornode = SCNNode(geometry: floorgeo)
        sceneView.scene.rootNode.addChildNode(floornode)
        let floorPhys = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: floorgeo, options: nil))
        floorPhys.categoryBitMask = 0b0001
        floornode.physicsBody = floorPhys
        var ftransformation = matrix_identity_float4x4
        ftransformation.columns.3.y = -2
        ftransformation.columns.3.z = -2
        floornode.simdTransform = matrix_multiply(matrix_identity_float4x4, ftransformation)
        return floornode
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
