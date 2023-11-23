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
    
    // MARK: - Navigation
    var titleText: String = ""
    var isTitleFinished: Bool = false
    var finalTitle: String = "IQIYI"
    
    //是否播放全景视频中
    var isShowingPanoramaVideo: Bool = false
    
    //是否展示3D模型中
    var isShowing3Dmodel: Bool = false

}
