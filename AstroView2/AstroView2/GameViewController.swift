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
    
    func moveNode(scene: SCNScene, nodeName: String, forDate: Date, moveFunc: (Date) -> simd_double3) {
        let bodyNode = scene.rootNode.childNode(withName: nodeName, recursively: true)!
        let position = moveFunc(forDate).toSCN()
        bodyNode.position = position.scaleBy(AstroConstants.oneAu)
    }
}

class GameViewController: NSViewController {
    
    private let rendererDelegate = SceneRendererDelegate()
    
    private let _systemModel : SystemModel = SpiceSystemModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene and null out gravity
        let scene = SCNScene(named: "art.scnassets/EmptySpace.scn")!
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        // create all the solar system bodies
        do {
            try addSolarBodies(targetNode: scene.rootNode)
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
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 1.1 * AstroConstants.oneAu)
        cameraNode.camera?.zFar = 5 * AstroConstants.oneAu
        
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
        
        let sunNode = scene.rootNode.childNode(withName: "Sun", recursively: true)!
        let bodyNode = sunNode.childNode(withName: "solarBody", recursively: true)!
        let bodyBounds = bodyNode.geometry!.boundingBox
        
        // we'll view from .02 AU away
        let bodyMax = bodyBounds.max
        let bodyMaxLen = bodyMax.length()
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
        camera.zFar = 1.5 * AstroConstants.oneAu
        
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
    
    private func addSolarBodies(targetNode: SCNNode) throws {
        let solarSystemNode = SCNNode();
        targetNode.addChildNode(solarSystemNode)
        
        try _systemModel.forEachBody { body in
            let childNode = GameViewController.solarSystemBody(bodyName: body.name, earthRadiusFraction: body.earthRadiusFraction, textureName: body.texturePath,
                                                               computePosition: {d in self._systemModel.sunRelativePosition(forBody: body, atTime: d)},
                pointerColor: NSColor.red)
            solarSystemNode.addChildNode(childNode)
        }
        solarSystemNode.position = SCNVector3(0.0, 0.0, 1000.0)
        
        // for debugging
        targetNode.addChildNode(GameViewController.makeAxesNode())
    }
    
    private class func sphereNode(at: SCNVector3, withColor: NSColor) -> SCNNode {
        let sphere = SCNSphere(radius: AstroConstants.oneAu / 100.0)
        sphere.firstMaterial?.diffuse.contents = withColor
        sphere.firstMaterial?.specular.contents = withColor
        sphere.firstMaterial?.shininess = 0.0
        
        let sphereNode = SCNNode()
        sphereNode.position = at
        sphereNode.geometry = sphere
        return sphereNode
    }
    
    private class func makeAxesNode() -> SCNNode {
        let axesNode = SCNNode()
        let xGeom = cylinderNode(radius: 0.01, targetPos: SCNVector3(AstroConstants.oneAu, 0.0, 0.0), withColor: NSColor.cyan)
        let yGeom = cylinderNode(radius: 0.01, targetPos: SCNVector3(0.0, AstroConstants.oneAu, 0.0), withColor: NSColor.yellow)
        let zGeom = cylinderNode(radius: 0.01, targetPos: SCNVector3(0.0, 0.0, AstroConstants.oneAu), withColor: NSColor.magenta)
        
        axesNode.addChildNode(xGeom)
        axesNode.addChildNode(yGeom)
        axesNode.addChildNode(zGeom)

        /*
        // draw markers
        let stepSize = 0.05
        for step in stride(from: stepSize, through: 1.0, by: stepSize) {
            axesNode.addChildNode(sphereNode(at: SCNVector3(AstroConstants.oneAu * step, 0.0, 0.0), withColor: NSColor.white))
            axesNode.addChildNode(sphereNode(at: SCNVector3(0.0, AstroConstants.oneAu * step, 0.0), withColor: NSColor.white))
            axesNode.addChildNode(sphereNode(at: SCNVector3(0.0, 0.0, AstroConstants.oneAu * step), withColor: NSColor.white))
        }
         */

        axesNode.name = "axes"
        return axesNode
    }
    
    private class func makeUpVectorNode(usingComputeFunction computePosition: (Date) -> simd_double3,
                                        withColor color: NSColor, withLength length: CGFloat) -> SCNNode {
        let posNow = computePosition(Date.now)
        
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date.now)!
        let sixMonthsFromNow = Calendar.current.date(byAdding: .month, value: 6, to: Date.now)!
        let pos3Months = computePosition(threeMonthsFromNow)
        let pos6Months = computePosition(sixMonthsFromNow)
        
