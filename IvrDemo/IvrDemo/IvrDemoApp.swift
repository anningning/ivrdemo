//
//  IvrDemoApp.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI
import os

@main
struct IvrDemoApp: App {
    
    //播放管理器
    @State private var player = PlayController()
    
    //视频资源管理器
    @State private var library = VideoController()
    
    //页面管理
    @State private var model = ViewModel()
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some Scene {
        
        //主Window
        WindowGroup (id: "main"){
            ContentView()
                .environment(player)
                .environment(library)
                .environment(model)
                .aspectRatio(model.ScreenWidth/model.ScreenHeight, contentMode: .fit)
        }
        .windowStyle(.plain)
        .defaultSize(width: model.ScreenWidth, height: model.ScreenHeight)

        // 苍兰诀氛围
        ImmersiveSpace(id: VideoType.canglan.rawValue){
            ImmersiveView(VideoType.canglan)
                .environment(player)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // 全景视频氛围
        ImmersiveSpace(id: VideoType.wuzhu.rawValue){
            PanoramaVideoView()
                .environment(model)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // 综艺氛围
        ImmersiveSpace(id: VideoType.yuexia.rawValue){
            ThreeDModelView()
                .environment(model)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
    }
}

/// 全局log
let logger = Logger()
