//
//  ImmersiveView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//


import SwiftUI
import RealityKit
import Combine
import RealityKitContent


/// A view that displays a 360 degree scene in which to watch video.
struct ImmersiveView: View {
    
    @State private var destination: VideoType
    @State private var destinationChanged = false
    
    @Environment(PlayController.self) private var model
    
    init(_ destination: VideoType) {
        self.destination = destination
    }
    
    var body: some View {
        
        RealityView { content in
            
            //粒子氛围
            do{
                let e = try await Entity(named: "Immersive", in: realityKitContentBundle)
                content.add(e)
            }
            catch{}
            
            
            let rootEntity = Entity()
            rootEntity.addSkybox(for: destination)
            content.add(rootEntity)
        } update: { content in
            guard destinationChanged else { return }
            guard let entity = content.entities.first else { fatalError() }
            entity.updateTexture(for: destination)
            Task { @MainActor in
                destinationChanged = false
            }
        }
        .transition(.opacity)
        
    }
}

extension Entity {
    func addSkybox(for destination: VideoType) {
        let subscription = TextureResource.loadAsync(named: destination.imageName).sink(
            receiveCompletion: {
                switch $0 {
                case .finished: break
                case .failure(let error): assertionFailure("\(error)")
                }
            },
            receiveValue: { [weak self] texture in
                guard let self = self else { return }
                
                //创建一个材质
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                self.components.set(ModelComponent(
                    mesh: .generateSphere(radius: 1000),
                    materials: [material]
                ))
                
                self.scale *= .init(x: -1, y: 1, z: 1)
                self.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
                
                // Rotate the sphere to show the best initial view of the space.
                updateRotation(for: destination)
            }
        )
        components.set(Entity.SubscriptionComponent(subscription: subscription))
    }
    
    func updateTexture(for destination: VideoType) {
        let subscription = TextureResource.loadAsync(named: destination.imageName).sink(
            receiveCompletion: {
                switch $0 {
                case .finished: break
                case .failure(let error): assertionFailure("\(error)")
                }
            },
            receiveValue: { [weak self] texture in
                guard let self = self else { return }
                
                guard var modelComponent = self.components[ModelComponent.self] else {
                    fatalError("Should this be fatal? Probably.")
                }
                
                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                modelComponent.materials = [material]
                self.components.set(modelComponent)
                
                // Rotate the sphere to show the best initial view of the space.
                updateRotation(for: destination)
            }
        )
        components.set(Entity.SubscriptionComponent(subscription: subscription))
    }
    
    func updateRotation(for destination: VideoType) {
        
        let angle = Angle.degrees(destination.rotationDegrees)
        let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
        self.transform.rotation = rotation
    }
    

    struct SubscriptionComponent: Component {
        var subscription: AnyCancellable
    }
}

