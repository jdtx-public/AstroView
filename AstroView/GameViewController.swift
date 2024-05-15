//
//  GameViewController.swift
//  AstroView
//
//  Created by Jeff Doar on 2/8/22.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    static let scaleFactor: Double = 0.00001;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var physicsField = SCNPhysicsField.radialGravity()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/earth.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        let oneMillionMiles:CGFloat = 1000000.0
        let earthPos:CGFloat = 93 * oneMillionMiles
        
        cameraNode.position = SCNVector3(x: 0, y:0, z: GameViewController.toSceneCoords(inputValue: earthPos))
        
        // create and add a light to the scene
        /*
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: GameViewController.toSceneCoords(inputValue: earthPos), z: GameViewController.toSceneCoords(inputValue: earthPos))
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
         */
        
        // add nodes for sun and earth
        let mercuryNode = GameViewController.solarSystemBody(earthMassFraction: 0.055, earthRadiusFraction: 0.3829, zInitial: earthPos * 0.7282, color: NSColor.green)
        scene.rootNode.addChildNode(mercuryNode)

        let venusNode = GameViewController.solarSystemBody(earthMassFraction: 0.815, earthRadiusFraction: 0.9499, zInitial: earthPos * 0.466, color: NSColor.gray)
        scene.rootNode.addChildNode(venusNode)

        let earthNode = GameViewController.solarSystemBody(earthMassFraction: 1.0, earthRadiusFraction: 50.0, zInitial: earthPos, color: NSColor.blue)
        scene.rootNode.addChildNode(earthNode)

        let sunNode = GameViewController.solarSystemBody(earthMassFraction: 333000.0, earthRadiusFraction: 109.0, zInitial: 0.0, color: NSColor.yellow)
        scene.rootNode.addChildNode(sunNode)

        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.pointOfView = cameraNode
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    private class func solarSystemBody(earthMassFraction: Double, earthRadiusFraction: Double, zInitial: Double, color: NSColor) -> SCNNode {
        let earthRadius = 3950.0
        let nodeRadius = earthRadiusFraction * earthRadius
        
        let sphere = SCNSphere(radius: toSceneCoords(inputValue: nodeRadius))
        let node = SCNNode( geometry: sphere)
        node.geometry?.firstMaterial?.diffuse.contents = color;
        node.position = SCNVector3(x: 0, y: toSceneCoords(inputValue: zInitial), z: 0)
        return node
    }
    
    private class func toSceneCoords(inputValue: Double) -> Double {
        return inputValue * scaleFactor;
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
