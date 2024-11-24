//
//  GameViewController.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/16/24.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    private static let earthRadius: Double = 6378137
    private static let earthMass: Double = 5.97219e24
    
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 109 * 1.3 * GameViewController.earthRadius)
        cameraNode.camera?.zFar = 109 * 3 * GameViewController.earthRadius
        
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
        viewByName(bodyName: "Earth")
    }
    
    @IBAction func handleViewSun(_ sender: Any) {
        viewByName(bodyName: "Sun")
    }
    
    private func viewByName(bodyName: String) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let bodyNode = scene.rootNode.childNode(withName: bodyName, recursively: true)!
        let bodyZ = bodyNode.position.z
        let bodyBounds = bodyNode.geometry!.boundingBox
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        cameraNode.position = SCNVector3(x: 0, y: 0, z: bodyZ + bodyBounds.max.z + 1000)
    }
    
    private class func addSolarBodies(targetNode: SCNNode) {
        let earthRadiusOrbit = 23454.8
        targetNode.addChildNode(solarSystemBody(bodyName: "Sun", earthMassFraction: 333030, earthRadiusFraction: 109, earthRadiusOrbit: 0, textureName: "Solarsystemscope_texture_8k_sun"));
        
        let earthNode = solarSystemBody(bodyName: "Earth", earthMassFraction: 1, earthRadiusFraction: 1, earthRadiusOrbit: earthRadiusOrbit, textureName: "earth_texture")
        targetNode.addChildNode(earthNode);
        
        let earthPos = PlanetSim.earthPos(d: Date.now)

        let fullDistance = earthRadiusOrbit * GameViewController.earthRadius

        earthNode.position = SCNVector3(earthPos.x * fullDistance, earthPos.y * fullDistance, earthPos.z * fullDistance)
    }
    
    private class func solarSystemBody(bodyName: String, earthMassFraction: Double, earthRadiusFraction: Double,
                                       earthRadiusOrbit: Double, textureName: String) -> SCNNode {
        let fullRadius = earthRadiusFraction * GameViewController.earthRadius
        let fullDistance = earthRadiusOrbit * GameViewController.earthRadius
        let fullMass = earthMassFraction * GameViewController.earthMass
        
        let sphere = SCNSphere(radius: fullRadius)
        let node = SCNNode( geometry: sphere)
        var textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        textureMaterial.diffuse.contents = myImage
        node.geometry?.materials = [textureMaterial]
        node.name = bodyName
        node.position = SCNVector3(x: 0, y: 0, z: fullDistance)
        return node
    }
}
