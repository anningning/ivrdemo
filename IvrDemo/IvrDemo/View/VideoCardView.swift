//
//  VideoCardView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI


/// A user can select a video card to view the video details.
struct VideoCardView: View {
    
    let video: VideoInfo
    
    
    //海报图宽高
    let cardImageW: CGFloat = 242
    let cardImageH: CGFloat = 363
    
    //card的宽度
    let cardW: CGFloat = 263
    
    init(video: VideoInfo) {
        self.video = video
    }
    
    var body: some View {
        VStack {
            
            //海报图
            Image(video.portraitImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: cardImageW, height: cardImageH)
                .cornerRadius(14)
                .padding([.top, .leading, .trailing], 10.0)
                
            VStack(alignment: .leading) {
                Text(video.title)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)

                Text(video.shortdes)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    // 影片特色文案框
                    FeaturesView(features: video.info.features)
                }
            }
            .padding(12.0)
        }
        .background(.thinMaterial)
        .frame(width: cardW) //这里不要限定height，可能会出现card上下边会被切割的情况
        .shadow(radius: 5)
        .hoverEffect()
        .cornerRadius(14)
    }
}

#Preview("VideoCardView") {
    VideoCardView(video: .preview)
}
