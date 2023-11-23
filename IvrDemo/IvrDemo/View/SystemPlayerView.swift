//
//  SystemPlayerView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import AVKit
import SwiftUI

// This view is a SwiftUI wrapper over `AVPlayerViewController`.
struct SystemPlayerView: UIViewControllerRepresentable {

    @Environment(PlayController.self) private var model
    @Environment(VideoController.self) private var library
    

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let controller = model.makePlayerViewController()
        return controller
    }
    
    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        Task { @MainActor in
            
            controller.contextualActions = []
        }
    }

}

