//
//  PanoramaVideoUI.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/17.


//全景视频操控台

import SwiftUI

struct PanoramaVideoUI: View {
    @Environment(ViewModel.self) private var model
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .center) {
                Text("The Panorama Video")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .padding(.top)

                Divider()
                    .padding([.leading, .trailing])

                Button {
                    Task {
                        if model.isShowingPanoramaVideo {
                            await dismissImmersiveSpace()
                        } else {
                            await openImmersiveSpace(id: VideoType.wuzhu.rawValue)
                        }
                    }
                } label: {
                    if model.isShowingPanoramaVideo {
                        Label(
                            "Exit the System",
                            systemImage: "arrow.down.right.and.arrow.up.left")
                    } else {
                        Text("Enter the System")
                    }
                }
                //.buttonStyle(.borderless)
                .padding(.bottom)
            }
            .frame(width: 400)
            .glassBackgroundEffect(in: .rect(cornerRadius: 40))
            .shadow(color: .white.opacity(0.5), radius: 10, x: 0.0, y: 10.0)
        }
        .padding([.leading, .trailing])
    }

}

#Preview {
    PanoramaVideoUI()
        .environment(ViewModel())
}
