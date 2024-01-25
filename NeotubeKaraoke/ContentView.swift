//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//
import GoogleMobileAds
import SwiftUI
import MultipeerConnectivity
import SwiftSoup
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
    @AppStorage("colorMode") var colorMode: String = (UserDefaults.standard.string(forKey: "colorMode") ?? "auto")
    @AppStorage("colorSchemeOfSystem") var colorSchemeOfSystem: String = "light"
    @AppStorage("userOnboarded") var userOnboarded: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var envPlayer: EnvPlayer // 유선 연결 디스플레이
    @EnvironmentObject var purchaseManager: PurchaseManager //앱내구입 관련
    @EnvironmentObject var entitlementManager: EntitlementManager //앱내구입 관련
    @State var adViewControllerRepresentable = AdViewControllerRepresentable() //광고
    @StateObject var adCoordinator = AdCoordinator() // 광고
    @State var isLandscape = false //가로모드 확인용
    @State var searching: Bool = false // 노래방 차트 shearcher 뷰로 이동하기 위해 사용
    @State var inputVal: String = "" // searcher 입력 값
    @State var vidFull = false // 플레이어 전체 화면
    @State var tabIndex: TabIndex = .Home // 탭뷰 인데스
    //@State var reloads = false
    //@State var closes = false
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false //비디오 끝 종료 확인
    @State var clickVid = false // 광고 재생 위해 영상 클릭했는지 검사
    @State var videoOrder: Int = 0
    //@State var isReady: Bool = true
    @State var resolution: Resolution = .basic //말그대로 영상 해상도
    //@State var once = false
    //@State var score: Int = 0
    //@State var showScore = false
    @State var recent = [LikeVideo]() //최근플레이한 비디오 리스트
    @State var addVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var nowVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var isNewitem = false // 다른 디바이스 예약 확인 알림 창 띄우기 용
    @State var manualopen = false // 메뉴얼 사용법
    @State var vidID: String = "노래방" //비디오 아이디
    
    //@State var colorMode = "auto"
