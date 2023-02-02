//
//  testView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/02.
//

import SwiftUI
import AVKit
import YoutubeDL
import PythonKit

struct testView: View {
    @State var que = false
    @State var player = AVPlayer()
    
    @State var indeterminateProgressKey: String?
    @State var youtubeDL: YoutubeDL?
    @State var info: Info?
    @State var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            
            //extractInfo(url: url)
        }
    }
    @State var Urls = URL(string: "https://dazabamuker.tistory.com")!
    //let ydl = try? YoutubeDL()
    
    var videoId: String = ""
    init(videoId: String = "") {
        self.videoId = videoId
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
