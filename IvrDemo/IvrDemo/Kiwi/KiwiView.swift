//
//  KiwiView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/17.
//

import SwiftUI
import RealityKit
import RealityKitContent



/// The model of the Earth.
struct KiwiView: View {
    var earthConfiguration: KiwiEntity.Configuration = .init()

    var animateUpdates: Bool = false
    var axCustomActionHandler: ((_: AccessibilityEvents.CustomAction) -> Void)? = nil

    /// The kiwi
    @State private var earthEntity: KiwiEntity?

    var body: some View {
        RealityView { content in
            // Create an earth entity with tilt, rotation, a moon, and so on.
            let entity = await KiwiEntity(
                configuration: earthConfiguration)
            content.add(entity)

            // Handle custom accessibility events.
            if let axCustomActionHandler {
                _ = content.subscribe(
                    to: AccessibilityEvents.CustomAction.self,
                    on: nil,
                    componentType: nil,
                    axCustomActionHandler)
            }

            // Store for later updates.
            self.earthEntity = earthEntity

        } update: { content in
            // Reconfigure everything when any configuration changes.
            earthEntity?.update(
                configuration: earthConfiguration,
                animateUpdates: animateUpdates)
        }
    }
}

#Preview {
    KiwiView(
        earthConfiguration: KiwiEntity.Configuration.orbitEarthDefault
        
    )
}
