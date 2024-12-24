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
        
        try _systemModel.forEachBody { body in
            let childNode = SystemModelGeometry.solarSystemBody(bodyName: body.name, earthRadiusFraction: body.earthRadiusFraction, textureName: body.texturePath,
                                                                computePosition: {d in self._systemModel.sunRelativePosition(forBody: body, atTime: d)},
                                                                pointerColor: NSColor.red)
            targetNode.addChildNode(childNode)
        }
        targetNode.position = SCNVector3(0.0, 0.0, 1000.0)
        
        // for debugging
        targetNode.addChildNode(SystemModelGeometry.makeAxesNode())
    }
    
    private class func solarSystemBody(bodyName: String, earthRadiusFraction: Double,
                                       textureName: String,
                                       computePosition: @escaping (Date) -> simd_double3,
                                       pointerColor: NSColor) -> SCNNode {
        let fullRadius = earthRadiusFraction * AstroConstants.earthRadius
        
        // we'll create two nodes here and put them under a parent node
        // the first node is stuff that moves with the body
        // the second is stuff that doesn't (e.g., the orbital path)
        
        let moveWithBodyNode = SCNNode()
        let fixedNode = SCNNode()
        
        let sphere = SCNSphere(radius: fullRadius)
        let solarBodyNode = SCNNode( geometry: sphere)
        let textureMaterial = SCNMaterial()
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: textureName, ofType: "jpg", inDirectory: "art.scnassets")
        let myImage = NSImage(byReferencingFile: resourcePath!)!
        let nodePos = computePosition(Date.now).toSCN()
        let fullPos = nodePos
        textureMaterial.diffuse.contents = myImage
        solarBodyNode.geometry?.materials = [textureMaterial]
        solarBodyNode.name = "solarBody"
        
        if (bodyName != "Sun") {
            // add a cylinder connecting the center of the world to the sun
            let cylinderNode = cylinderNode(radius: fullRadius / 4.0, targetPos: fullPos.scaleBy(-1.0), withColor: pointerColor)
            cylinderNode.name = "sunConnector"
            moveWithBodyNode.addChildNode(cylinderNode)
            
            // add the up vector
            let upvecNode = makeUpVectorNode(usingComputeFunction: computePosition, withColor: NSColor.green, withLength: fullRadius * 1000.0)
            upvecNode.name = "upVector"
            moveWithBodyNode.addChildNode(upvecNode)
            
            // add the orbits too
            let orbitNode = makeOrbitNode(computePosition: computePosition, withColor: NSColor.yellow)
            orbitNode.name = "orbitPath"
            fixedNode.addChildNode(orbitNode)
        }
        
        moveWithBodyNode.addChildNode(solarBodyNode)
        // parentNode.position = fullPos
        let mtx = SCNMatrix4MakeTranslation(fullPos.x, fullPos.y, fullPos.z)
        moveWithBodyNode.setWorldTransform(mtx)
        moveWithBodyNode.name = bodyName

        let parentNode = SCNNode()
        parentNode.addChildNode(moveWithBodyNode)
        parentNode.addChildNode(fixedNode)

        /*
        print("\(solarBodyNode.position) \(solarBodyNode.worldPosition)")
        print("\(parentNode.position) \(parentNode.worldPosition)")
        print("parent pivot: \(parentNode.pivot)")
        print("body pivot: \(solarBodyNode.pivot)")
        print("parent simdPosition: \(parentNode.simdPosition)")
        print("parent simdTransform: \(parentNode.simdTransform)")
        */
        // node.addAnimation(axialRotationAnimation(), forKey: "rotation about axis")
        
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

    private class func makeOrbitNode(computePosition: @escaping (Date) -> simd_double3, withColor color: NSColor) -> SCNNode {
        let orbitMaterial = SCNMaterial()
        orbitMaterial.diffuse.contents = color

        // build the geometry
        let numSteps: Int = 30
        let stride = (1.0 / (CGFloat(numSteps) * 2.0)) * _secondsInYear
        
        var rawPositions: [simd_double3] = [simd_double3](repeating: simd_double3.zero, count: numSteps * 2)
        
        for i in 0..<numSteps {
            let dateHere = Date.now.advanced(by: Double(i) * stride)
            rawPositions[i] = computePosition(dateHere)
            rawPositions[i + numSteps] = rawPositions[i] * -1.0
            
            print("\(dateHere): \(rawPositions[i]) \(rawPositions[i + numSteps])")
        }
        
        let positions = Array(rawPositions.map { $0.toSCN() })
        
        // remember that the positions all need to be relative to now because
        // the planet's position is the parent node position
        // let positions2 = positions.map { $0.subtracted(by: positions[0]) }
        let positions2 = positions

        let positionPairs = Array(positions2.adjacentPairs())

        let orbitNode = SCNNode()
        orbitNode.name = "orbit"
        
        let lineGeoms = positionPairs.map { lineFrom(vector: $0.0, toVector: $0.1) }
        for oneGeom in lineGeoms {
            let oneNode = SCNNode(geometry: oneGeom)
            oneNode.geometry?.materials = [orbitMaterial]
            orbitNode.addChildNode(oneNode)
        }
        
        let vectorLens = Array(positionPairs.map { $0.0.distance(to: $0.1) })

        /*
        let index01: [Int32] = [0, 1]
        let pairsSource = positionPairs.map { SCNGeometrySource(vertices: [ $0.0, $0.1 ]) }
        let elementSource = positionPairs.map { _ in SCNGeometryElement(indices: index01, primitiveType: .line) }
        
        let sources = Array(pairsSource)
        let elements = Array(elementSource)

        // let geomSource = [SCNGeometrySource(vertices: positions2)]
        // let geomElem = [SCNGeometryElement(indices: indices, primitiveType: .line)]

        let orbitGeom = SCNGeometry(sources: sources, elements: elements)
        orbitGeom.materials = [orbitMaterial]

        let orbitNode = SCNNode(geometry: orbitGeom)
        orbitNode.name = "orbit"
        */

        // done
        return orbitNode
    }

    /*
    private class func makeOrbitPathNode(usingComputeFunction computePosition: (Date) -> simd_double3,
                                        withColor color: NSColor) -> SCNNode {
        let lineMaterial = SCNMaterial()
        lineMaterial.diffuse.contents = color

        let orbitNode = SCNNode()
        
        let pathSegments = 4
        
        var curDate = Date.now

        var curPos = computePosition(curDate)
        
        for _ in 0...pathSegments {
            let nextDate = Calendar.current.date(byAdding: .month, value: 3, to: curDate)!
            let nextPos = computePosition(nextDate)
            
            let lineDiff = nextPos - curPos
            
            let curPosScn = curPos.toSCN().scaleBy(AstroConstants.oneAu)
            let nextPosScn = nextPos.toSCN().scaleBy(AstroConstants.oneAu)
            let linePosScn = lineDiff.toSCN().scaleBy(AstroConstants.oneAu)
            
            let cylinderNode = cylinderNode(radius: 3.0, targetPos: linePosScn, withColor: color)
            cylinderNode.position = curPosScn

            /*
            let lineGeom = lineFrom(vector: curPosScn, toVector: nextPosScn)
            let lineNode = SCNNode(geometry: lineGeom)
            lineGeom.materials = [lineMaterial]
            */

            curDate = nextDate
            curPos = nextPos
            
            orbitNode.addChildNode(cylinderNode)
        }
        
        return orbitNode
    }
    */
}
