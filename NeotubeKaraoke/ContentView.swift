//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//
import GoogleMobileAds
import SwiftUI
//커스텀 텝바를 위한 enum
enum TabIndex {
    case Home
    case Setting
    case PlayList
}
// 메인 뷰
struct ContentView: View {
    
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    private let adCoordinator = AdCoordinator()
    @State var isLandscape = false
    @State var searching: Bool = false
    @State var inputVal: String = ""
    @State var vidFull = false
    @State var tabIndex: TabIndex = .Home
    @State var videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false), isReady: .constant(true), resolution: .constant(.basic), isLandscape: .constant(false))
    @State var reloads = false
    @State var closes = false
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false
    @State var videoOrder: Int = 0
    @State var isReady: Bool = true
    @State var resolution: Resolution = .basic
    @State var once = false
    @State var adCount: Int = 1 {
        didSet{
            DispatchQueue.global(qos: .background).sync {
                if self.adCount % 2 == 0 {
                    print("광고중")
                    print(self.adCount)
                    adCoordinator.loadAd()
                    adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
                } else {
                    if !once {
                        adCoordinator.loadAd()
                        self.once = true
                    }
                }
            }
        }
    }
    
    private let loading: LocalizedStringKey = "Loading...\n"
    private let selSong: LocalizedStringKey = "Please select your song to sing -^^-\n"
    
    func rotateLandscape() {
        if !isLandscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.isLandscape = true
            } else {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.isLandscape = false
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
    }
    
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
                    searcher( videoPlay: $videoPlay, reloads: $reloads, tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, searching: $searching, inputVal: $inputVal, isLandscape: $isLandscape)
                        .toolbar(.hidden, for: .tabBar)
                        .tag(TabIndex.Home)
                    
                    PlayListView(nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, inputVal: $inputVal, searching: $searching, isLandscape: $isLandscape)
                        .tag(TabIndex.PlayList)
                    SettingView(resolution: $resolution)
                        .tag(TabIndex.Setting)
                    
                }
                //탭뷰 위에 플레이어화면을 올려줌
                VStack{
                    ZStack{
                        // 제생중이던 비디오가 종료되면 다음 동영상으로 넘어가도록해줌
                        if UIDevice.current.orientation.isLandscape {
                            VStack{}.onAppear(){
                                isLandscape = true
                            }
                        } else {
                            VStack{}.onAppear(){
                                isLandscape = false
                            }
                        }
                        if searching {
                            VStack{}.onAppear(){
                                self.tabIndex = .Home
                            }
                        }
                        if self.vidEnd {
                            VStack{}.onAppear(){
                                
                                print(vidEnd)
                                if isReady {
                                    if nowPlayList.count - 1 > videoOrder {
                                        vidFull = false
                                        videoOrder += 1
                                        self.isReady = false
                                        videoPlay = VideoPlay(videoId: nowPlayList[videoOrder].videoId, vidFull: $vidFull, vidEnd: self.$vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape)
                                        reloads = true
                                        print("리로드")
                                    } else {
                                        videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false), isReady: .constant(true), resolution: .constant(.basic), isLandscape: $isLandscape)
                                        reloads = true
                                    }
                                }
                            }
                        }
                        // 플레이어를 새로 그리기 위해 시간 텀이 필요
                        if reloads {
                            Text(loading)
                                .frame(width: geometry.size.width, height: 60)
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                                        self.reloads = false
                                        self.adCount += 1
                                    }
                                }
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                            
                            // 플레이어 뷰 첫 화면
                        } else if videoPlay.videoId == "nil" && !reloads {
                            Text(self.selSong)
                            //.bold()
                                .frame(width: geometry.size.width, height: 60)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
//                                .onAppear(){
//                                    adCoordinator.loadAd()
//                                }
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
                VStack{
                    HStack{
                        Button {
                            rotateLandscape()
                        } label: {
                            Image(systemName: isLandscape ? "rotate.right" : "rotate.left")
                                .padding()
                                .tint(.white)
                                .background {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.secondary)
                                }
                            //.padding(.bottom, 55)
                                .padding(.leading, 15)
                                .opacity(vidFull ? isLandscape ? 0.01 : 0.5 : 0.01)
                        }
                        .animation(.easeInOut, value: vidFull)
                        Spacer()
                    }
                    if !vidFull {
                        Spacer()
                    }
                }
            }
            .background {
                // Add the adViewControllerRepresentable to the background so it
                // doesn't influence the placement of other views in the view hierarchy.
                adViewControllerRepresentable
                    .frame(width: .zero, height: .zero)
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

