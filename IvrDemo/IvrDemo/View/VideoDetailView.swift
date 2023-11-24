//
//  VideoDetailView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
//视频详情页

import SwiftUI

struct VideoDetailView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    let video: VideoInfo
    @Environment(PlayController.self) private var player
    @Environment(VideoController.self) private var library
    

    var body: some View {
        HStack(alignment: .top) {
            
            // 详情信息
            VStack(alignment: .leading) {
                
                //返回按钮
                Button(action: {
                    self.mode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .padding(.bottom, 20)
                
                //片名
                Text(video.title)
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                
                // 影片特色: {3D} {全景} {30集全}
                HStack(spacing: 8) {
                    ForEach(video.info.features, id: \.self) {
                        Text($0)
                            .fixedSize()
                            .font(.title2.weight(.bold))
                            .padding([.leading, .trailing], 4)
                            .padding([.top, .bottom], 4)
                            .background(RoundedRectangle(cornerRadius: 5).stroke())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 10)
                
                // 详情描述
                Text(video.description)
                    .font(.headline)
                    .padding(.bottom, 20)
                
                // 演员信息
                HStack(spacing: 10) {
                    ForEach(0..<video.info.stars.count, id: \.self) { index in
                        VStack(alignment: .center, spacing: 5) {
                            
                            // 演员头像
                            Image(video.getActorImageName(index: index))
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                            
                            //演员名字
                            Text(video.info.stars[index])
                                .font(.headline)
                            
                            //角色名字
                            Text(video.info.roles[index])
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }.padding(.bottom, 20)
                
                HStack(alignment: .center) {
                    //播放按钮
                    Button {
                        
                        //全景播放事件
                        if video.videoType == VideoType.wuzhu{
                            player.setPlayModel(.fullPanoSpace)
                            Task {
                                await openImmersiveSpace(id: VideoType.wuzhu.rawValue)
                            }
                        }
                        
                        //普通播放事件
                        else{
                            player.prepareVideo(video, playmodel: .fullWindow)
                        }
                        
                    } label: {
                        Label("点击播放", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .frame(width: 250.0, height: 100.0)
                }
                
            }
            .padding([.leading, .top], 35.0)
            
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                
                //背景图
                
                GeometryReader { geometry in
                        Image(video.landscapeImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                    }

                //logo
                Image("iqiyi_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding([.top, .trailing], 35.0)
            }

        }
        .background(Color(hex: Int(video.bgColor, radix: 16) ?? 0, alpha: 0.64))
    

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


#Preview {
    NavigationStack {
        VideoDetailView(video: .preview)
            .environment(PlayController())
            .environment(VideoController())
    }
}
