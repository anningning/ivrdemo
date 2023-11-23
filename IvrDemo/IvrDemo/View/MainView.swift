//
//  MainView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI

/// The text that displays the app's title.
private struct TitleText: View {
    var title: String
    var body: some View {
        Text(title)
            .monospaced()
            .font(.system(size: 60, weight: .bold))
    }
}

// App主页
struct MainView: View {
    
    @Environment(ViewModel.self) private var model
    @Environment(VideoController.self) private var library
    
    /// video
    @Binding private var navigationPath: [VideoInfo]
    
    /// A path that represents the user's content navigation path.
    @Binding private var isPresentingSpace: Bool
    
    /// Creates a `LibraryView` with a binding to a selection path.
    ///
    /// The default value is an empty binding.
    init(path: Binding<[VideoInfo]>, isPresentingSpace: Binding<Bool> = .constant(false)) {
        _navigationPath = path
        _isPresentingSpace = isPresentingSpace
    }
    
    var body: some View {
        @Bindable var model = model
        
        ZStack(){

            NavigationStack(path: $navigationPath) {
                
                // scrolling view.
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: verticalPadding) {
                        
                        //顶部栏
                        HStack {

                            //左侧图标
                            Image("avpicon")
                                .resizable()
                                .padding(.leading, 25.0)
                                .scaledToFit()
                                .frame(height: TopIconHeight)

                            Spacer()
                            
                            // logo
                            Image("iqiyi_logo")
                                .resizable()
                                .scaledToFit()
                                .padding(.trailing, outerPadding)
                                .padding(.top, 8)
                                .frame(height: TopIconHeight)
                        }
                        
                        // Card列表
                        VideoListView(videos: library.videos,
                                      cardSpacing: horizontalSpacing)
                        
                    }
                    .opacity(model.isTitleFinished ? 1 : 0)
                    .padding([.top, .bottom], verticalPadding)
                    .navigationDestination(for: VideoInfo.self) { video in
                        
                        // 影片详情页
                        VideoDetailView(video: video)
                            //.navigationTitle(video.title)
                            //.navigationBarHidden(true)
                        
                    }
                }
            }
            .typeText(
                text: $model.titleText,
                finalText: model.finalTitle,
                isFinished: $model.isTitleFinished,
                isAnimated: !model.isTitleFinished)
            .updateImmersionOnChange(of: $navigationPath, isPresentingSpace: $isPresentingSpace)
            
            //启动Splash
            TitleText(title: model.finalTitle)
                .padding(.horizontal, 70)
                .hidden()
                .overlay(alignment: .leading) {
                    TitleText(title: model.titleText)
                        .padding(.leading, 70)
                }
                .opacity(model.isTitleFinished ? 0 : 1)
        }
        
    }

    // MARK: - Platform-specific metrics.
    
    /// The vertical padding between views.
    var verticalPadding: Double {
        valueFor(visionOS: 30)
    }
    
    var outerPadding: Double {
        valueFor(visionOS: 30)
    }
    
    var horizontalSpacing: Double {
        valueFor(visionOS: 30)
    }
    
    var TopIconHeight: Double {
        valueFor(visionOS: 40)
    }

}

#Preview {
    NavigationStack {
        MainView(path: .constant([]))
            .environment(ViewModel())
            .environment(VideoController())
    }
}
