//
//  SolarSystemEntity.swift
//  AstroRk
//
//  Created by Jeff Doar on 9/14/25.
//

import Foundation
import RealityKit

class SolarSystemEntity {
    class func entity() -> Entity {
        let curDate = Date.now
        let entity = Entity()
        entity.addChild(sun())
        
        positionEntities(atDate: curDate, solarEntity: entity)
      
        return entity
    }
    
    private class func sun() -> Entity {
        let sunEntity = Entity()
        let body = solarBody(bodyRadius: 695700, name: "Sun", textureName: "Solarsystemscope_texture_8k_sun")
        sunEntity.components.set([body])
        sunEntity.name = "Sun"
        
        sunEntity.addChild(mercury())
        
        return sunEntity
    }
    
    private class func mercury() -> Entity {
        let mercuryEntity = Entity()
        let body = solarBody(bodyRadius: 2439.7, name: "Mercury", textureName: "Solarsystemscope_texture_8k_mercury")
        mercuryEntity.components.set([body])
        mercuryEntity.name = "Mercury"
        return mercuryEntity
    }
    
    private class func solarBody(bodyRadius: Float, name: String, textureName: String) -> ModelComponent {
        let localRadius: Float = bodyRadius.kmToViewUnits
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
    
    private class func positionEntities(atDate: Date, solarEntity: Entity) {
        let sun = solarEntity.findEntity(named: "Sun")!
        sun.setPosition(.zero, relativeTo: solarEntity)
        
        let mercury = sun.findEntity(named: "Mercury")!
    }
}
