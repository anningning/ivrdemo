//
//  VideoDetailView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
//视频详情页

import SwiftUI

struct VideoDetailView: View {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    let video: VideoInfo
    @Environment(PlayController.self) private var player
    @Environment(VideoController.self) private var library
    
    let margins = 30.0
    
    var body: some View {
        HStack(alignment: .top, spacing: margins) {
            
            // 详情信息
            VStack(alignment: .leading) {
                
                
                VideoInfoView(video: video)
                
                
                HStack {
                    Group {
                        Button {
                            
                            //全景播放
                            if video.videoType == VideoType.wuzhu{
                                player.setPlayModel(.fullPanoSpace)
                                Task {
                                    await openImmersiveSpace(id: VideoType.wuzhu.rawValue)
                                }
                            }
                            
                            //普通播放
                            else{
                                player.prepareVideo(video, playmodel: .fullWindow)
                            }
                            
                        } label: {
                            Label("Play Video", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 420)
                Spacer()
            }
            
            // 预览图
            PreView(video: video)
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(width: 620)
                .cornerRadius(20)
            
        }
        .padding(margins)
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: .preview)
            .environment(PlayController())
            .environment(VideoController())
    }
}
