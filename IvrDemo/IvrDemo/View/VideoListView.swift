//
//  VideoListView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
//视频card列表

import SwiftUI

/// A view the presents a horizontally scrollable list of video cards.
struct VideoListView: View {
    
    typealias SelectionAction = (VideoInfo) -> Void

    private let videos: [VideoInfo]
    private let cardSpacing: Double


    init(videos: [VideoInfo], cardSpacing: Double) {
        self.videos = videos
        self.cardSpacing = cardSpacing
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(videos) { video in
                        Group {
                            
                            NavigationLink(value: video) {
                                
                                //每一个VideoCard
                                VideoCardView(video: video)
                            }
                        }
                    }
                }
                .buttonStyle(buttonStyle)
                
                .padding([.top, .bottom], 0)
                .padding([.leading, .trailing], margins)
                
            }
        }
    }
    
    
    var buttonStyle: some PrimitiveButtonStyle {
        .plain
    }
    
    var margins: Double {
        valueFor(visionOS: 30)
    }
}

#Preview("Full") {
    NavigationStack {
        VideoListView(videos: .all, cardSpacing: 30)
            .frame(height: 580)
    }
}
