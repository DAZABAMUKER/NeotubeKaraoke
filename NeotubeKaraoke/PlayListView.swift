//
//  PlayListView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/07.
//

import SwiftUI

struct PlayListView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                LinearGradient(colors: [
                    Color(red: 1, green: 112 / 255.0, blue: 0),
                    Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                ],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                )
                .frame(height: 60)
                .mask(alignment: .leading) {
                    Text("Playlist")
                        .italic()
                        .bold()
                        .font(.largeTitle)
                        .padding(.horizontal, 20)
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "plus.app")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(.horizontal ,20)
                        .foregroundColor(.orange)
                }

            }
            .background(.indigo.opacity(0.3))
            Text("Recent")
                .bold()
                .font(.title)
            VStack{
                ZStack{
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(20)
                        .background(.green)
                        //.opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .rotationEffect(.degrees(-15))
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(20)
                        .background(.orange)
                        //.opacity(0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .rotationEffect(.degrees(-5))
                        //.padding(20)
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(20)
                        .background(.linearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .rotationEffect(.degrees(10))
                        .padding(20)
                }
                Text("재생목록1")
            }
            List{
                ForEach(0..<10) { video in
                    //TableCell(Video: video)
                    Text("기본 재생목록")
                }
            }
            .listStyle(.plain)
        }
        .preferredColorScheme(.dark)
    }
}

struct PlayListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayListView()
    }
}

struct LikeVideo {
    let videoId: String
    let title: String
    let thumnail: String
    let channelTitle: String
}
