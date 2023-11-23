//
//  PanoramaVideoView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/16.
//

import SwiftUI
import RealityKit
import AVFoundation
import AVKit

struct PanoramaVideoView: View {
    
    @Environment(ViewModel.self) private var model
    
    var body: some View {
        RealityView { content in
            
            let videoEntity = Entity()

            guard let url = Bundle.main.url(forResource: VideoType.wuzhu.rawValue, withExtension: "mov") else {fatalError("Video was not found!")}
            
            //创建播放器
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer()

                 
            //材质
            let material = VideoMaterial(avPlayer: player)
            videoEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))

        
            videoEntity.scale = .init(x: 1, y: 1, z: -1)
            videoEntity.transform.translation += SIMD3<Float>(0.0, 0.0, 0.0)

            //旋转至正前方
            let angle = Angle.degrees(-90)
            let rotation = simd_quatf(angle: Float(angle.radians), axis: .init(x: 0, y: 1, z: 0))
            videoEntity.transform.rotation = rotation


            //添加实体
            content.add(videoEntity)
            
            //播放
            player.replaceCurrentItem(with: playerItem)
            player.play()
            
        } update: { content in

        }
        .onAppear {
            model.isShowingPanoramaVideo = true
        }
        .onDisappear {
            model.isShowingPanoramaVideo = false
        }
    }
}

#Preview {
    PanoramaVideoView()
        //.environment(ViewModel())
}
