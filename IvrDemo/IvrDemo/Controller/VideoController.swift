//
//  VideoController.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
// VideoInfo的管理器，用于加载管理Video等数据。

import Foundation
import SwiftUI
import Observation

@Observable class VideoController {
    
    private(set) var videos = [VideoInfo]()
    
    
    init() {
        videos = loadVideos()
    }
    
    /// Loads the video content for the app.
    private func loadVideos() -> [VideoInfo] {
        let filename = "Videos.json"
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        return load(url)
    }
    
    
    private func load<T: Decodable>(_ url: URL, as type: T.Type = T.self) -> T {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            fatalError("Couldn't load \(url.path):\n\(error)")
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            //.convertFromSnakeCase 选项会自动将 JSON 中的下划线风格（例如 image_name）转换为 Swift 语言中的驼峰风格（例如 imageName）
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(url.lastPathComponent) as \(T.self):\n\(error)")
        }
    }
}
