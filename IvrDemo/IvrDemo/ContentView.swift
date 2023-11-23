//
//  ContentView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    /// The library's selection path.
    @State private var navigationPath = [VideoInfo]()
    
    /// A Boolean value that indicates whether the app is currently presenting an immersive space.
    @State private var isPresentingSpace = false
    
    @Environment(PlayController.self) private var player
    @Environment(ViewModel.self) private var model
    
    var body: some View {
        
        switch player.playModel {
        case .fullWindow:
            // 播放View
            PlayerView()
                .onAppear {
                    player.play()
                }
        default:
            
            ZStack {
                // 全景视频操控台UI
                PanoramaVideoUI()
                    .opacity(model.isShowingPanoramaVideo ? 1 : 0)

                // 主View
                MainView(path: $navigationPath, isPresentingSpace: $isPresentingSpace)
                .opacity(model.isShowingPanoramaVideo ? 0 : 1)
            }
            .padding(.leading)
            .animation(.default, value: model.isShowingPanoramaVideo)
            
        }
        
    }
}

#Preview {
    ContentView()
        .environment(PlayController())
        .environment(ViewModel())
}




