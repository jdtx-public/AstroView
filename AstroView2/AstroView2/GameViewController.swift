//
//  GameViewController.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/16/24.
//

import SceneKit
import QuartzCore
import SCNMathExtensions
import novas_swift
import simd

class GameViewController: NSViewController {
    
    
    private let _systemModel : SystemModel
    private var _geometry: SpaceGeometry
    private let _rendererDelegate: SceneRendererDelegate

    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        _systemModel = SpiceSystemModel()
        _geometry = SystemModelGeometry(withModel: _systemModel)
        _rendererDelegate = SceneRendererDelegate(systemModel: _systemModel)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        _systemModel = SpiceSystemModel()
        _geometry = SystemModelGeometry(withModel: _systemModel)
        _rendererDelegate = SceneRendererDelegate(systemModel: _systemModel)

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene and null out gravity
        let scene = SCNScene(named: "art.scnassets/EmptySpace.scn")!
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        // create all the solar system bodies
        do {
            scene.rootNode.addChildNode(try _geometry.createGeometry())
        } catch {
            // eat the error and bail
            return
        }
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0.4 * AstroConstants.oneAu)
        cameraNode.camera?.zFar = 60 * AstroConstants.oneAu
        
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
        
        scnView.delegate = _rendererDelegate
        
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
    
    @IBAction func handleViewJupiter(_ sender: Any) {
        viewByName(bodyName: "Jupiter")
    }
    
    @IBAction func handleViewSaturn(_ sender: Any) {
        viewByName(bodyName: "Saturn")
    }
    
    @IBAction func handleViewUranus(_ sender: Any) {
        viewByName(bodyName: "Uranus")
    }
    
    @IBAction func handleViewNeptune(_ sender: Any) {
        viewByName(bodyName: "Neptune")
    }
    
    @IBAction func handleViewSun(_ sender: Any) {
        // the sun is obviously at distance 0 from the center
        // of the system, so viewByName won't work
        
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        let sunNode = scene.rootNode.childNode(withName: "Sun", recursively: true)!
        let bodyNode = sunNode.childNode(withName: "solarBody", recursively: true)!
        let bodyBounds = bodyNode.geometry!.boundingBox
        
        // we'll view from .02 AU away
        let bodyMax = bodyBounds.max
        let extensionLen = 0.01 * AstroConstants.oneAu
        let newPos = bodyMax.extendBy(by: extensionLen) + sunNode.worldPosition
        
        viewSolarBody(bodyNode: sunNode, fromCameraPos: newPos)
    }
    
    private func viewByName(bodyName: String) {
        let scnView = self.view as! SCNView
        let scene = scnView.scene!
        
        // let bodyNode = scene.rootNode.childNode(withName: bodyName, recursively: true)!.childNode(withName: "solarBody", recursively: true)!
        let bodyNode = scene.rootNode.childNode(withName: bodyName, recursively: true)!
        
        let bodyPos = bodyNode.worldPosition
        
        // view from .01 AU away
        let extensionLen = 0.01 * AstroConstants.oneAu
        let cameraPos = bodyPos.extendBy(by: extensionLen)

        viewSolarBody(bodyNode: bodyNode, fromCameraPos: cameraPos)
    }
    
    private func viewSolarBody(bodyNode: SCNNode, fromCameraPos: SCNVector3) {
        let scnView = self.view as! SCNView
        let cameraPos = fromCameraPos
        
        let cameraNode = scnView.pointOfView!
        let camera = cameraNode.camera!
        camera.zNear = 0.005 * AstroConstants.oneAu
        camera.zFar = 60 * AstroConstants.oneAu
        
        let oldPos = cameraNode.position
        let geometryNode = bodyNode.childNode(withName: "solarBody", recursively: true)!
        let bodyBounds = geometryNode.geometry!.boundingBox

        print("targetNode pos = \(bodyNode.position) \(bodyNode.position.length() / AstroConstants.oneAu)")
        print("cameraNode oldPos = \(oldPos) \(oldPos.length() / AstroConstants.oneAu)")
        print("cameraNode newPos = \(cameraPos) len = \(cameraPos.length() / AstroConstants.oneAu)")
        print("camera z =\(cameraNode.camera?.zNear) \(cameraNode.camera?.zFar)")
        print("geometry bounds = \(bodyBounds)")
        let parentBounds = bodyNode.boundingBox
        print("parent bounds = \(parentBounds)")

        cameraNode.position = cameraPos
        cameraNode.look(at: cameraPos.scaleBy(-1.0))
        print("cameraNode up = \(cameraNode.worldUp)")

        // cameraNode.constraints = [SCNLookAtConstraint(target: bodyNode)]

        let mightBeVisible = scnView.isNode(bodyNode, insideFrustumOf: cameraNode)
        print("target node might be visible: \(mightBeVisible)")
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

            let fakeTime = Date.now.addingTimeInterval((elapsedTime * 50.0))
            let planetPos = computePosition(fakeTime)
            
            let fullPos = planetPos.scaleBy(AstroConstants.oneAu)
            // print("\(node.name): \(planetPos)")
            
            node.position = fullPos
        }
        
        return moveTo
    }
}
