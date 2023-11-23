//
//  VideoInfoView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI

struct VideoInfoView: View {
    let video: VideoInfo
    var body: some View {
        VStack(alignment: .leading) {
            Text(video.title)
                .font(.title)
                .padding(.bottom, 4)
            InfoLineView(duration: video.info.duration)
                .padding([.bottom], 4)
            FeaturesView(features: video.info.features)
                .padding(.bottom, 4)
            RoleView(role: String(localized: "演员:"), people: video.info.stars)
                .padding(.top, 1)
            Text(video.description)
                .font(.headline)
                .padding(.bottom, 12)
        }
    }
}

/// 时长信息
struct InfoLineView: View {
    let duration: String
    var body: some View {
        HStack {
            Text("\(duration)")
                .font(.subheadline.weight(.medium))
        }
    }
}

/// 影片特色UI
struct FeaturesView: View {
    let features: [String]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(features, id: \.self) {
                Text($0)
                    .fixedSize()
                    .font(.caption2.weight(.bold))
                    .padding([.leading, .trailing], 4)
                    .padding([.top, .bottom], 4)
                    .background(RoundedRectangle(cornerRadius: 5).stroke())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 演员UI
struct RoleView: View {
    let role: String
    let people: [String]
    var body: some View {
        VStack(alignment: .leading) {
            Text(role)
            Text(people.formatted())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VideoInfoView(video: .preview)
        .padding()
        .frame(width: 500, height: 500)
        .background(.gray)
        .previewLayout(.sizeThatFits)
}
