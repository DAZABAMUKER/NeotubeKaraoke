//
//  VideoPlay.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/14.
//

import SwiftUI
import AVKit

struct VideoPlay: View {
    @State var player = AVPlayer()
    var videoId: String = ""
    
    init(videoId: String = "fSlqTX39CMM") {
        self.videoId = videoId
    }
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VideoPlayer(player: player)
            .frame(width: 400, height: 300, alignment: .center)
            .onAppear() {
                extractVideos(from: videoId) { (dic) -> (Void) in
                    print(dic)
                    //player = AVPlayer(url: URL(string: dic.values.first!)!)
                }
                //player = AVPlayer(url:URL(string: "https://www.youtube.com/watch?v=\(videoId)")!)
            }
        
    }
}

struct VideoPlay_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlay()
    }
}
