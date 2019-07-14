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
    
    // MARK: - Overide UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
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
        let backboard = SCNScene(named: "art.scnassets/backboard.scn")!.rootNode.clone()
        backboard.simdTransform = result.worldTransform
        backboard.eulerAngles.x -= .pi / 2
        sceneView.scene.rootNode.addChildNode(backboard)
        let shape = SCNPhysicsShape(node: backboard, options: [
            SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron
        ])
        let body = SCNPhysicsBody(type: .static, shape: shape)
        backboard.physicsBody = body
        backboard.physicsBody?.categoryBitMask = BitMaskCategory.backboard.rawValue
        backboard.physicsBody?.collisionBitMask = BitMaskCategory.boll.rawValue
        backboard.physicsBody?.contactTestBitMask = BitMaskCategory.boll.rawValue
        
        
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "Wall" {
                node.removeFromParentNode()
            }
        }
    }
    
    private func addBall() {
        guard let frame = sceneView.session.currentFrame else { return }
        let ball = SCNNode(geometry: SCNSphere(radius: 0.24))
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(
            node: ball,
            options: [SCNPhysicsShape.Option.collisionMargin: 0.01] //TRY 0.0001
        ))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/ball.jpg")
        
        let transform = SCNMatrix4(frame.camera.transform)
        ball.transform = transform
        
        let power: Float = 10
        let force = SCNVector3(-transform.m31 * power, -transform.m32 * power, -transform.m33 * power)
        ball.physicsBody?.applyForce(force, asImpulse: true)
        ball.physicsBody?.categoryBitMask = BitMaskCategory.boll.rawValue
        ball.physicsBody?.collisionBitMask = BitMaskCategory.backboard.rawValue
        ball.physicsBody?.contactTestBitMask = BitMaskCategory.backboard.rawValue
        
        sceneView.scene.rootNode.addChildNode(ball)
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
        let nodeA = contact.nodeA //backboard
//        let nodeB = contact.nodeB //boll
        
        if nodeA.physicsBody?.contactTestBitMask == BitMaskCategory.backboard.rawValue {
            print(#function, #line)
            
        }
    }
    
}
