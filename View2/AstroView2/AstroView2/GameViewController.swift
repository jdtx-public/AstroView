//
//  GameViewController.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/16/24.
//

import SceneKit
import QuartzCore

class SceneRendererDelegate: NSObject, SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let scene = renderer.scene!
        let date = Date.now
        
        moveNode(scene: scene, nodeName: "Sun", forDate: date, moveFunc: PlanetSim.sunPos)
        moveNode(scene: scene, nodeName: "Mercury", forDate: date, moveFunc: PlanetSim.mercuryPos)
        moveNode(scene: scene, nodeName: "Venus", forDate: date, moveFunc: PlanetSim.venusPos)
        moveNode(scene: scene, nodeName: "Earth", forDate: date, moveFunc: PlanetSim.earthPos)
        moveNode(scene: scene, nodeName: "Moon", forDate: date, moveFunc: PlanetSim.moonPos)
        moveNode(scene: scene, nodeName: "Mars", forDate: date, moveFunc: PlanetSim.marsPos)
    }
    
    func moveNode(scene: SCNScene, nodeName: String, forDate: Date, moveFunc: (Date) -> SCNVector3) {
        let bodyNode = scene.rootNode.childNode(withName: nodeName, recursively: true)!
        let position = moveFunc(forDate)
        bodyNode.position = position.scaleBy(GameViewController.oneAu)
    }
}

class GameViewController: NSViewController {
    
    public static let earthRadius: Double = 6378137
    public static let earthMass: Double = 5.97219e24
    public static let oneAuInEarthRadii = 23454.8
    public static let oneAu: Double = oneAuInEarthRadii * earthRadius
    
    private let rendererDelegate = SceneRendererDelegate()
    
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
        
        scnView.delegate = rendererDelegate
        
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
        // the sun is obviously at distance 0 from the center
        // of the system, so viewByName won't work
        
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let bodyNode = scene.rootNode.childNode(withName: "Sun", recursively: true)!
        let bodyBounds = bodyNode.geometry!.boundingBox
        
        let cameraPos = bodyBounds.max.scaleBy(1.20)

        viewFrom(cameraPos: cameraPos)

        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        cameraNode.constraints = [SCNLookAtConstraint(target: bodyNode)]
    }
    
    private func viewByName(bodyName: String) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let bodyNode = scene.rootNode.childNode(withName: bodyName, recursively: true)!

        let bodyPos = bodyNode.position
        
        // scale the length by an amount
        let cameraPos = bodyPos.scaleBy(1.05)
        
        viewFrom(cameraPos: cameraPos)
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        // cameraNode.constraints = [SCNLookAtConstraint(target: bodyNode)]
    }
    
    private func viewFrom(cameraPos: SCNVector3) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        print("cameraNode oldPos = \(cameraNode.position)")
        print("cameraNode newPos = \(cameraPos)")
        cameraNode.position = cameraPos
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
    }
    
    private class func addSolarBodies(targetNode: SCNNode) {
        let sunNode = solarSystemBody(bodyName: "Sun",
                                      earthRadiusFraction: 109,
                                      textureName: "Solarsystemscope_texture_8k_sun",
                                      computePosition: PlanetSim.sunPos)
        targetNode.addChildNode(sunNode)

        let mercuryNode = solarSystemBody(bodyName: "Mercury",
                                          earthRadiusFraction: 0.3829,
                                          textureName: "Solarsystemscope_texture_8k_mercury",
                                          computePosition: PlanetSim.mercuryPos)
        targetNode.addChildNode(mercuryNode)

        let venusNode = solarSystemBody(bodyName: "Venus",
                                        earthRadiusFraction: 0.9499,
                                          textureName: "2k_venus_surface",
                                        computePosition: PlanetSim.venusPos)
        targetNode.addChildNode(venusNode)

        let earthNode = solarSystemBody(bodyName: "Earth",
                                        earthRadiusFraction: 1,
                                        textureName: "Solarsystemscope_texture_8k_earth_daymap",
                                        computePosition: PlanetSim.earthPos)
        targetNode.addChildNode(earthNode)
        
        let moonNode = solarSystemBody(bodyName: "Moon",
                                       earthRadiusFraction: 0.2725,
                                        textureName: "8k_moon",
                                        computePosition: PlanetSim.moonPos)
        targetNode.addChildNode(moonNode)
        
        let marsNode = solarSystemBody(bodyName: "Mars",
                                       earthRadiusFraction: 0.533,
                                        textureName: "2k_mars",
                                       computePosition: PlanetSim.marsPos)
        targetNode.addChildNode(marsNode)
    }

    private class func solarSystemBody(bodyName: String, earthRadiusFraction: Double,
                                       textureName: String,
                                       computePosition: @escaping (Date) -> SCNVector3) -> SCNNode {
        let fullRadius = earthRadiusFraction * GameViewController.earthRadius
        
        let sphere = SCNSphere(radius: fullRadius)
        let node = SCNNode( geometry: sphere)
        let textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        textureMaterial.diffuse.contents = myImage
        node.geometry?.materials = [textureMaterial]
        node.name = bodyName
        node.position = computePosition(Date.now)
        node.addAnimation(axialRotationAnimation(), forKey: "rotation about axis")

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
        let moveTo = SCNAction.customAction(duration: 1000.0) { node, elapsedTime in
            let oldPos = node.position.scaleBy(1 / oneAu)
            // print("\(node.name): \(oldPos)")

            let fakeTime = Date.now.addingTimeInterval((elapsedTime * 360.0))
            let planetPos = computePosition(fakeTime)
            
            let fullPos = planetPos.scaleBy(oneAu)
            // print("\(node.name): \(planetPos)")
            
            node.position = fullPos
        }
        
        return moveTo
    }
}
