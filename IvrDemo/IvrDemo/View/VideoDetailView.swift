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
                
                VStack(alignment: .leading) {
                    
                    //片名
                    Text(video.title)
                        .font(.title)
                        .padding(.bottom, 4)
                    
//                    InfoLineView(duration: video.info.duration)
//                        .padding([.bottom], 4)
                    
                    // 影片功能特色
                    FeaturesView(features: video.info.features)
                        .padding(.bottom, 4)
                    
                    // 详情描述
                    Text(video.description)
                        .font(.headline)
                        .padding(.bottom, 12)
                    
                    // 演员信息
                    RoleView(people: video.info.stars)
                        .padding(.top, 1)
                }
                
                
                
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
            .padding(.leading, 30.0)
            
            // 预览图
            PreView(video: video)
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(width: 620)
                .cornerRadius(20)
            
        }
        .padding(margins)
    }
}

/// 时长信息
struct InfoLineView: View {
    let duration: String
    var body: some View {
        HStack {
            Text("\(duration)")
                .font(.subheadline.weight(.medium))
        }
    }
}

/// 影片特色UI
struct FeaturesView: View {
    let features: [String]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(features, id: \.self) {
                Text($0)
                    .fixedSize()
                    .font(.caption2.weight(.bold))
                    .padding([.leading, .trailing], 4)
                    .padding([.top, .bottom], 4)
                    .background(RoundedRectangle(cornerRadius: 5).stroke())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 演员UI
struct RoleView: View {
    let people: [String]
    var body: some View {
        VStack(alignment: .leading) {
            Text(people.formatted())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: .preview)
            .environment(PlayController())
            .environment(VideoController())
    }
}
