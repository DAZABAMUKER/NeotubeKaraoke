//
//  listView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/12.
//
import SwiftUI

struct ListView: View {
    
    private var Video: LikeVideo
    private var image: UIImageView!
    init(Video: LikeVideo ) {
        self.Video = Video
    }
    
    var body: some View {
        GeometryReader{ geometry in
            HStack() {
                AsyncImage(url: URL(string: Video.thumnail)){ image in
                    image.resizable()
                } placeholder: {
                    ZStack{
                        Rectangle()
                            .fill(LinearGradient(colors: [
                                Color.pink,
                                Color(red: 253 / 255, green: 138 / 255, blue: 138 / 255)
                            ], startPoint: .top, endPoint: .bottom))
                            .aspectRatio(16/9, contentMode: .fill)
                            .scaledToFit()
                            .cornerRadius(8)
                            .frame(height: 60)
                        Image(systemName: "music.note.tv")
                            .resizable()
                            .frame(height: 30)
                            .aspectRatio(0.92, contentMode: .fit)
                            .foregroundColor(Color.white)
                    }.padding(.leading,7)
                }
                .aspectRatio(16/12, contentMode: .fit)
                .frame(height: 90)
                .padding(.leading, -13)
                .padding(.bottom, 10)
                VStack(alignment: .leading) {
                    LinearGradient(colors: [
                        Color(red: 1, green: 112 / 255.0, blue: 0),
                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                    ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                    )
                    .mask(alignment: .leading) {
                        Text(Video.title)
                            .bold()
                            .lineLimit(2)
                            .frame(height: 45)
                        //.background(Color.green)
                            //.foregroundColor(.orange)
                            .font(.system(size: 18))
                    }
                    Text(Video.channelTitle)
                        .lineLimit(1)
                        //.background(.blue)
                        //.bold()
                        .font(.system(size: 13))
                        .padding(.top, 0)
                    Spacer()
                }
                .foregroundColor(Color.white)
                Spacer()
            }
            .frame(width: geometry.size.width, height: 80)
            //.background(.black)
        }
    }
}

struct previewPList : PreviewProvider {
    static var previews: some View {
        ListView(Video: LikeVideo(videoId: "rdpBZ5_b48g", title: "Wake Me UP", thumnail: "", channelTitle: "Green Day"))
    }
}
