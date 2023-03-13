//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//

import SwiftUI

enum TabIndex {
    case Home
    case Setting
    case PlayList
}

struct ContentView: View {
    
    @State var vidFull = false
    @State var tabIndex: TabIndex = .Home
    @State var videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false))
    @State var reloads = false
    @State var closes = false
    @State var anime = true
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false
    //@StateObject var audioManager = AudioManager(file: URL(string: "https://www.naver.com")!, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 1.0)
    
    func changeColor(tabIndex: TabIndex) -> Color{
        switch tabIndex {
        case .Home:
            return Color.red
        case .Setting:
            return Color.white
        case .PlayList:
            return Color.green
        }
    }
    
    func CircleOffset(tabIndex: TabIndex, geometry: GeometryProxy) -> CGFloat {
        switch tabIndex {
        case .PlayList:
            return -geometry.size.width / 3
        case .Home:
            return 0
        case .Setting:
            return geometry.size.width / 3
        }
    }
    
    func TabButtonSel(tabIndex: TabIndex, img: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            print("click")
            self.tabIndex = tabIndex
        }) {
            Image(systemName: img)
                .font(.system(size: 30))
                .scaleEffect(self.tabIndex == tabIndex ? 1.7 : 1.0)
                .foregroundColor(self.tabIndex == tabIndex ? changeColor(tabIndex: tabIndex) : Color.gray)
                .frame(width: geometry.size.width / 3, height: 50)
                .offset(y: self.tabIndex == tabIndex ? -5 : 0)
                .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
        }
        .background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                TabView(selection: $tabIndex) {
                    searcher( videoPlay: $videoPlay, reloads: $reloads, tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd)
                        .toolbar(.hidden, for: .tabBar)
                        .tag(TabIndex.Home)
                    PlayListView(nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd)
                        .tag(TabIndex.PlayList)
                    
                    SettingView()
                        .tag(TabIndex.Setting)
                        
                }
                VStack{
                    ZStack{
                        if reloads {
                            Text("Loading...")
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                        self.reloads = false
                                    }
                                }
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                        } else if videoPlay.videoId == "nil" {
                            Text("부르실  노래를  선곡해주세요 *^^*")
                                //.bold()
                                .font(.title2)
                                .frame(width: geometry.size.width, height: 60)
                                .offset(x: anime ? -Double(geometry.size.width) : Double(geometry.size.width))
                                .animation(.easeInOut(duration: 4).repeatForever(), value: anime)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                                .onAppear(){
                                    self.anime = false
                                }
                        } else {
                            videoPlay
                        }
                        VStack{
                            Spacer()
                            VStack{}
                                .frame(width: geometry.size.width, height: 60)
                                .background(content: {
                                    ZStack{
                                        Image(systemName: "chevron.compact.down").resizable().scaledToFit().opacity(self.vidFull ? 0.9 : 0.01).frame(height: 10)
                                        Color.black.opacity(0.01).frame(width: geometry.size.width, height: 60)
                                    }
                                })
                                .onTapGesture {
                                    self.vidFull.toggle()
                                }
                        }
                    }
                    .onAppear(){
                        //videoPlay = VideoPlay(videoId: "Qj1Gt5z4zxo", vidFull: $vidFull)
                    }
                    .frame(height: vidFull ? 700 : 60)
                    .animation(.easeInOut(duration: 0.5), value: vidFull)
                    Spacer()
                        .frame(height: 50)
                }
                Circle()
                    .frame(width: 100)
                    .offset(x: self.CircleOffset(tabIndex: tabIndex, geometry: geometry), y: 25)
                    .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                    .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
                    .shadow(radius: 10)
                HStack(spacing: 0) {
                    TabButtonSel(tabIndex: .PlayList, img: "music.mic", geometry: geometry)
                    TabButtonSel(tabIndex: .Home, img: "magnifyingglass", geometry: geometry)
                    TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                    
                }
                .preferredColorScheme(.light)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
