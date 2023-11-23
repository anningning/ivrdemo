//
//  ViewExtension.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI
import UIKit



extension View {
    
    /// A helper function that returns a platform-specific value.
    func valueFor<V>(visionOS: V) -> V {
        visionOS
    }
    
    
    
    
    /// A debugging function to add a border around a view.
    func debugBorder(color: Color = .red, width: CGFloat = 1.0, opacity: CGFloat = 1.0) -> some View {
        self
            .border(color, width: width)
            .opacity(opacity)
    }
    
    /// Listens for gestures and places an item based on those inputs.
    func placementGestures(
        initialPosition: Point3D = .zero,
        axZoomIn: Bool = false,
        axZoomOut: Bool = false
    ) -> some View {
        self.modifier(
            PlacementGesturesModifier(
                initialPosition: initialPosition,
                axZoomIn: axZoomIn,
                axZoomOut: axZoomOut
            )
        )
    }
}

/// A modifier that adds gestures and positioning to a view.
private struct PlacementGesturesModifier: ViewModifier {
    var initialPosition: Point3D
    var axZoomIn: Bool
    var axZoomOut: Bool

    @State private var scale: Double = 1
    @State private var startScale: Double? = nil
    @State private var position: Point3D = .zero
    @State private var startPosition: Point3D? = nil

    func body(content: Content) -> some View {
        content
            .onAppear {
                position = initialPosition
            }
            .scaleEffect(scale)
            .position(x: position.x, y: position.y)
            .offset(z: position.z)

            // Enable people to move the model anywhere in their space.
            .simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
                .handActivationBehavior(.pinch)
                .onChanged { value in
                    if let startPosition {
                        let delta = value.location3D - value.startLocation3D
                        position = startPosition + delta
                    } else {
                        startPosition = position
                    }
                }
                .onEnded { _ in
                    startPosition = nil
                }
            )

            // Enable people to scale the model within certain bounds.
            .simultaneousGesture(MagnifyGesture()
                .onChanged { value in
                    if let startScale {
                        scale = max(0.1, min(3, value.magnification * startScale))
                    } else {
                        startScale = scale
                    }
                }
                .onEnded { value in
                    startScale = scale
                }
            )
            .onChange(of: axZoomIn) {
                scale = max(0.1, min(3, scale + 0.2))
                startScale = scale
            }
            .onChange(of: axZoomOut) {
                scale = max(0.1, min(3, scale - 0.2))
                startScale = scale
            }
    }
}
