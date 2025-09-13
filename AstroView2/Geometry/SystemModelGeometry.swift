//
//  SystemModelGeometry.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/20/24.
//

import Foundation

import Algorithms
import SceneKit
import simd

public class SystemModelGeometry: SpaceGeometry {
    private let _systemModel: SystemModel
    private static let _secondsInYear : Double = 365.25 * 24 * 60 * 60
    
    public init(withModel model: SystemModel) {
        _systemModel = model
    }
    
    public func createGeometry() throws -> SCNNode {
        let solarSystemNode = SCNNode()
        
        try addSolarBodies(targetNode: solarSystemNode)
        
        return solarSystemNode
    }
    
    private func addSolarBodies(targetNode: SCNNode) throws {
        try addBody(bodyRecord: _systemModel.bodyCatalog.sun, targetNode: targetNode)

        targetNode.position = SCNVector3(0.0, 0.0, 1000.0)
        
        // for debugging
        targetNode.addChildNode(SystemModelGeometry.makeAxesNode())
    }
    
    private func addBody(bodyRecord: BodyRecord, targetNode: SCNNode) throws {
        let systemNode = SCNNode()
        systemNode.name = bodyRecord.name

        let curDate = Date.now
        let fullPos = _systemModel.parentRelativePosition(forBody: bodyRecord, atTime: curDate).toSCN()
        let mtx = SCNMatrix4MakeTranslation(fullPos.x, fullPos.y, fullPos.z)
        systemNode.setWorldTransform(mtx)
      
        let bodyNode = SystemModelGeometry.solarSystemBody(forBodyRecord: bodyRecord,
                                                            computeDate: bodyRecord.computeFractionalYearDate,
                                                            computePosition: {d in self._systemModel.parentRelativePosition(forBody: bodyRecord, atTime: d)},
                                                            pointerColor: NSColor.red)
        systemNode.addChildNode(bodyNode)
        
        let childBodyNode = SCNNode()
        try _systemModel.bodyCatalog.forEachChild(of: bodyRecord) { childBody in
            try addBody(bodyRecord: childBody, targetNode: childBodyNode)
        }
        systemNode.addChildNode(childBodyNode)
        
        targetNode.addChildNode(systemNode)
    }
    
    private func addBodies(targetNode: SCNNode, ofType: BodyType) throws {
        try _systemModel.bodyCatalog.forEachBody { body in
            if body.bodyType != ofType {
                return
            }
            
            let childNode = SystemModelGeometry.solarSystemBody(forBodyRecord: body,
                                                                computeDate: body.computeFractionalYearDate,
                                                                computePosition: {d in self._systemModel.parentRelativePosition(forBody: body, atTime: d)},
                                                                pointerColor: NSColor.red)
            
            targetNode.addChildNode(childNode)
        }
    }
    
