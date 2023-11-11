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
    @Environment(\.colorScheme) var colorScheme
    
    init(Video: LikeVideo ) {
        self.Video = Video
    }
    
    var body: some View {
        GeometryReader{ geometry in
            HStack() {
                ZStack{
                    AsyncImage(url: URL(string: Video.thumbnail)){ image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70/9*16, height: 70*4/3)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                                    .size(width: 70/9*16, height: 70)
                                    .offset(x: 0, y: 70/6)
                                       
                            )
                            //.border(.red)
                            .frame(width: 70/9*16, height: 70)
                            //.border(.green)
                            //.shadow(color: .black,radius: 10, x: 0, y: 10)
                    } placeholder: {
                        ZStack{
                            Rectangle()
                                .foregroundStyle(Color(red: 1, green: 112 / 255.0, blue: 0))
                                .aspectRatio(16/9, contentMode: .fill)
                                .scaledToFit()
                                .cornerRadius(8)
                                .frame(height: 60)
                            Image(systemName: "music.note.tv")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .foregroundColor(Color.white)
                        }
                        .frame(height: 90)
                        .padding(.leading,7)
                    }
                    .aspectRatio(16/12, contentMode: .fit)
                    
                    //.padding(.leading, -13)
                    .padding(.bottom, 10)
                    HStack{
                        Spacer()
                        VStack(spacing: 0){
                            Spacer()
                            Text(Video.runTime)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .lineLimit(1)
                                .background(.black.opacity(0.6))
                        }
                    }
                    .frame(width: 120, height: 50)
                        .padding(.leading, -13)
                }
                VStack(alignment: .leading) {
                    Text(Video.title)
                        .bold()
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 45)
                    //.background(Color.green)
                        //.foregroundColor(.orange)
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                    Text(Video.channelTitle)
                        .lineLimit(1)
                        //.background(.blue)
                        //.bold()
                        .font(.system(size: 13))
                        .padding(.top, 0)
                    Spacer()
                }
                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                Spacer()
            }
            .frame(width: geometry.size.width, height: 80)
            //.background(.black)
        }
    }
}

struct previewPList : PreviewProvider {
    static var previews: some View {
        ListView(Video: LikeVideo(videoId: "rdpBZ5_b48g", title: "Wake Me UP", thumbnail: "https://i.ytimg.com/vi/vRiFFMBLGAc/hqdefault.jpg", channelTitle: "Green Day", runTime: "3:50"))
    }
}
