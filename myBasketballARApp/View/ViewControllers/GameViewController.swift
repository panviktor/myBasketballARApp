//
//  ViewController.swift
//  myBasketballARApp
//
//  Created by Виктор on 10/07/2019.
//  Copyright © 2019 SwiftViktor. All rights reserved.
//

import ARKit

class GameViewController: UIViewController  {
    
    @IBOutlet var sceneView: ARSCNView!
    
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
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if let nearestResult = hitTestResult.first {
            addBackboard(result: nearestResult)
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
