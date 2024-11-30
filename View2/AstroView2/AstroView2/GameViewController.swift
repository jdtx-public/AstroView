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
        
        /*
        moveNode(scene: scene, nodeName: "Sun", forDate: date, moveFunc: PlanetSim.sunPos)
        moveNode(scene: scene, nodeName: "Mercury", forDate: date, moveFunc: PlanetSim.mercuryPos)
        moveNode(scene: scene, nodeName: "Venus", forDate: date, moveFunc: PlanetSim.venusPos)
        moveNode(scene: scene, nodeName: "Earth", forDate: date, moveFunc: PlanetSim.earthPos)
        moveNode(scene: scene, nodeName: "Moon", forDate: date, moveFunc: PlanetSim.moonPos)
        moveNode(scene: scene, nodeName: "Mars", forDate: date, moveFunc: PlanetSim.marsPos)
        */
    }
    
    func moveNode(scene: SCNScene, nodeName: String, forDate: Date, moveFunc: (Date) -> SCNVector3) {
        let bodyNode = scene.rootNode.childNode(withName: nodeName, recursively: true)!
        let position = moveFunc(forDate)
        bodyNode.position = position.scaleBy(GameViewController.oneAu)
    }
}

class GameViewController: NSViewController {
    
    public static let earthRadius: Double = 1.0
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
        cameraNode.camera?.zFar = 5 * GameViewController.oneAu
        
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
        ambientLightNode.light!.color = NSColor.white
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        scnView.delegate = rendererDelegate
        
        // set the scene to the view
        scnView.scene = scene
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        //
        scnView.allowsCameraControl = true
        scnView.pointOfView = cameraNode
        
        // Add a click gesture recognizer
        /*
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
         */
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
    
    @IBAction func handleViewMercury(_ sender: Any) {
        viewByName(bodyName: "Mercury")
    }
    
    @IBAction func handleViewVenus(_ sender: Any) {
        viewByName(bodyName: "Venus")
    }
    
    @IBAction func handleViewEarth(_ sender: Any) {
        viewByName(bodyName: "Earth")
    }
    
    @IBAction func handleViewMars(_ sender: Any) {
        viewByName(bodyName: "Mars")
    }
    
    @IBAction func handleViewSun(_ sender: Any) {
        // the sun is obviously at distance 0 from the center
        // of the system, so viewByName won't work
        
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let bodyNode = scene.rootNode.childNode(withName: "Sun", recursively: true)!
        let bodyBounds = bodyNode.geometry!.boundingBox
        
        // we'll view from .05 AU away
        let bodyMax = bodyBounds.max
        let bodyMaxLen = bodyMax.length()
        let factor = 0.05 * GameViewController.oneAu / bodyMaxLen
        let newPos = bodyMax.scaleBy(factor)
        
        viewSolarBody(bodyNode: bodyNode, fromCameraPos: newPos)
    }
    
    private func viewByName(bodyName: String) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let bodyNode = scene.rootNode.childNode(withName: bodyName, recursively: true)!

        let bodyPos = bodyNode.worldPosition
        
        // scale the length by an amount
        let cameraPos = bodyPos.scaleBy(1.03)

        viewSolarBody(bodyNode: bodyNode, fromCameraPos: cameraPos)
    }
    
    private func viewSolarBody(bodyNode: SCNNode, fromCameraPos: SCNVector3) {
        let scnView = self.view as! SCNView
        let cameraPos = fromCameraPos
        
        let cameraNode = scnView.pointOfView!
        let camera = cameraNode.camera!
        camera.zNear = 0.01 * GameViewController.oneAu
        camera.zFar = 1.5 * GameViewController.oneAu

        print("targetNode pos = \(bodyNode.position) \(bodyNode.position.length() / GameViewController.oneAu)")
        print("cameraNode oldPos = \(cameraNode.position) \(cameraPos.length() / GameViewController.oneAu)")
        print("cameraNode newPos = \(cameraPos) len = \(cameraPos.length() / GameViewController.oneAu)")
        print("camera z =\(cameraNode.camera?.zNear) \(cameraNode.camera?.zFar)")

        cameraNode.position = cameraPos
        cameraNode.look(at: SCNVector3(0, 0, 0))

        cameraNode.constraints = [SCNLookAtConstraint(target: bodyNode)]

        let mightBeVisible = scnView.isNode(bodyNode, insideFrustumOf: cameraNode)
        print("target node might be visible: \(mightBeVisible)")

        let povNode = scnView.pointOfView!
        let bodyBounds = bodyNode.geometry!.boundingBox
        print("povPos = \(povNode.position); bounds = \(bodyBounds)")
    }
    
    private class func addSolarBodies(targetNode: SCNNode) {
        let solarSystemNode = SCNNode();
        targetNode.addChildNode(solarSystemNode)
        
        let sunNode = solarSystemBody(bodyName: "Sun",
                                      earthRadiusFraction: 109,
                                      textureName: "Solarsystemscope_texture_8k_sun",
                                      computePosition: PlanetSim.sunPos)
        solarSystemNode.addChildNode(sunNode)

        let mercuryNode = solarSystemBody(bodyName: "Mercury",
                                          earthRadiusFraction: 0.3829,
                                          textureName: "Solarsystemscope_texture_8k_mercury",
                                          computePosition: PlanetSim.mercuryPos)
        solarSystemNode.addChildNode(mercuryNode)

        let venusNode = solarSystemBody(bodyName: "Venus",
                                        earthRadiusFraction: 0.9499,
                                          textureName: "2k_venus_surface",
                                        computePosition: PlanetSim.venusPos)
        solarSystemNode.addChildNode(venusNode)

        let earthNode = solarSystemBody(bodyName: "Earth",
                                        earthRadiusFraction: 1,
                                        textureName: "Solarsystemscope_texture_8k_earth_daymap",
                                        computePosition: PlanetSim.earthPos)
        solarSystemNode.addChildNode(earthNode)
        
        let moonNode = solarSystemBody(bodyName: "Moon",
                                       earthRadiusFraction: 0.2725,
                                        textureName: "8k_moon",
                                        computePosition: PlanetSim.moonPos)
        solarSystemNode.addChildNode(moonNode)
        
        let marsNode = solarSystemBody(bodyName: "Mars",
                                       earthRadiusFraction: 0.533,
                                        textureName: "2k_mars",
                                       computePosition: PlanetSim.marsPos)
        solarSystemNode.addChildNode(marsNode)
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
        let nodePos = computePosition(Date.now)
        let fullPos = nodePos.scaleBy(GameViewController.oneAu)
        textureMaterial.diffuse.contents = myImage
        node.geometry?.materials = [textureMaterial]
        node.name = bodyName
        node.worldPosition = fullPos
        // node.addAnimation(axialRotationAnimation(), forKey: "rotation about axis")

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
            // let oldPos = node.position.scaleBy(1 / oneAu)
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
