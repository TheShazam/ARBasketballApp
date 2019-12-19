//
//  ViewController.swift
//  ARBasketballApp
//
//  Created by Hisham Alsamarrai on 12/17/19.
//  Copyright © 2019 Hisham Alsamarrai. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // IBOutlet is a reference to an element on the storyboard
    // Have access to the hidden properties and so on
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopButton: UIButton!
    
    var currentNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizer()
    }
    
    // Recognizes taps and movements on the screen
    func registerGestureRecognizer()
    {
        // If tap is recognized -- #selector requires us to make sure @obj function is available to expose the handleTap function to Objective-C
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // Takes in one arguement which is the gestureRecognizer referenced
        sceneView.addGestureRecognizer(tap)
    }
    
    // Finds the scene view, gets the center point, then has the basketball positioned in order for us to place it correctly when tapped
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        // Access scene view
        guard let sceneView = gestureRecognizer.view as? ARSCNView
        else
        {
            return
        }
        
        // Access the point of view of the scene view -- the center point of the scene view
        guard let centerPoint = sceneView.pointOfView
        else
        {
            return
        }
        
        // Transform matrix, contains the orientation and the location of the camera which determines the position of the camera in which we want the basketball to be placed
        let cameraTransform = centerPoint.transform
        // m - row and column
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        // minus operator(-) because its reversed
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        // Takes in 3 arguements(x, y, z) -- creates a new vector
        // x1 + x2, y1 + y2, z1 + z2
        // x1, y1, and z1 refers to the cameras location
        // x2, y2, and z2 refers to the cameras orientation
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        // Creates a ball with a radius of 0.15 and gives the material of our png file with lightning added
        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        // In order to create any object in virtual reality, that object must be a node and sets the position of the ball to cameraPosition
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        ballNode.physicsBody = physicsBody
        
        let forceVector:Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraPosition.x * forceVector, y: cameraPosition.y * forceVector, z: cameraPosition.z * forceVector), asImpulse: true)
        
        // Add the object to the scene using addChildNode, which our ballNode arguement is essentially the ball
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    // Displays the backboard for the app
    func addBackboard()
    {
        // SCNScene is a function that takes in one argument which is the locaiton of the scene to be loaded
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn")
        else
        {
            return
        }
        
        // childNode is a function that takes in two arguements - 1st is name of the element(backboard), 2nd is recursively which is false because the rim and RimHolder are child nodes of the backboard
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false)
        else
        {
            return
        }
        
        // Has x, y, and z arguments for our backboardNode
        backboardNode.position = SCNVector3(x: 0, y: 0.5, z: -3)
        
        // Add physics body for the backboardNode, options will detect all the details of the model(the hoop or ring)
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        // Static for type so the backboard doesnt move and call the physicsShape for shape
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody // Assigning backboardNode to have a physicsBody
        
        // Adding to the scene our backboardNode
        sceneView.scene.rootNode.addChildNode(backboardNode)
        currentNode = backboardNode
        
    }
    
    // The horizontal action -- moves left to right
    func horizontalAction(node: SCNNode)
    {
        // For the left action the node that it is applied to(the ball) will move left one meter every 3 seconds
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        // For the right action the node that it is applied to(the ball) will move right one meter every 3 seconds
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        
        // The sequence of actions for left and right actions
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }
    
    // The round action -- moves down and up and up and down
    func roundAction(node: SCNNode)
    {
        let upLeft = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0), duration: 2)
        
        // The action sequences
        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // Releases images that aren't being used
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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
    
    // IBAction is an action to be performed when the action has occurred
    
    // Adds a hoop to the screen
    @IBAction func addHoop(_ sender: Any)
    {
        addBackboard()  // Adds the backboard to the scene
        addHoopButton.isHidden = true   // The addHoopButton is hidden
        
    }
    
    // Calls our roundAction method when button is selected(<->)
    @IBAction func startRoundAction(_ sender: Any)
    {
        roundAction(node: currentNode)
    }
    
    // Ends all the actions when the stop button is selected
    @IBAction func stopAllActions(_ sender: Any)
    {
        currentNode.removeAllActions()
    }
    
    // Calls our horizontalAction method when button is selected(<~>)
    @IBAction func startHorizontalAction(_ sender: Any)
    {
        horizontalAction(node: currentNode)
    }
}
