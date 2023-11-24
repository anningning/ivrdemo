//
//  VideoInfo.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
// 基础的Video数据结构，可序列化，对应Videos.json。

import Foundation
import UIKit

enum VideoType: String, CaseIterable, Identifiable, Codable {
    
    case canglan
    case beizhe
    case yuexia
    case baishe
    case wuzhu

    
    var id: Self { self }
    
    /// The environment image to load.
    var imageName: String { "\(rawValue)_scene" }
    
    /// A number of degrees to rotate the 360 "destination" image to provide the best initial view.
    var rotationDegrees: Double {
        switch self {
        case .canglan: 55
        case .beizhe: -55
        case .yuexia: 0
        case .wuzhu: 0
        case .baishe: -55
        }
    }
}

struct VideoInfo: Identifiable, Hashable, Codable {
    
    /// The unique identifier of the item.
    let id: Int
    
    let urltype: String
    let url: URL
    
    /// 名称
    let title: String
    
    /// 播放类型
    var videoType: VideoType
    
    /// 描述
    let shortdes: String
    let description: String
    
    /// 竖图
    var portraitImageName: String { "\(videoType.rawValue)_port" }
    
    /// 横图
    var landscapeImageName: String { "\(videoType.rawValue)_land" }
    
    /// 图片地址
    var imageData: Data {
        UIImage(named: landscapeImageName)?.pngData() ?? Data()
    }
    /// 子信息
    let info: Info
    
    /// URL获取
    var resolvedURL: URL {
        if urltype == "local"{
            return Bundle.main.url(forResource: videoType.rawValue, withExtension: "mov")!
        }
        
        if url.scheme == nil {
            return URL(fileURLWithPath: "\(Bundle.main.bundlePath)/\(url.path)")
        }
        return url
    }

    
    //演员头像
    func getActorImageName(index: Int) -> String {
        return "\(videoType.rawValue)_s\(index+1)" 
    }
    
    
    /// 序列化VideoInfo的Info
    struct Info: Hashable, Codable {
        var releaseYear: String
        var contentRating: String
        var duration: String
        var features: [String]
        var stars: [String]
        var roles: [String]
        
        var releaseDate: Date {
            var components = DateComponents()
            components.year = Int(releaseYear)
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(from: components)!
        }
    }
}
