//
//  VideoCardView.swift
//  IvrDemo
//
//  Created by 安小宁 on 2023/11/10.
//

import SwiftUI


/// A user can select a video card to view the video details.
struct VideoCardView: View {
    
    let video: VideoInfo
    
    
    //海报图宽高
    let cardImageW: CGFloat = 240
    let cardImageH: CGFloat = 360
    
    //card的宽度
    let cardW: CGFloat = 260
    
    init(video: VideoInfo) {
        self.video = video
    }
    
    var body: some View {
        VStack {
            
            //海报图
            Image(video.portraitImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 360)
                .cornerRadius(14)
                .padding([.top, .leading, .trailing], 10.0)
                .padding([.bottom], 8)
            
            VStack(alignment: .leading) {
                
                //片名
                Text(video.title)
                    .font(.system(size: 26))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.black)
                    .frame(width: 240.0, height: 28.0)
                    

                //简述
                Text(video.shortdes)
                    .fontWeight(.regular)
                    .foregroundColor(Color(hex: "ffffffDE"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 6.0)
                
                // 影片特色: {3D} {全景} {30集全}
                HStack {
                    ForEach(video.info.features, id: \.self) {
                        Text($0)
                            .fontWeight(/*@START_MENU_TOKEN@*/.medium/*@END_MENU_TOKEN@*/)
                            .fixedSize()
                            .font(.system(size: 14))
                            .padding([.leading, .trailing], 6)
                            .padding(.vertical, 2.0)
                            .background(RoundedRectangle(cornerRadius: 6).stroke())
                            .foregroundStyle(.secondary)
                        
                    }
                }
            }
            
            .padding(.leading, 20)
            .padding(.bottom, 28.0)
        }
        .background(.thinMaterial)
        .frame(width: cardW) //这里不要限定height，可能会出现card上下边会被切割的情况
        .shadow(radius: 4)
        .hoverEffect()
        .cornerRadius(20)
    }
}

#Preview("VideoCardView") {
    VideoCardView(video: .preview)
}
extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hexString.count == 6 {
            hexString += "FF"
        }

        var rgbaValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbaValue)

        let red = Double((rgbaValue & 0xFF000000) >> 24) / 255.0
        let green = Double((rgbaValue & 0x00FF0000) >> 16) / 255.0
        let blue = Double((rgbaValue & 0x0000FF00) >> 8) / 255.0
        let alpha = Double(rgbaValue & 0x000000FF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
