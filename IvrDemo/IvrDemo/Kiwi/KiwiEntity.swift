//
//  KiwiEntity.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/17.
//

import RealityKit
import SwiftUI
import RealityKitContent

/// An entity kiki wiwi
class KiwiEntity: Entity {


    private var kiwi: Entity = Entity()


    /// An entity that rotates 23.5° to create axial tilt.
    private let equatorialPlane = Entity()

    /// An entity that provides a configurable rotation,
    /// separate from the day/night cycle.
    private let rotator = Entity()
    
    /// Keep track of solar intensity and only update when it changes.
    private var currentSunIntensity: Float? = nil

    // MARK: - Initializers

    /// Creates a new blank earth entity.
    @MainActor required init() {
        super.init()
    }

    init(
        configuration: Configuration
    ) async {
        super.init()

        // Load the earth and pole models.
        guard let k = await RealityKitContent.entity(named: "Kiwi") else { return }
        self.kiwi = k
        

        self.addChild(equatorialPlane)
        equatorialPlane.addChild(rotator)
        rotator.addChild(kiwi)



        // Configure everything for the first time.
        update(
            configuration: configuration,
            animateUpdates: false)
    }

    // MARK: - Updates

    /// Updates all the entity's configurable elements.
    ///
    /// - Parameters:
    ///   - configuration: Information about how to configure the Earth.
    ///   - satelliteConfiguration: An array of configuration structures, one
    ///     for each artificial satellite.
    ///   - moonConfiguration: A satellite configuration structure that's
    ///     specifically for the Moon.
    ///   - animateUpdates: A Boolean that indicates whether changes to certain
    ///     configuration values should be animated.
    func update(
        configuration: Configuration,
        animateUpdates: Bool
    ) {

        
        // Set a static rotation of the tilted Earth, driven from the configuration.
        rotator.orientation = configuration.rotation

        // Set the speed of the Earth's automatic rotation on it's axis.
        if var rotation: RotationComponent = kiwi.components[RotationComponent.self] {
            rotation.speed = configuration.currentSpeed
            kiwi.components[RotationComponent.self] = rotation
        } else {
            kiwi.components.set(RotationComponent(speed: configuration.currentSpeed))
        }



        // Set the sunlight, if corresponding controls have changed.
        if configuration.currentSunIntensity != currentSunIntensity {
            currentSunIntensity = configuration.currentSunIntensity
        }

        // Tilt the axis according to a date. For this to be meaningful,
        // locate the sun along the positive x-axis. Animate this move for
        // changes that the user makes when the globe appears in the volume.
        var planeTransform = equatorialPlane.transform
        planeTransform.rotation = tilt(date: configuration.date)
        if animateUpdates {
            equatorialPlane.move(to: planeTransform, relativeTo: self, duration: 0.25)
        } else {
            equatorialPlane.move(to: planeTransform, relativeTo: self)
        }

        // Scale and position the entire entity.
        move(
            to: Transform(
                scale: SIMD3(repeating: configuration.scale),
                rotation: orientation,
                translation: configuration.position),
            relativeTo: parent)

        // Set an accessibility component on the entity.
        components.set(makeAxComponent(
            configuration: configuration))
    }

    /// Create an accessibility component suitable for the Earth entity.
    ///
    /// - Parameters:
    ///   - configuration: Information about how to configure the Earth.
    ///   - satelliteConfiguration: An array of configuration structures, one
    ///     for each artificial satellite.
    ///   - moonConfiguration: A satellite configuration structure that's
    ///     specifically for the Moon.
    /// - Returns: A new accessibility component.
    private func makeAxComponent(
        configuration: Configuration
    ) -> AccessibilityComponent {
        // Create an accessibility component.
        var axComponent = AccessibilityComponent()
        axComponent.isAccessibilityElement = true

        // Add a label.
        axComponent.label = "Earth model"

        // Add a value that describes the model's current state.
        var axValue = configuration.currentSpeed != 0 ? "Rotating, " : "Not rotating, "
        axValue.append(configuration.showSun ? "with the sun shining, " : "with the sun not shining, ")
        if configuration.axDescribeTilt {
            if let dateString = configuration.date?.formatted(.dateTime.day().month(.wide)) {
                axValue.append("and tilted for the date \(dateString)")
            } else {
                axValue.append("and no tilt")
            }
        }
        if configuration.showPoles {
            axValue.append("with the poles indicated, ")
        }
       
        axComponent.value = LocalizedStringResource(stringLiteral: axValue)

        // Add custom accessibility actions, if applicable.
        if !configuration.axActions.isEmpty {
            axComponent.customActions.append(contentsOf: configuration.axActions)
        }

        return axComponent
    }