        let v3 = SCNVector3(pos3Months.x - posNow.x, pos3Months.y - posNow.y, pos3Months.z - posNow.z)
        let v6 = SCNVector3(pos6Months.x - posNow.x, pos6Months.y - posNow.y, pos6Months.z - posNow.z)
        
        let upVec = v3.crossProduct(v6)
        
        let longUpVec = upVec.extendTo(to: length)
        
        print("calculated up vector: \(longUpVec)")
        
        let cylinderNode = cylinderNode(radius: 1.0, targetPos: longUpVec, withColor: color)

        return cylinderNode
    }

    private class func solarSystemBody(bodyName: String, earthRadiusFraction: Double,
                                       textureName: String,
                                       computePosition: @escaping (Date) -> simd_double3,
                                       pointerColor: NSColor) -> SCNNode {
        let fullRadius = earthRadiusFraction * AstroConstants.earthRadius
        
        let parentNode = SCNNode()
        
        let sphere = SCNSphere(radius: fullRadius)
        let solarBodyNode = SCNNode( geometry: sphere)
        let textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        let nodePos = computePosition(Date.now).toSCN()
        let fullPos = nodePos.scaleBy(AstroConstants.oneAu)
        textureMaterial.diffuse.contents = myImage
        solarBodyNode.geometry?.materials = [textureMaterial]
        solarBodyNode.name = "solarBody"
        
        if (bodyName != "Sun") {
            // add a cylinder connecting the center of the world to the sun
            let cylinderNode = cylinderNode(radius: fullRadius / 4.0, targetPos: fullPos.scaleBy(-1.0), withColor: pointerColor)
            cylinderNode.name = "sunConnector"
            parentNode.addChildNode(cylinderNode)
            
            // add the up vector
            let upvecNode = makeUpVectorNode(usingComputeFunction: computePosition, withColor: pointerColor, withLength: fullRadius * 10.0)
            upvecNode.name = "upVector"
            parentNode.addChildNode(upvecNode)
        }

        parentNode.addChildNode(solarBodyNode)
        // parentNode.position = fullPos
        let mtx = SCNMatrix4MakeTranslation(fullPos.x, fullPos.y, fullPos.z)
        parentNode.setWorldTransform(mtx)
        parentNode.name = bodyName
        
        print("\(solarBodyNode.position) \(solarBodyNode.worldPosition)")
        print("\(parentNode.position) \(parentNode.worldPosition)")
        print("parent pivot: \(parentNode.pivot)")
        print("body pivot: \(solarBodyNode.pivot)")
        print("parent simdPosition: \(parentNode.simdPosition)")
        print("parent simdTransform: \(parentNode.simdTransform)")
        // node.addAnimation(axialRotationAnimation(), forKey: "rotation about axis")

        return parentNode
    }
    
    private class func cylinderNode(radius: CGFloat, targetPos: SCNVector3, withColor: NSColor) -> SCNNode {
        let cylMaterial = SCNMaterial()
        cylMaterial.diffuse.contents = withColor

        /*
        let cylinder = SCNCylinder(radius: 109, height: targetPos.length())
        cylinder.materials = [cylMaterial]
        */
        
        let cylinderGeom = lineFrom(vector: SCNVector3(0.0, 0.0, 0.0), toVector: targetPos)
        let cylinderNode = SCNNode(geometry: cylinderGeom)
        cylinderGeom.materials = [cylMaterial]

        // calc elevation and azimuth to that position
        /*
        let azimuthElevation = targetPos.azimuthElevation

        let xzRotate = SCNVector3(0.0, 1.0, 0.0).quaternion(fromAngleRadians: azimuthElevation.azimuth)
        let yRotate = SCNVector3(targetPos.x, 0.0, targetPos.z).quaternion(fromAngleRadians: azimuthElevation.elevation)
        
        cylinderNode.rotate(by: xzRotate, aroundTarget: SCNVector3(0.0, 1.0, 0.0))
        cylinderNode.rotate(by: yRotate, aroundTarget: SCNVector3(targetPos.x, 0.0, targetPos.z))
        */
        
        // done
        return cylinderNode
    }

    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]

        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)

        return SCNGeometry(sources: [source], elements: [element])

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
