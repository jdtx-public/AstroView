//
//  SolarSystemEntity.swift
//  AstroRk
//
//  Created by Jeff Doar on 9/14/25.
//

import Foundation
import RealityKit

class SolarSystemEntity {
    class func entity(systemModel: SystemModel) -> Entity {
        let entity = Entity()
        let bodyCatalog = systemModel.bodyCatalog
        
        let sunRecord = bodyCatalog.sun
        let sunEntity = makeEntity(forRecord: sunRecord)
        
        addChildrenToEntity(parentEntity: sunEntity, parentRecord: bodyCatalog.sun, fromCatalog: bodyCatalog)
        
        entity.addChild(sunEntity)
                
        return entity
    }
    
    private class func makeEntity(forRecord: BodyRecord) -> Entity {
        let entity = Entity()
        let body = solarBody(bodyRadius: forRecord.earthRadiusFraction, name: forRecord.name, textureName: forRecord.texturePath)
        let recordComponent = BodyRecordComponent(bodyRecord: forRecord)
        
        entity.components.set([body, recordComponent])
        entity.name = forRecord.name
        
        return entity
    }
    
    private class func addChildrenToEntity(parentEntity: Entity, parentRecord: BodyRecord, fromCatalog: BodyCatalog) {
        do {
            try fromCatalog.forEachChild(of: parentRecord) { childRecord in
                let childEntity = makeEntity(forRecord: childRecord)
                parentEntity.addChild(childEntity)
                
                addChildrenToEntity(parentEntity: childEntity, parentRecord: childRecord, fromCatalog: fromCatalog)
            }
        }
        catch {
            // ignore for now
        }
    }
    
    private class func solarBody(bodyRadius: Double, name: String, textureName: String) -> ModelComponent {
        let localRadius: Float = Float(bodyRadius.earthRadiiToViewUnits)
        var baseMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
        let textureResource = try? TextureResource.load(named: textureName)
        if textureResource != nil {
            baseMaterial.color = PhysicallyBasedMaterial.BaseColor(texture: .init(textureResource!))
        }
        let materials: [any Material] = [baseMaterial]
        return ModelComponent(
            mesh: .generateSphere(radius: localRadius),
            materials: materials,
        )
    }
}
