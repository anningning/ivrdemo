//
//  ViewModel.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI

/// The data that the app uses to configure its views.
@Observable
class ViewModel {
    
    let ScreenWidth: CGFloat = 1400
    let ScreenHeight: CGFloat = 700
    
    var titleText: String = ""
    var isTitleFinished: Bool = false
    var finalTitle: String = "IQIYI"
    
    //是否播放全景视频中
    var isShowingPanoramaVideo: Bool = false
    
    //是否展示3D模型中
    var isShowing3Dmodel: Bool = false

}
