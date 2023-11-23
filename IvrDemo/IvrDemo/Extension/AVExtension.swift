//
//  AVExtension.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//
//处理音视频播放中的中断事件

import AVFoundation

// A simple type that unpacks the relevant values from an AVAudioSession interruption event.
struct InterruptionResult {
    
    let type: AVAudioSession.InterruptionType
    let options: AVAudioSession.InterruptionOptions
    
    init?(_ notification: Notification) {
        // Determine the interruption type and options.
        guard let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType,
              let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {
            return nil
        }
        self.type = type
        self.options = options
    }
}

