//
//  ViewModifier.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI

extension View {
    /// Makes the specified text appear one letter at a time.
    func typeText(
        text: Binding<String>,
        finalText: String,
        isFinished: Binding<Bool>,
        cursor: String = "|",
        isAnimated: Bool = true
    ) -> some View {
        self.modifier(
            TypeTextModifier(
                text: text,
                finalText: finalText,
                isFinished: isFinished,
                cursor: cursor,
                isAnimated: isAnimated
            )
        )
    }
}


extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}


private struct TypeTextModifier: ViewModifier {
    @Binding var text: String
    var finalText: String
    @Binding var isFinished: Bool
    var cursor: String
    var isAnimated: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isAnimated == false {
                    text = finalText
                    isFinished = true
                }
            }
            .task {
                guard isAnimated else { return }

                // Blink the cursor a few times.
                for _ in 1 ... 2 {
                    text = cursor
                    try? await Task.sleep(for: .milliseconds(300))
                    text = ""
                    try? await Task.sleep(for: .milliseconds(200))
                }

                // Type out the title.
                for index in finalText.indices {
                    text = String(finalText.prefix(through: index)) + cursor
                    let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * 100
                    try? await Task.sleep(for: .milliseconds(milliseconds))
                }

                // Wrap up the title sequence.
                try? await Task.sleep(for: .milliseconds(400))
                text = finalText
                isFinished = true
            }
    }
}

extension View {

    func updateImmersionOnChange(of path: Binding<[VideoInfo]>, isPresentingSpace: Binding<Bool>) -> some View {
        self.modifier(ImmersiveSpacePresentationModifier(navigationPath: path, isPresentingSpace: isPresentingSpace))
    }

    
    // Only used in iOS and tvOS for full-screen modal presentation.
    func fullScreenCoverPlayer(player: PlayController) -> some View {
        self.modifier(FullScreenCoverModifier(player: player))
    }
}

private struct ImmersiveSpacePresentationModifier: ViewModifier {
    
    @Environment(\.openImmersiveSpace) private var openSpace
    @Environment(\.dismissImmersiveSpace) private var dismissSpace
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    /// The current phase for the scene, which can be active, inactive, or background.
    @Environment(\.scenePhase) private var scenePhase
    
    @Binding var navigationPath: [VideoInfo]
    @Binding var isPresentingSpace: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: navigationPath) {
                Task {
                    // The selection path becomes empty when the user returns to the main library window.
                    if navigationPath.isEmpty {
                        
                        if isPresentingSpace {
                            await dismissSpace()
                            isPresentingSpace = false
                        }
                    } else {

                        guard !isPresentingSpace else { return }
                        // The navigationPath has one video, or is empty.
                        guard let video = navigationPath.first else { fatalError() }
                        
                        
                        //全景此时不进入沉浸空间
                        if video.videoType == VideoType.wuzhu {
                            return
                        }

                        switch await openSpace(id: video.videoType.rawValue) {
                        case .opened: isPresentingSpace = true
                        default: isPresentingSpace = false
                        }
                        
//                        if video.videoType == VideoType.zongyi {
//                            openWindow(id:"3dmodel")
//                        }

                    }
                }
            }
            // Close the space and unload media when the user backgrounds the app.
            .onChange(of: scenePhase) { _, newPhase in
                if isPresentingSpace, newPhase == .background {
                    Task {
                        await dismissSpace()
                    }
                }
            }
    }
}


private struct FullScreenCoverModifier: ViewModifier {
    
    let player: PlayController
    @State private var isPresentingPlayer = false
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresentingPlayer) {
                SystemPlayerView()
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.reset()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            // Observe the player's presentation property.
            .onChange(of: player.playModel, { _, newPresentation in
                isPresentingPlayer = newPresentation == .fullWindow
            })
    }
}