    private class func solarSystemBody(forBodyRecord body: BodyRecord,
                                       computeDate: @escaping (Date, Double) -> Date,
                                       computePosition: @escaping (Date) -> simd_double3,
                                       pointerColor: NSColor) -> SCNNode {
        let fullRadius = body.earthRadiusFraction * AstroConstants.earthRadius
        
        // we'll create two nodes here and put them under a parent node
        // the first node is stuff that moves with the body
        // the second is stuff that doesn't (e.g., the orbital path)
        
        let moveWithBodyNode = SCNNode()
        let fixedNode = SCNNode()
        
        let solarBodyNode = createBodyNode(forBodyRecord: body)
        moveWithBodyNode.addChildNode(solarBodyNode)
        
        let fullPos = computePosition(Date.now).toSCN()

        if (body.bodyType != .Sun) {
            // add a cylinder connecting the center of the world to its parent
            let cylinderNode = cylinderNode(radius: fullRadius / 4.0, targetPos: fullPos.scaleBy(-1.0), withColor: pointerColor)
            cylinderNode.name = "parentConnector"
            moveWithBodyNode.addChildNode(cylinderNode)

            // add the up vector
            let upvecNode = makeUpVectorNode(forBodyRecord: body, usingComputeFunction: computePosition, withColor: NSColor.green, withLength: fullRadius * 1000.0)
            upvecNode.name = "upVector"
            moveWithBodyNode.addChildNode(upvecNode)
        }
        
        if (body.bodyType != .Sun) {
            // add the orbits for planets and moons
            let orbitColor = body.bodyType == .Planet ? NSColor.yellow : NSColor.white
            let orbitNode = makeOrbitNode(computeDate: computeDate, computePosition: computePosition, withColor: orbitColor)
            orbitNode.name = "orbitPath"
            fixedNode.addChildNode(orbitNode)
        }
        

        let parentNode = SCNNode()
        parentNode.addChildNode(moveWithBodyNode)
        parentNode.addChildNode(fixedNode)
        
        return parentNode
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
    
    private class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    private class func makeUpVectorNode(forBodyRecord body: BodyRecord,
                                        usingComputeFunction computePosition: (Date) -> simd_double3,
                                        withColor color: NSColor, withLength length: CGFloat) -> SCNNode {
        let posNow = computePosition(Date.now)
        
        // find its position now, 1/4 of an orbit from now, and 1/2 of an orbit from now
        let oneQuarterSeconds = (body.orbitalPeriodEarthYears / 4) * AstroConstants.secondsPerYear

        let oneQuarterOrbitFromNow = Calendar.current.date(byAdding: .second, value: Int(oneQuarterSeconds), to: Date.now)!
        let oneHalfOrbitFromNow = Calendar.current.date(byAdding: .second, value: Int(oneQuarterSeconds), to: oneQuarterOrbitFromNow)!
        let posQuarterOrbit = computePosition(oneQuarterOrbitFromNow)
        let posHalfOrbit = computePosition(oneHalfOrbitFromNow)
        
        let v3 = SCNVector3(posQuarterOrbit.x - posNow.x, posQuarterOrbit.y - posNow.y, posQuarterOrbit.z - posNow.z)
        let v6 = SCNVector3(posHalfOrbit.x - posNow.x, posHalfOrbit.y - posNow.y, posHalfOrbit.z - posNow.z)
        
        let upVec = v3.crossProduct(v6)
        
        let longUpVec = upVec.extendTo(to: length)
        
        print("calculated up vector for \(body.name): \(longUpVec)")
        
        let cylinderNode = cylinderNode(radius: 1.0, targetPos: longUpVec, withColor: color)

        return cylinderNode
    }

    private class func makeOrbitNode(computeDate: @escaping (Date, Double) -> Date, computePosition: @escaping (Date) -> simd_double3, withColor color: NSColor) -> SCNNode {
        let orbitMaterial = SCNMaterial()
        orbitMaterial.diffuse.contents = color
        
        let basePosition = computePosition(Date.now).toSCN()

        // build the geometry
        let rawPositionsAllMapped = orbitNodeArrayAllMapped(numSteps: 60, computeDate: computeDate, computePosition: computePosition)
        
        let positions = Array(rawPositionsAllMapped.map { $0.toSCN().relativeTo(basePosition) })
        
        let positions2 = positions

        var positionPairs = [(SCNVector3, SCNVector3)](repeating: (SCNVector3.zero, SCNVector3.zero), count: positions.count)
        positionPairs.replaceSubrange(0..<positions.count, with: positions2.adjacentPairs())
        positionPairs[positionPairs.count - 1] = (positionPairs[positionPairs.count - 2].1, positionPairs[0].0)

        let orbitNode = SCNNode()
        orbitNode.name = "orbit"
        
        let lineGeoms = positionPairs.map { lineFrom(vector: $0.0, toVector: $0.1) }
        for oneGeom in lineGeoms {
            let oneNode = SCNNode(geometry: oneGeom)
            oneNode.geometry?.materials = [orbitMaterial]
            orbitNode.addChildNode(oneNode)
        }
        
        // done
        return orbitNode
    }
    
    private class func orbitNodeArrayAllMapped(numSteps: Int, computeDate: @escaping (Date, Double) -> Date, computePosition: @escaping (Date) -> simd_double3) -> [simd_double3] {
        let stepSize = (1.0 / (CGFloat(numSteps - 1)))

        let steps = Array(stride(from: 0.0, through: 1.0, by: stepSize))
        let startDate = Date.now
        let dates = steps.map { computeDate(startDate, $0) }
        let rawPositions: [simd_double3] = Array(dates.map(computePosition))
        
        return rawPositions
    }
    
    private class func createBodyNode(forBodyRecord body: BodyRecord) -> SCNNode {
        let fullRadius = body.earthRadiusFraction * AstroConstants.earthRadius

        let sphere = SCNSphere(radius: fullRadius)
        let solarBodyNode = SCNNode( geometry: sphere)
        let textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: body.texturePath, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        textureMaterial.diffuse.contents = myImage
        solarBodyNode.geometry?.materials = [textureMaterial]
        solarBodyNode.name = "solarBody"

        return solarBodyNode
    }
}
