//
//  PlayerView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
// 播放页面

import SwiftUI

/// Constants that define the style of controls a player presents.
enum PlayerControlsStyle {
    /// A value that indicates to use the system interface that AVPlayerViewController provides.
    case system
    /// A value that indicates to use compact controls that display a play/pause button.
    case custom
}

/// A view that presents the video player.
struct PlayerView: View {
    
    let controlsStyle: PlayerControlsStyle

    @Environment(PlayController.self) private var model
    
    /// Creates a new player view.
    init(controlsStyle: PlayerControlsStyle = .system) {
        self.controlsStyle = controlsStyle
    }
    
    var body: some View {
        switch controlsStyle {
        case .system:
            SystemPlayerView()
               
        case .custom:
            InlinePlayerView()
        }
    }
}


#Preview {
    PlayerView()
}
