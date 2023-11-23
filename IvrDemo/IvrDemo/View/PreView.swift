//
//  PreView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
//预告片

import SwiftUI

struct PreView: View {
    
    let video: VideoInfo
    
    @State private var isPosterVisible = true
    @Environment(PlayController.self) private var model
    
    var body: some View {
        if isPosterVisible {
            Button {
                // Loads the video for inline playback.
                model.prepareVideo(video)
                withAnimation {
                    isPosterVisible = false
                }
            } label: {
                PrePosterView(video: video)
            }
            .buttonStyle(.plain)
        } else {
            PlayerView(controlsStyle: .custom)
                .onAppear {
                    if model.shouldAutoPlay {
                        model.play()
                    }
                }
        }

    }
}

/// 播放按钮UI
private struct PrePosterView: View {
    
    let video: VideoInfo
    
    var body: some View {
        ZStack {
            Image(video.landscapeImageName)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 2) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24.0))
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(.circle)
                Text("Preview")
                    .font(.title3)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            }
        }
    }
}

#Preview("Preview View") {
    PreView(video: .preview)
        .environment(PlayController())
}

#Preview("PrePosterView View") {
    PrePosterView(video: .preview)
}

