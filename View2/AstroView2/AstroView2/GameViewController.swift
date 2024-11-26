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
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!

        let bodyPos = bodyNode.position
        let bodyBounds = bodyNode.geometry!.boundingBox
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: bodyPos.z + bodyBounds.max.z + 1000)

        let lookAtConstraint = SCNLookAtConstraint(target: bodyNode)
        cameraNode.constraints = [lookAtConstraint]

        /*
        let bodyZ = bodyNode.position.z
        let bodyBounds = bodyNode.geometry!.boundingBox
        cameraNode.position = SCNVector3(x: 0, y: 0, z: bodyZ + bodyBounds.max.z + 1000)
        */
        /*
        */
    }
    
    private class func addSolarBodies(targetNode: SCNNode) {
        let sunNode = solarSystemBody(bodyName: "Sun", earthMassFraction: 333030,
                                      earthRadiusFraction: 109, earthRadiusOrbit: 0,
                                      textureName: "Solarsystemscope_texture_8k_sun",
                                      computePosition: { d in return SCNVector3(x: 0, y: 0, z: 0) })
        targetNode.addChildNode(sunNode)

        let mercuryNode = solarSystemBody(bodyName: "Mercury", earthMassFraction: 0.055,
                                          earthRadiusFraction: 0.3829, earthRadiusOrbit: 0.38,
                                          textureName: "Solarsystemscope_texture_8k_mercury",
                                          computePosition: PlanetSim.mercuryPos)
        targetNode.addChildNode(mercuryNode)

        let venusNode = solarSystemBody(bodyName: "Venus", earthMassFraction: 0.815,
                                        earthRadiusFraction: 0.9499, earthRadiusOrbit: 0.72332,
                                          textureName: "2k_venus_surface",
                                        computePosition: PlanetSim.venusPos)
        targetNode.addChildNode(venusNode)

        let earthNode = solarSystemBody(bodyName: "Earth", earthMassFraction: 1,
                                        earthRadiusFraction: 1, earthRadiusOrbit: 1,
                                        textureName: "Solarsystemscope_texture_8k_earth_daymap",
                                        computePosition: PlanetSim.earthPos)
        targetNode.addChildNode(earthNode)
        
        let marsNode = solarSystemBody(bodyName: "Mars", earthMassFraction: 0.107,
                                       earthRadiusFraction: 0.533, earthRadiusOrbit: 1.523,
                                        textureName: "2k_mars",
                                       computePosition: PlanetSim.marsPos)
        targetNode.addChildNode(marsNode)
    }

    private class func solarSystemBody(bodyName: String, earthMassFraction: Double, earthRadiusFraction: Double,
                                       earthRadiusOrbit: Double, textureName: String,
                                       computePosition: @escaping (Date) -> SCNVector3) -> SCNNode {
        let oneAuInEarthRadii = 23454.8
        
        let fullRadius = earthRadiusFraction * GameViewController.earthRadius
        let fullDistance = earthRadiusOrbit * oneAuInEarthRadii * GameViewController.earthRadius
        
        let sphere = SCNSphere(radius: fullRadius)
        let node = SCNNode( geometry: sphere)
        let textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        textureMaterial.diffuse.contents = myImage
        node.geometry?.materials = [textureMaterial]
        node.name = bodyName
        node.position = SCNVector3(x: 0, y: 0, z: fullDistance)
        node.addAnimation(axialRotationAnimation(), forKey: "rotation about axis")
        node.runAction(moveBody(computePosition: computePosition))
        return node
    }

    private class func solarSystemBody_old(bodyName: String, earthMassFraction: Double, earthRadiusFraction: Double,
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
    
    private class func axialRotationAnimation() -> CAAnimation {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(scnVector4: SCNVector4(0.0, 1.0, 0.0, 0.0))
        spin.toValue = NSValue(scnVector4: SCNVector4(0.0, 1.0, 0.0, 2.0 * Float.pi))
        spin.duration = 10.0
        spin.repeatCount = .infinity
        
        return spin
    }
    
    private class func moveBody(computePosition: @escaping (Date) -> SCNVector3) -> SCNAction {
        let earthRadiusOrbit = 23454.8
        let fullDistance = earthRadiusOrbit * GameViewController.earthRadius

        let moveTo = SCNAction.customAction(duration: 1000.0) { node, elapsedTime in
            let fakeTime = Date.now.addingTimeInterval((elapsedTime * 360.0))
            let earthPos = computePosition(fakeTime)
            node.position = SCNVector3(earthPos.x * fullDistance, earthPos.y * fullDistance, earthPos.z * fullDistance)
        }
        
        return moveTo
    }
}
