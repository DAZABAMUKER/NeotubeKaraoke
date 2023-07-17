//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//
import GoogleMobileAds
import SwiftUI
import MultipeerConnectivity
//커스텀 텝바를 위한 enum
enum TabIndex {
    case Home
    case Setting
    case PlayList
    case chart
    case peer
}
// 메인 뷰
struct ContentView: View {
    
    @AppStorage("micPermission") var micPermission: Bool = UserDefaults.standard.bool(forKey: "micPermission")
    @EnvironmentObject var envPlayer: EnvPlayer
    
    @State var adViewControllerRepresentable = AdViewControllerRepresentable()
    @StateObject var adCoordinator = AdCoordinator()
    @State var isLandscape = false
    @State var searching: Bool = false
    @State var inputVal: String = ""
    @State var vidFull = false
    @State var tabIndex: TabIndex = .Home
    @State var videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false), isReady: .constant(true), resolution: .constant(.basic), isLandscape: .constant(false), score: .constant(0))
    @State var reloads = false
    @State var closes = false
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false
    @State var clickVid = false
    @State var videoOrder: Int = 0
    @State var isReady: Bool = true
    @State var resolution: Resolution = .basic
    @State var once = false
    @State var score: Int = 0
    @State var showScore = false
    @State var recent = [LikeVideo]()
    @State var addVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var nowVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var isNewitem = false
    //@State var connectedPeers = [MCPeerID]()
    
    @State var adCount: Int = 0 {
        didSet{
            if adCount > oldValue {
                DispatchQueue.global(qos: .background).sync {
                    if self.adCount % 2 == 0 {
                        print("광고중")
                        print(self.adCount)
                        //adCoordinator.loadAd()
                        //print(adCoordinator.ad)
                        adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
                    } else {
                        print("홀수")
                        adCoordinator.loadAd()
//                        if !once {
//                            adCoordinator.loadAd()
//                            self.once = true
//                        }
                    }
                }
            }
        }
    }
    
    private let loading: LocalizedStringKey = "Loading...\n"
    private let selSong: LocalizedStringKey = "Please select your song to sing -^^-\n"
    private let newVideoAdded: LocalizedStringKey = "New Video reserved"
    
    func rotateLandscape() {
        if !isLandscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.isLandscape = true
            } else {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = true
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.isLandscape = false
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = false
            }
        }
    }
    
    // 텝이 변할 때 마다 텝바 아이템의 색을 변경하는 함수
    func changeColor(tabIndex: TabIndex) -> Color{
        switch tabIndex {
        case .Home:
            return Color(red: 1, green: 109/255, blue: 96/255)
        case .Setting:
            return Color.white
        case .PlayList:
            return Color(red: 152/255, green: 216/255, blue: 170/255)
        case .chart:
            return Color(red: 247/255, green: 208/255, blue: 96/255)
        case .peer:
            return Color.indigo
        }
    }
    
    // 원이 이동하면서 해당 탭이 선택되었음을 알림
    func CircleOffset(tabIndex: TabIndex, geometry: GeometryProxy) -> CGFloat {
        switch tabIndex {
        case .PlayList:
            return -geometry.size.width * 4 / 10
        case .chart:
            return -geometry.size.width * 2 / 10
        case .Home:
            return 0
        case .peer:
            return geometry.size.width * 2 / 10
        case .Setting:
            return geometry.size.width * 4 / 10
        }
    }
    
    // 선택된 탭바 아이템을 총괄하여 적용시켜주는 함수
    func TabButtonSel(tabIndex: TabIndex, img: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            self.tabIndex = tabIndex
        }) {
            Image(systemName: img)
                .font(.system(size: 30))
                .scaleEffect(self.tabIndex == tabIndex ? 1.7 : 1.0)
                .foregroundColor(self.tabIndex == tabIndex ? changeColor(tabIndex: tabIndex) : Color.gray)
                .frame(width: geometry.size.width / 5, height: 50)
                .offset(y: self.tabIndex == tabIndex ? -5 : 0)
                .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
                .shadow(radius: 10)
        }
        //.background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
        .background(.clear)
    }
    
    //MARK: - 뷰
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                TabView(selection: $tabIndex) {
                    searcher( videoPlay: $videoPlay, reloads: $reloads, tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, searching: $searching, inputVal: $inputVal, isLandscape: $isLandscape, score: $score, recent: $recent, addVideo: $addVideo, nowVideo: $nowVideo)
                        .toolbar(.hidden, for: .tabBar)
                        .tag(TabIndex.Home)
                    PlayListView(nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, inputVal: $inputVal, searching: $searching, isLandscape: $isLandscape, score: $score, recent: $recent, nowVideo: $nowVideo)
                        .tag(TabIndex.PlayList)
                    SettingView(resolution: $resolution, isLandscape: $isLandscape)
                        .tag(TabIndex.Setting)
                    TopChart(inputVal: $inputVal, searching: $searching)
                        .tag(TabIndex.chart)
                    FindingView(addVideo: $addVideo, nowPlayList: $nowPlayList)
                        .tag(TabIndex.peer)
                }
                .onChange(of: self.nowPlayList) { [nowPlayList] newValue in
                    //print(newValue.last, self.nowVideo, nowPlayList.last)
                    if newValue.last != nowPlayList.last && newValue.last ?? LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None") != self.nowVideo {
                        self.isNewitem = true
                    }
                }
                .alert(self.newVideoAdded, isPresented: $isNewitem) {
                    
                }
                
                //탭뷰 위에 플레이어화면을 올려줌
                VStack{
                    ZStack{
//                        
//                        if adCoordinator.ad != nil {
//                            Spacer().onAppear() {
//                                print(adCoordinator.ad)
//                            }
//                        }
                        if vidFull && UIDevice.current.model == "iPad" {
                            VStack{}.onAppear(){
                                self.isLandscape = true
                            }
                        }
                        /*
                        if adCoordinator.isAdTwice {
                            VStack{}.onAppear(){
                                self.adCount -= 1
                                adCoordinator.isAdTwice = false
                            }
                        }
                         */
                        if UIDevice.current.model != "iPad" {
                            if UIDevice.current.orientation.isLandscape {
                                VStack{}.onAppear(){
                                    isLandscape = true
                                }
                            } else {
                                VStack{}.onAppear(){
                                    isLandscape = false
                                }
                            }
                        } else {
                            VStack{}.onAppear(){
                                isLandscape = true
                            }
                        }
                        if searching {
                            VStack{}.onAppear(){
                                self.tabIndex = .Home
                            }
                        }
                        if self.clickVid {
                            VStack{}.onAppear(){
                                self.adCount += 1
                            }
                        }
                        if self.vidEnd {
                            VStack{}.onAppear(){
                                print(vidEnd)
                                self.showScore = true
                                if isLandscape {
                                    rotateLandscape()
                                }
                                
                                if isReady {
                                    //self.adCount += 1
                                    if nowPlayList.count - 1 > videoOrder {
                                        vidFull = false
                                        videoOrder += 1
                                        self.isReady = false
                                        self.clickVid = true
                                        videoPlay = VideoPlay(videoId: nowPlayList[videoOrder].videoId, vidFull: $vidFull, vidEnd: self.$vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                                        reloads = true
                                        print("리로드")
                                    } else {
                                        videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false), isReady: .constant(true), resolution: .constant(.basic), isLandscape: $isLandscape, score: $score)
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
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                        self.reloads = false
                                        self.envPlayer.isOn = false
                                        self.clickVid = false
                                    }
                                }
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                            
                            // 플레이어 뷰 첫 화면
                        } else if videoPlay.videoId == "nil" && !reloads {
                            Text(self.selSong)
                            //.bold()
                                .frame(width: geometry.size.width, height: 60)
                                .background(Color(red: 44/255, green: 54/255, blue: 51/255))
                        } else {
                            //찐 플레이어 뷰
                            videoPlay
                                .environmentObject(envPlayer)
                        }
                    }
                    .frame(height: vidFull ? geometry.size.height : 60)
                    .animation(.easeInOut(duration: 0.5), value: vidFull)
                    //.edgesIgnoringSafeArea(.top)
                    Spacer()
                        .frame(height: self.vidFull ? 0 : 50)
                }
                .background {
                    // Add the adViewControllerRepresentable to the background so it
                    // doesn't influence the placement of other views in the view hierarchy.
                    adViewControllerRepresentable
                        .frame(width: .zero, height: .zero)
                }
                
                if !vidFull {
                    Circle()
                        .frame(width: 100)
                        .offset(x: self.CircleOffset(tabIndex: tabIndex, geometry: geometry), y: 25)
                        .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
                        .shadow(radius: 10)
                    HStack(spacing: 0) {
                        TabButtonSel(tabIndex: .PlayList, img: "music.note.list", geometry: geometry)
                        TabButtonSel(tabIndex: .chart, img: "crown", geometry: geometry)
                        TabButtonSel(tabIndex: .Home, img: "magnifyingglass", geometry: geometry)
                        TabButtonSel(tabIndex: .peer, img: "shared.with.you", geometry: geometry)
                        TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                    }
                    .background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                    .preferredColorScheme(.light)
//                    .onAppear(){
//                        
//                        self.isLandscape = false
//                    }
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
                if self.showScore && self.micPermission {
                    if score != 0{
                        VStack{
                            Spacer()
                            HStack{
                                StrokeText(text: "Score:", width: 2, color: .white)
                                StrokeText(text: "\(self.score) ~", width: 2, color: .white)
                            }
                            Spacer()
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                        .background(Color.black.opacity(0.5))
                        .animation(.easeInOut, value: self.score == 0)
                        .onAppear(){
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5 ) {
                                self.showScore = false
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
                Text(text).offset(x:  width, y: 0)
                Text(text).offset(x: -width, y: 0)
                Text(text).offset(x: 0, y:  width)
                Text(text).offset(x: 0, y: -width)
            }
            .foregroundColor(color)
            .font(.largeTitle)
            .bold()
            Text(text)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .bold()
        }
    }
}
