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
    
    //圆角
    let cornerRadius = 14.0
    
    //海报图宽高
    let cardImageW: CGFloat = 242
    let cardImageH: CGFloat = 363
    
    //card的宽度
    let cardW: CGFloat = 263
    
    init(video: VideoInfo) {
        self.video = video
    }
    
    //海报图
    var cardImage: some View {
        Image(video.portraitImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: cardImageW, height: cardImageH)
            .cornerRadius(cornerRadius)
            .padding([.top, .leading, .trailing], 10.0)
    }

    var body: some View {
        VStack {
            
            cardImage
                
            VStack(alignment: .leading) {
                Text(video.title)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)

                Text(video.shortdes)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    FeaturesView(features: video.info.features)
                }
            }
            .padding(12.0)
        }
        .background(.thinMaterial)
        .frame(width: cardW) //这里不要限定height，可能会出现card上下边会被切割的情况
        .shadow(radius: 5)
        .hoverEffect()
        .cornerRadius(cornerRadius)
    }
}

#Preview("VideoCardView") {
    VideoCardView(video: .preview)
}
