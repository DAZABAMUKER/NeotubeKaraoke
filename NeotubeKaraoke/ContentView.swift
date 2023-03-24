//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//

import SwiftUI
//커스텀 텝바를 위한 enum
enum TabIndex {
    case Home
    case Setting
    case PlayList
}
// 메인 뷰
struct ContentView: View {
    
    @State var vidFull = false
    @State var tabIndex: TabIndex = .Home
    @State var videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false))
    @State var reloads = false
    @State var closes = false
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false
    @State var videoOrder: Int = 0
    
    // 텝이 변할 때 마다 텝바 아이템의 색을 변경하는 함수
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
    
    // 원이 이동하면서 해당 탭이 선택되었음을 알림
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
    
    // 선택된 탭바 아이템을 총괄하여 적용시켜주는 함수
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
    
    //MARK: - 뷰
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                TabView(selection: $tabIndex) {
                    searcher( videoPlay: $videoPlay, reloads: $reloads, tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd, videoOrder: $videoOrder)
                        .toolbar(.hidden, for: .tabBar)
                        .tag(TabIndex.Home)
                    PlayListView(nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, videoOrder: $videoOrder)
                        .tag(TabIndex.PlayList)
                    
                    SettingView()
                        .tag(TabIndex.Setting)
                    
                }
                //탭뷰 위에 플레이어화면을 올려줌
                VStack{
                    ZStack{
                        // 제생중이던 비디오가 종료되면 다음 동영상으로 넘어가도록해줌
                        if self.vidEnd {
                            VStack{}.onAppear(){
                                if nowPlayList.count - 1 > videoOrder {
                                    videoPlay = VideoPlay(videoId: nowPlayList[videoOrder + 1].videoId, vidFull: $vidFull, vidEnd: $vidEnd)
                                    videoOrder += 1
                                    reloads = true
                                    print("리로드")
                                }
                            }
                        }
                        // 플레이어를 새로 그리기 위해 시간 텀이 필요
                        if reloads {
                            Text("Loading...\n")
                                .frame(width: geometry.size.width, height: 60)
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                        self.reloads = false
                                    }
                                }
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                            
                            // 플레이어 뷰 첫 화면
                        } else if videoPlay.videoId == "nil" && !reloads {
                            Text("부르실  노래를  선곡해주세요 *^^*\n")
                            //.bold()
                                .frame(width: geometry.size.width, height: 60)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                        } else {
                            //찐 플레이어 뷰
                            videoPlay
                        }
                    }
                    .frame(height: vidFull ? geometry.size.height : 60)
                    .animation(.easeInOut(duration: 0.5), value: vidFull)
                    //.edgesIgnoringSafeArea(.top)
                    Spacer()
                        .frame(height: self.vidFull ? 0 : 50)
                }
                if !vidFull {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