//    @State var colorSchemeOfSystem: ColorScheme = .dark
    //@State var restartApp = false
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
                    }
                }
            }
        }
    }
    
    func colorResult(light: Color, dark: Color) -> Color {
        if self.colorMode == "auto" {
            if colorSchemeOfSystem == "dark" {
                return dark
            } else {
                return light
            }
        } else if self.colorMode == "dark" {
            return dark
        } else {
            return light
        }
    }
    
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
            return Color.teal
        case .PlayList:
            return Color.green
        case .chart:
            return Color.orange
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
                //.shadow(radius: 10)
        }
        //.background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
        .background(.clear)
    }
    
    func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    //MARK: - 뷰
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                ZStack(alignment: .bottom){
                    TabView(selection: $tabIndex) {
                        searcher(tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder/*, isReady: $isReady*/, resolution: $resolution, searching: $searching, inputVal: $inputVal, isLandscape: $isLandscape/*, score: $score*/, recent: $recent, addVideo: $addVideo, nowVideo: $nowVideo, vidID: $vidID)
                            .toolbar(.hidden, for: .tabBar)
                            .environmentObject(self.purchaseManager)
                            .environmentObject(self.entitlementManager)
                            .tag(TabIndex.Home)
                        PlayListView(nowPlayList: $nowPlayList, vidFull: $vidFull, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, /*isReady: $isReady,*/ resolution: $resolution, inputVal: $inputVal, searching: $searching, isLandscape: $isLandscape, /*score: $score,*/ recent: $recent, nowVideo: $nowVideo, vidID: $vidID)
                            .tag(TabIndex.PlayList)
                        SettingView(resolution: $resolution, isLandscape: $isLandscape)
                            .tag(TabIndex.Setting)
                            .environmentObject(self.purchaseManager)
                            .environmentObject(self.entitlementManager)
                        TopChart(inputVal: $inputVal, searching: $searching)
                            .tag(TabIndex.chart)
                        FindingView(addVideo: $addVideo, nowPlayList: $nowPlayList)
                            .tag(TabIndex.peer)
                    }
                    .onAppear(){
                        self.colorSchemeOfSystem = self.colorScheme == .dark ? "dark" : "light"
                    }
                    .onChange(of: self.nowPlayList) { [nowPlayList] newValue in
                        //print(newValue.last, self.nowVideo, nowPlayList.last)
                        if newValue.last != nowPlayList.last && newValue.last ?? LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None") != self.nowVideo {
                            self.isNewitem = true
                        }
                    }
                    .alert("에약되었습니다.", isPresented: $isNewitem) {
                        
                    }
                    //탭뷰 위에 플레이어화면을 올려줌
                    VStack{
                        ZStack{
//                            if vidFull && UIDevice.current.model == "iPad" {
//                                VStack{}.onAppear(){
//                                    self.isLandscape = true
//                                }
//                            }
//                            if UIDevice.current.model != "iPad" {
//                                if UIDevice.current.orientation.isLandscape {
//                                    VStack{}.onAppear(){
//                                        isLandscape = true
//                                    }
//                                } else {
//                                    VStack{}.onAppear(){
//                                        isLandscape = false
//                                    }
//                                }
//                            } else {
//                                VStack{}.onAppear(){
//                                    isLandscape = true
//                                }
//                            }
                            if searching {
                                VStack{}.onAppear(){
                                    self.tabIndex = .Home
                                }
                            }
                            if self.clickVid {
                                VStack{}.onAppear(){
                                    if !entitlementManager.hasPro {
                                        self.adCount += 1
                                    }
                                }
                            }
                            if self.vidEnd {
                                VStack{}.onAppear(){
                                    print(vidEnd)
                                    //self.showScore = true
                                    if isLandscape {
                                        rotateLandscape()
                                    }
                                    
                                    //if isReady {
                                        //self.adCount += 1
                                    if nowPlayList.count - 1 > videoOrder {
                                        vidFull = false
                                        videoOrder += 1
                                        //self.isReady = false
                                        self.clickVid = true
                                        self.vidID = nowPlayList[videoOrder].videoId
                                        /*videoPlay = VideoPlay(videoId: nowPlayList[videoOrder].videoId, vidFull: $vidFull, vidEnd: self.$vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)*/
                                        //reloads = true
                                        //print("리로드")
                                    } else {
                                        /*videoPlay = VideoPlay(videoId: "nil", vidFull: .constant(false), vidEnd: .constant(false), isReady: .constant(true), resolution: .constant(.basic), isLandscape: $isLandscape, score: $score)*/
                                        //reloads = true
                                    }
                                    //}
                                }
                            }
                            VideoPlay(videoId: $vidID, vidFull: $vidFull, vidEnd: $vidEnd, /*isReady: $isReady,*/ resolution: $resolution, isLandscape: $isLandscape/*, score: $score*/, clickVid: $clickVid)
                            // 플레이어를 새로 그리기 위해 시간 텀이 필요
//                            if reloads {
//                                Text("loading")
//                                    .frame(width: geometry.size.width, height: 60)
//                                    .onAppear(){
//                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//                                            self.reloads = false
//                                            self.envPlayer.isOn = false
//                                            self.clickVid = false
//                                        }
//                                    }
//                                // 플레이어 뷰 첫 화면
//                            } else if videoPlay.videoId == "nil" && !reloads {
//                            } else {
//                                //찐 플레이어 뷰
//                                videoPlay
//                                    .environmentObject(envPlayer)
//                            }
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
                        HStack{
                            Rectangle()
                                .frame(width: geometry.size.width, height: 50)
                        }
                        .shadow(radius: 5)
                        Circle()
                            .frame(width: 100)
                            .offset(x: self.CircleOffset(tabIndex: tabIndex, geometry: geometry), y: 25)
                            .foregroundColor(colorResult(light: Color(red: 0.9412, green: 0.9255, blue: 0.8980), dark: Color(red: 0.13, green: 0.13, blue: 0.13)))
                            .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
                            .shadow(radius: 5)
                        HStack(spacing: 0) {
                            TabButtonSel(tabIndex: .PlayList, img: "music.note.list", geometry: geometry)
                            TabButtonSel(tabIndex: .chart, img: "crown", geometry: geometry)
                            TabButtonSel(tabIndex: .Home, img: "magnifyingglass", geometry: geometry)
                            TabButtonSel(tabIndex: .peer, img: "shared.with.you", geometry: geometry)
                            if self.colorMode == "dark" {
                                TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                                    .preferredColorScheme(.dark)
                            } else if self.colorMode == "light" {
                                TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                                    .preferredColorScheme(.light)
                            } else {
                                TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                                    .preferredColorScheme(colorSchemeOfSystem == "dark" ? .dark : .light)
                            }
                        }
                        .background(self.colorScheme == .light ? Color(red: 0.9412, green: 0.9255, blue: 0.8980) : Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        
                    }
                    
//                    if self.showScore && self.micPermission {
//                        if score != 0{
//                            VStack{
//                                Spacer()
//                                HStack{
//                                    StrokeText(text: "Score:", width: 2, color: .white)
//                                    StrokeText(text: "\(self.score) ~", width: 2, color: .white)
//                                }
//                                Spacer()
//                                Spacer()
//                            }
//                            .frame(width: geometry.size.width)
//                            .background(Color.black.opacity(0.5))
//                            .animation(.easeInOut, value: self.score == 0)
//                            .onAppear(){
//                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5 ) {
//                                    self.showScore = false
//                                }
//                            }
//                        }
//                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            if !userOnboarded {
                //ManualList()
                VStack{
                    ZStack{
                        Image(systemName: "books.vertical.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.orange)
                            .frame(height: 100)
                    
                    }
                    .padding()
                    Divider()
                    Button {
                        manualopen = true
                    } label: {
                        Text("앱 사용법 보러가기")
                            .padding(5)
                    }
                    Divider()
                    Button(action: {
                        userOnboarded = true
                    }, label: {
                        Text("닫기")
                            .padding(5)
                            .padding(.bottom, 5)
                    })
                    
                }
                .frame(width: 200)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .shadow(radius: 10)
                .sheet(isPresented: $manualopen, content: {
                        ManualList()
                })
                
            }
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
