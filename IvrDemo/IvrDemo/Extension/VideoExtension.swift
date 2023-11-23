//
//  VideoExtension.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import Foundation

extension VideoInfo {
    static var preview: VideoInfo {
        VideoController().videos[0]
    }
}

extension Array {
    static var all: [VideoInfo] {
        VideoController().videos
    }
}
