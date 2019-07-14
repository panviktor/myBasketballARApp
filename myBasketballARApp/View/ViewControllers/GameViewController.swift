//
//  ViewController.swift
//  myBasketballARApp
//
//  Created by Виктор on 10/07/2019.
//  Copyright © 2019 SwiftViktor. All rights reserved.
//

import ARKit

class GameViewController: UIViewController  {
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var goalsLabel: UILabel!
    @IBOutlet var throwsLabel: UILabel!
    
    // MARK: - Properties
    var isBackboardPlaced = false {
        didSet {
            if isBackboardPlaced {
                guard let configuration = sceneView.session.configuration as? ARWorldTrackingConfiguration else { return }
                configuration.planeDetection = []
                sceneView.session.run(configuration)
            }
        }
    }
    
    private var goals = 0
    private var trows = 0
    
    private var contactTopHoop = false
    private var contactBottonHoop = false
    
    // MARK: - Overide UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        goalsLabel.text = "Goals: 0"
        throwsLabel.text = "Throws: 0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - IBAction Methods
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if isBackboardPlaced {
            addBall()
        } else {
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let nearestResult = hitTestResult.first {
                addBackboard(result: nearestResult)
                sceneView.scene.physicsWorld.contactDelegate = self
                isBackboardPlaced = true
            }
        }
    }
}

// MARK: - GameViewController Custom Method
extension GameViewController {
    private func createWall(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let wall = SCNNode()
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)
        let geometry = SCNPlane(width: width, height: height)
        let trackerImage = UIImage(named: "tracker")
        geometry.firstMaterial?.diffuse.contents = trackerImage
        wall.geometry = geometry
        wall.eulerAngles.x = -.pi / 2
        wall.name = "Wall"
        
        return wall
    }
    
    private func addBackboard(result: ARHitTestResult) {
        let backboardCSN = SCNScene(named: "art.scnassets/backboard.scn")
        
        guard let mainNode = backboardCSN?.rootNode.childNode(withName: "mainNode", recursively: false) else { return }
        mainNode.simdTransform = result.worldTransform
        mainNode.eulerAngles.x -= .pi / 2
        
        guard let backboard = mainNode.childNode(withName: "backboard", recursively: false) else { return }
        guard let topHoop = backboard.childNode(withName: "topHoop", recursively: false) else { return }
        guard let middleHoop = backboard.childNode(withName: "middleHoop", recursively: false) else { return }
        guard let bottonHoop = backboard.childNode(withName: "bottonHoop", recursively: false) else { return }
        guard let worldBox = mainNode.childNode(withName: "worldBox", recursively: false) else { return }
        
        let backboardShape = SCNPhysicsShape(node: backboard, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let backboardPhysicsBody = SCNPhysicsBody(type: .static, shape: backboardShape)
        backboard.physicsBody = backboardPhysicsBody
        backboard.physicsBody?.categoryBitMask = BitMaskCategory.backboard.rawValue
        backboard.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        backboard.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        
        let topHoopShape = SCNPhysicsShape(node: topHoop, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let topHoppePhysicsBody = SCNPhysicsBody(type: .static, shape: topHoopShape)
        topHoop.physicsBody = topHoppePhysicsBody
        topHoop.physicsBody?.categoryBitMask = BitMaskCategory.topHoop.rawValue
        topHoop.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        topHoop.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        topHoop.opacity = 0
        
        let middleHoopShape = SCNPhysicsShape(node: middleHoop, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let middleHoopPhysicsBody = SCNPhysicsBody(type: .static, shape: middleHoopShape)
        middleHoop.physicsBody = middleHoopPhysicsBody
        middleHoop.physicsBody?.categoryBitMask = BitMaskCategory.bottonHoop.rawValue
        middleHoop.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        middleHoop.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        
        let bottonHoopShape = SCNPhysicsShape(node: bottonHoop, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let bottonHoopPhysicsBody = SCNPhysicsBody(type: .static, shape: bottonHoopShape)
        bottonHoop.physicsBody = bottonHoopPhysicsBody
        bottonHoop.physicsBody?.categoryBitMask = BitMaskCategory.bottonHoop.rawValue
        bottonHoop.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        bottonHoop.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        bottonHoop.opacity = 0
        
        let worldBoxShape = SCNPhysicsShape(node: worldBox, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
        let worldBoxPhysicsBody = SCNPhysicsBody(type: .static, shape: worldBoxShape)
        worldBox.physicsBody = worldBoxPhysicsBody
        worldBox.physicsBody?.categoryBitMask = BitMaskCategory.worldBox.rawValue
        worldBox.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        worldBox.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        worldBox.opacity = 0
        
        sceneView.scene.rootNode.addChildNode(mainNode)
        hideWall()
    }
    
    private func contactHoopReset() {
        contactTopHoop = false
        contactBottonHoop = false
    }
    
    private func addBall() {
        guard let frame = sceneView.session.currentFrame else { return }
        
        let ball = SCNNode(geometry: SCNSphere(radius: 0.24))
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(
            node: ball,
            options: [SCNPhysicsShape.Option.collisionMargin: 0.005]
        ))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/ball.jpg")
        
        let transform = SCNMatrix4(frame.camera.transform)
        ball.transform = transform
        ball.name = "ball"
        
        let power: Float = 10
        let force = SCNVector3(-transform.m31 * power, -transform.m32 * power, -transform.m33 * power)
        
        ball.physicsBody?.applyForce(force, asImpulse: true)
        ball.physicsBody?.categoryBitMask = BitMaskCategory.boll.rawValue
        ball.physicsBody?.collisionBitMask = BitMaskCategory.backboard.rawValue
        ball.physicsBody?.contactTestBitMask = BitMaskCategory.backboard.rawValue
        
        contactHoopReset()
    
        sceneView.scene.rootNode.addChildNode(ball)
        trows += 1
        throwsLabel.text = "Throws: " + String(trows)
    }
    
    private func hideWall() {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "Wall" {
                node.removeFromParentNode()
            }
        }
    }
    
}

// MARK: - ARSCNViewDelegate

extension GameViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let wall = createWall(planeAnchor: planeAnchor)
        node.addChildNode(wall)
    }
}


// MARK: - SCNPhysicsContactDelegate

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskCategory.boll.rawValue && contact.nodeB.physicsBody?.categoryBitMask == BitMaskCategory.topHoop.rawValue && !contactTopHoop {
            contactTopHoop = true
            contactBottonHoop = false
        }
        
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskCategory.boll.rawValue && contact.nodeB.physicsBody?.categoryBitMask == BitMaskCategory.worldBox.rawValue {
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contactTopHoop && !contactBottonHoop {
//  true false????????????       if  contact.nodeA.physicsBody?.categoryBitMask == BitMaskCategory.boll.rawValue && contact.nodeB.physicsBody?.categoryBitMask == BitMaskCategory.bottonHoop.rawValue {
           if contact.nodeA.physicsBody?.categoryBitMask == BitMaskCategory.boll.rawValue && contact.nodeB.name == "bottonHoop" {
              print(#line,  contact.nodeB.physicsBody?.categoryBitMask == BitMaskCategory.bottonHoop.rawValue, contact.nodeB.name == "bottonHoop")
                contactBottonHoop = true
                goals += 1
                contactHoopReset()
                DispatchQueue.main.async {
                    self.goalsLabel.text = "Goals: \(self.goals)"
                }
            }
        }
    }
}