    /// Calculates the orientation of the Earth's tilt on a specified date.
    ///
    /// This method assumes the sun appears at some distance from the Earth
    /// along the negative x-axis.
    ///
    /// - Parameter date: The date that the Earth's tilt represents.
    ///
    /// - Returns: A representation of tilt that you apply to an Earth model.
    private func tilt(date: Date?) -> simd_quatf {
        // Assume a constant magnitude for the Earth's tilt angle.
        let tiltAngle: Angle = .degrees(date == nil ? 0 : 23.5)

        // Find the day in the year corresponding to the date.
        let calendar = Calendar.autoupdatingCurrent
        let day = calendar.ordinality(of: .day, in: .year, for: date ?? Date()) ?? 1

        // Get an axis angle corresponding to the day of the year, assuming
        // the sun appears in the negative x direction.
        let axisAngle: Float = (Float(day) / 365.0) * 2.0 * .pi

        // Create an axis that points the northern hemisphere toward the
        // sun along the positive x-axis when axisAngle is zero.
        let tiltAxis: SIMD3<Float> = [
            sin(axisAngle),
            0,
            -cos(axisAngle)
        ]

        // Create and return a tilt orientation from the angle and axis.
        return simd_quatf(angle: Float(tiltAngle.radians), axis: tiltAxis)
    }
}


extension KiwiEntity {
    /// Configuration information for Earth entities.
    struct Configuration {
        var isCloudy: Bool = false

        var scale: Float = 0.6
        var rotation: simd_quatf = .init(angle: 0, axis: [0, 1, 0])
        var speed: Float = 0
        var isPaused: Bool = false
        var position: SIMD3<Float> = .zero
        var date: Date? = nil

        var showPoles: Bool = false
        var poleLength: Float = 0.875
        var poleThickness: Float = 0.75

        var showSun: Bool = true
        var sunIntensity: Float = 14
        var sunAngle: Angle = .degrees(280)

        var axActions: [LocalizedStringResource] = []
        var axDescribeTilt: Bool = false

        var currentSpeed: Float {
            isPaused ? 0 : speed
        }

        var currentSunIntensity: Float? {
            showSun ? sunIntensity : nil
        }

        static var globeEarthDefault: Configuration = .init(
            axActions: AccessibilityActions.rotate,
            axDescribeTilt: true
        )

        static var orbitEarthDefault: Configuration = .init(
            scale: 0.4,
            speed: 0.1,
            date: Date(),
            axActions: AccessibilityActions.zoom)

        static var solarEarthDefault: Configuration = .init(
            isCloudy: true,
            scale: 4.6,
            speed: 0.045,
            position: [-2, 0.4, -5],
            date: Date())
    }

    /// Custom actions available to people using assistive technologies.
    enum AccessibilityActions {
        case zoomIn, zoomOut, rotateCW, rotateCCW

        /// The name of the action that VoiceOver reads aloud.
        var name: LocalizedStringResource {
            switch self {
            case .zoomIn: "Zoom in"
            case .zoomOut: "Zoom out"
            case .rotateCW: "Rotate clockwise"
            case .rotateCCW: "Rotate counterclockwise"
            }
        }

        /// The collection of zoom actions.
        static var zoom: [LocalizedStringResource] {
            [zoomIn.name, zoomOut.name]
        }

        /// The collection of rotation actions.
        static var rotate: [LocalizedStringResource] {
            [rotateCW.name, rotateCCW.name]
        }
    }
}
