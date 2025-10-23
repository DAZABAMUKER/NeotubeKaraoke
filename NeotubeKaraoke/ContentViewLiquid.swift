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

// 메인 뷰
@available(iOS 26.0, *)
struct ContentViewLiquid: View {
    
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
    @State var nowPlayList = [LikeVideo]()
    @State var vidEnd = false //비디오 끝 종료 확인
    @State var clickVid = false // 광고 재생 위해 영상 클릭했는지 검사
    @State var videoOrder: Int = 0
    @State var resolution: Resolution = .basic //말그대로 영상 해상도
    //@State var score: Int = 0
    //@State var showScore = false
    @State var recent = [LikeVideo]() //최근플레이한 비디오 리스트
    @State var addVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var nowVideo: LikeVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
    @State var isNewitem = false // 다른 디바이스 예약 확인 알림 창 띄우기 용
    @State var manualopen = false // 메뉴얼 사용법
    @State var vidID: String = "노래방" //비디오 아이디
    
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
                        //adCoordinator.canPlay = false
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
    
    func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    //MARK: - 뷰
    var body: some View {
        TabView() { //Liquid Glass UI Design Tabbar
            Tab(role: .search) { //메인이 되는 Search 탭
                searcher(tabIndex: $tabIndex, vidFull: $vidFull, nowPlayList: $nowPlayList, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, resolution: $resolution, searching: $searching, inputVal: $inputVal, isLandscape: $isLandscape/*, score: $score*/, recent: $recent, addVideo: $addVideo, nowVideo: $nowVideo, vidID: $vidID)
                    .environmentObject(self.purchaseManager)
                    .environmentObject(self.entitlementManager)
            }
            Tab() { //플레이리스트
                PlayListView(nowPlayList: $nowPlayList, vidFull: $vidFull, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, resolution: $resolution, inputVal: $inputVal, searching: $searching, isLandscape: $isLandscape, /*score: $score,*/ recent: $recent, nowVideo: $nowVideo, vidID: $vidID)
            } label: {
                Image(systemName: "list.bullet")
            }
            Tab() { //차트 현재는 금영만 가능함
                TopChart(inputVal: $inputVal, searching: $searching)
            } label: {
                Image(systemName: "crown")
            }
            Tab() { // 장치 연결 뷰
                FindingView(addVideo: $addVideo, nowPlayList: $nowPlayList)
            } label: {
                Image(systemName: "shared.with.you")
            }
            Tab() { // 마지막 설정 뷰
                SettingView(resolution: $resolution, isLandscape: $isLandscape)
                    .environmentObject(self.purchaseManager)
                    .environmentObject(self.entitlementManager)
            } label: {
                Image(systemName: "gear")
            }
        }
        
        .tabBarMinimizeBehavior(.automatic)
//        .tabViewBottomAccessory(content: {
//            Text("")
//        })
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
        
    }
    
}

