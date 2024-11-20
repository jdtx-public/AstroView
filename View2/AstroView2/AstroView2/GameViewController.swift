//
//  GameViewController.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/16/24.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene and null out gravity
        let scene = SCNScene(named: "art.scnassets/EmptySpace.scn")!
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        // create all the solar system bodies
        GameViewController.addSolarBodies(targetNode: scene.rootNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 200)
        cameraNode.camera?.zFar = 30000;
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 300, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
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
    
    @IBAction func handleViewEarth(_ sender: Any) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 23464)
    }
    
    @IBAction func handleViewSun(_ sender: Any) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 200)
    }
    
    private class func addSolarBodies(targetNode: SCNNode) {
        targetNode.addChildNode(solarSystemBody(bodyName: "Sun", earthMassFraction: 333030, earthRadiusFraction: 109, zInitial: 0, textureName: "Solarsystemscope_texture_8k_sun"));
        targetNode.addChildNode(solarSystemBody(bodyName: "Earth", earthMassFraction: 1, earthRadiusFraction: 1, zInitial: 23454.8, textureName: "earth_texture"));
    }
    
    private class func solarSystemBody(bodyName: String, earthMassFraction: Double, earthRadiusFraction: Double, zInitial: Double, textureName: String) -> SCNNode {
        let sphere = SCNSphere(radius: earthRadiusFraction)
        let node = SCNNode( geometry: sphere)
        var textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        textureMaterial.diffuse.contents = myImage
        node.geometry?.materials = [textureMaterial]
        node.name = bodyName
        node.position = SCNVector3(x: 0, y: 0, z: zInitial)
        return node
    }
}
