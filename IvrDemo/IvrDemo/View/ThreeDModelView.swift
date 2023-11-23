//
//  ThreeDModelView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/15.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ThreeDModelView: View {
    
    @Environment(ViewModel.self) private var model
    
    @State var axZoomIn: Bool = false
    @State var axZoomOut: Bool = false
    
    var body: some View {


        
        //普通体积Window
//        Model3D(named: "Globe"){ model in
//            model
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 300)
//                
//        } placeholder: {
//            ProgressView()
//        }
        
        KiwiView(
            earthConfiguration: KiwiEntity.Configuration.orbitEarthDefault
        ) { event in
            if event.key.defaultValue == KiwiEntity.AccessibilityActions.zoomIn.name.defaultValue {
                axZoomIn.toggle()
            } else if event.key.defaultValue == KiwiEntity.AccessibilityActions.zoomOut.name.defaultValue {
                axZoomOut.toggle()
            }
        }
        .placementGestures(
            initialPosition: Point3D([1200, -1200.0, -1000.0]),
            axZoomIn: axZoomIn,
            axZoomOut: axZoomOut)
        .onDisappear {
            model.isShowing3Dmodel = false
        }
        
    }
}

#Preview {
    ThreeDModelView()
}
