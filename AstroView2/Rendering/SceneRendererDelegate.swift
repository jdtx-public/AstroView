//
//  SceneRendererDelegate.swift
//  AstroView2
//
//  Created by Jeff Doar on 9/13/25.
//

import Foundation
import SceneKit
import QuartzCore
import SCNMathExtensions
import novas_swift
import simd

public class SceneRendererDelegate: NSObject, SCNSceneRendererDelegate {
    private let _systemModel: SystemModel
    private var _curTime: Date
    private var _lastUpdateTime: TimeInterval
    
    public init(systemModel: SystemModel) {
        _systemModel = systemModel
        _curTime = Date.now
        _lastUpdateTime = 0.0
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let scene = renderer.scene!
        let timeDiff = _lastUpdateTime != 0.0 ? time - _lastUpdateTime : 0.0
        let timeBump = timeDiff * 3600.0 * 24.0
        _curTime = _curTime.addingTimeInterval(timeBump)

        _lastUpdateTime = time

        let sunRecord = _systemModel.bodyCatalog.sun
        
        do {
            try _systemModel.bodyCatalog.forEachChild(of: sunRecord) { child in
                moveNode(scene: scene, nodeName: child.name, forDate: _curTime,
                         moveFunc: {
                            inputDate in _systemModel.sunRelativePosition(forBody: child, atTime: inputDate)
                        })
            }
        } catch {
        }
    }
    
    func moveNode(scene: SCNScene, nodeName: String, forDate: Date, moveFunc: (Date) -> simd_double3) {
        let bodyNode = scene.rootNode.childNode(withName: nodeName, recursively: true)!
        let fullPos = moveFunc(forDate).toSCN()
        let mtx = SCNMatrix4MakeTranslation(fullPos.x, fullPos.y, fullPos.z)
        bodyNode.setWorldTransform(mtx)
        // bodyNode.position = position.scaleBy(AstroConstants.oneAu)
    }
}

