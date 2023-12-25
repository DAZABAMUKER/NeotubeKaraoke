//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI
//import PythonKit
import MultipeerConnectivity

struct searcher: View{
    
    @StateObject var peers = ConnectPeer()
    @State var showplayer = false
    @State var isEditing: Bool = false
    @State var likeModal: Bool = false
    @StateObject var models = Models()
    @StateObject var ytSearch = HTMLParser()
    @State var playlist = [playlists]()
    @State var ResponseItems = [Video]()
    @State var ytVideos = [LikeVideo]()
    @State var lastNowPL = false
    @State var rightAfterNowPL = false
    @State var alreadyHave = false
    
    //Cheer View 변수
    @State var cheerColor = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.indigo, Color.purple]
    @State var colorIndex = 0
    @State var showCheer = false
    @State var ment = ""
    @State var isAnimation = false
    @State var audioManager = AudioManager()
    
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var tabIndex: TabIndex
    @Binding var vidFull: Bool
    @Binding var nowPlayList: [LikeVideo]
    @Binding var vidEnd: Bool
    @Binding var clickVid: Bool
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var searching: Bool
    @Binding var inputVal: String
    @Binding var isLandscape: Bool
    @Binding var score: Int
    @Binding var recent: [LikeVideo]
    @Binding var addVideo: LikeVideo
    @Binding var nowVideo: LikeVideo
    
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if self.searching {
                    VStack{}.onAppear(){
                        //self.ytSearch.search(value: self.inputVal)
                        let _ = models.getVideos(val: inputVal)
                        self.searching = false
                    }
                }
                if models.stsCode != 200 && models.stsCode != 0 {
                    VStack{}.onAppear(){
                        self.ytSearch.search(value: self.inputVal)
                        models.stsCode = 0
                    }
                }
                if ytSearch.isResults {
                    VStack{}.onAppear(){
                        self.ytVideos = ytSearch.results
                        ytSearch.isResults = false
                    }
                }
                if models.isResponseitems {
                    VStack{}.onAppear(){
                        self.ytVideos = models.responseitems.map{LikeVideo(videoId: $0.videoID, title: $0.title, thumbnail: $0.thumbnail, channelTitle: $0.channelTitle)}
                        models.isResponseitems = false
                        print("change")
                    }
                }
                ZStack{
                    VStack(spacing: 9){
                        Spacer()
                            .frame(height: 60)
                        if !self.ytVideos.isEmpty {
                            //MARK: - 리스트
                            ScrollView{
                                VStack{
                                    if !entitlementManager.hasPro{
                                        BannerAd()
                                            .frame(width: geometry.size.width, height: 70)
                                    }
                                    ForEach(self.ytVideos, id: \.videoId){ responseitems in
                                        Button {
                                            //videoPlay.closes = true
                                            //if self.isReady {
                                                self.vidEnd = true
                                                self.isReady = false
                                                self.clickVid = true
                                                videoPlay = VideoPlay(videoId: responseitems.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                                                reloads = true
                                                //print("리로드")
                                                self.nowVideo = LikeVideo(videoId: responseitems.videoId, title: responseitems.title, thumbnail: responseitems.thumbnail, channelTitle: responseitems.channelTitle)
                                                self.nowPlayList.append(self.nowVideo)
                                                self.videoOrder = nowPlayList.count - 1
                                                saveRecent(video: responseitems)
                                            //}
                                        } label: {
                                            HStack(spacing: 0){
                                                ListView(Video: responseitems)
                                                    .padding(.leading, 5)
                                                    //.border(.red)
                                                HStack(spacing: 0){
                                                    Image(systemName: "ellipsis")
                                                        .rotationEffect(Angle(degrees: 90))
                                                        .tint(.secondary)
                                                        .frame(width: 15, height: 70)
                                                        .background(.black.opacity(0.01))
                                                        .onTapGesture {
                                                            self.likeModal = true
                                                            self.addVideo = LikeVideo(videoId: responseitems.videoId, title: responseitems.title, thumbnail: responseitems.thumbnail, channelTitle: responseitems.channelTitle, runTime: responseitems.runTime)
                                                        }
                                                        .padding(.trailing, 5)
                                                }
                                                //.border(.green)
                                            }
                                        }
                                        //.disabled(!isReady)
                                    }
                                    if !entitlementManager.hasPro {
                                        BannerAd()
                                            .frame(width: geometry.size.width, height: 70)
                                    }
                                    VStack{}
                                        .frame(height: 200)
                                }
                                //.background(Color.black.opacity(0.6))
                            }
                            //.frame(width:geometry.size.width,height: geometry.size.height - 60)
//                            .background(){
//                                Image("clear")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: geometry.size.width)
//                                    .opacity(0.3)
//                                    .brightness(-0.3)
//                            }
                            .padding(.top, -8)
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 80)
                            //.preferredColorScheme(.dark)
                            //VStack{}.frame(height: 135).background(.red)
                        } else {
                            ZStack{
                                Image("clear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width)
                                    .padding(.top, -200)
                                    .opacity(0.3)
                                    .brightness(-0.3)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            
                            //.preferredColorScheme(.dark)
                        }
                    }
                    //.border(Color.black)
                    .background{
                        Color.black.opacity(!self.ytVideos.isEmpty ? 0.0 : 0.05)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    VStack{
                        HStack(spacing: 0){
                            //MARK: - SearchBar
                            //이미지
                            Button {
                                self.showCheer = true
                            } label: {
                                ZStack{
                                    Image(systemName: "circle")
                                        .foregroundColor(Color(red: 1, green: 112 / 255.0, blue: 0))
                                        .font(.system(size: 50))
                                        .padding(.leading, 10)
                                        .padding(.bottom, 5)
                                    Image(systemName: "music.mic")
                                        .foregroundColor(Color(red: 1, green: 112 / 255.0, blue: 0))
                                        .font(.system(size: 30))
                                        .padding(.leading, 10)
                                        .padding(.bottom, 5)
                                }
                                .onAppear(){
                                    openRecent()
                                }
                            }
                            .sheet(isPresented: $showCheer) {
                                cheerView
                                    .onAppear(){
                                        self.audioManager.setEngine(file: Bundle.main.url(forResource: "clap", withExtension: "wav")!, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0, views: "Searcher View")
                                    }
                            }
                            TextField("", text: $inputVal, onEditingChanged: {isEditing = $0 })
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .background(border)
                                //.foregroundColor(.white)
                                .padding(.trailing, 30)
                                .padding(.leading, 20)
                                .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: "검색"))
                                .onSubmit {
                                    let _ = models.getVideos(val: inputVal)
                                    //getResults(val: inputVal)
                                    //loadytsr()
                                    //getSome()
                                    //self.ytSearch.search(value: self.inputVal)
                                }
                            //Text(String(models.stsCode))
                            Button {
                                self.inputVal = ""
                            } label: {
                                if (self.inputVal.count > 0) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 20))
                                        .padding(.trailing, 10)
                                        .padding(.leading, -10)
                                }
                            }
                        }
                        .onAppear(){
                            decodePList()
                        }
                        .background{
                            if self.colorScheme == .dark {
                                Color(red: 0.13, green: 0.13, blue: 0.13)
                                    .edgesIgnoringSafeArea(.horizontal)
                                    .frame(width: geometry.size.width)
                                    .padding(.top, -geometry.safeAreaInsets.top)
                                    .shadow(radius: 5)
                            } else {
                                Color(red: 0.9412, green: 0.9255, blue: 0.8980)
                                    .edgesIgnoringSafeArea(.horizontal)
                                    .frame(width: geometry.size.width)
                                    .padding(.top, -geometry.safeAreaInsets.top)
                                    .shadow(radius: 5)
                            }
                        }
                        Spacer()
                    }
                    if self.isEditing {
                        //MARK: 키보드 숨김 뷰 버튼
                        VStack{
                            Spacer()
                                .frame(height: 60)
                            VStack{}
                                .ignoresSafeArea(.all)
                                .frame(width: geometry.size.width, height: geometry.size.height-60)
                                .background {
                                    Color.black.opacity(0.01)
                                }
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                    }
                    
                    //MARK: 재생목록 추가 뷰
                    if self.likeModal {
                        VStack(spacing: 0){
                            Text("재생목록 추가")
                                .padding(15)
                                .bold()
                            //.font(.title)
                            List {
                                Button {
                                    self.tabIndex = .peer
                                    self.likeModal = false
                                } label: {
                                    Text("영상 공유하기")
                                }
                                .listRowBackground(Color.black.opacity(0.5))
                                Button {
                                    self.lastNowPL.toggle()
                                } label: {
                                    HStack{
                                        Text("현재 재생목록 마지막에 추가")
                                            .listRowBackground(Color.black.opacity(0.5))
                                        Spacer()
                                        Image(systemName: self.lastNowPL ? "checkmark.circle.fill" : "circle")
                                    }
                                }
                                .listRowBackground(Color.black.opacity(0.5))
                                Button {
                                    self.rightAfterNowPL.toggle()
                                } label: {
                                    HStack{
                                        Text("현재 노래 다음에 추가")
                                        Spacer()
                                        Image(systemName: self.rightAfterNowPL ? "checkmark.circle.fill" : "circle")
                                    }
                                }
                                .listRowBackground(Color.black.opacity(0.5))
                                ForEach(0..<self.playlist.count, id: \.self) { i in
                                    Button {
                                        self.playlist[i].isSelected.toggle()
                                    } label: {
                                        HStack{
                                            Text(" \(self.playlist[i].name)")
                                            Spacer()
                                            Image(systemName: self.playlist[i].isSelected ? "checkmark.circle.fill" : "circle")
                                        }
                                    }
                                    .listRowBackground(Color.black.opacity(0.5))
                                }
                            }
                            .listStyle(.plain)
                            .background(.clear)
                            HStack{
                                //취소버튼
                                Button {
                                    self.likeModal = false
                                    self.addVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
                                } label: {
                                    Text("취소")
                                        .padding(10)
                                }
                                Divider()
                                    .frame(width: 60,height: 50)
                                //추가버튼
                                Button {
                                    let tempList = self.playlist.filter{$0.isSelected == true}
                                    self.likeModal = false
                                    tempList.forEach{ addVideoToPlist(item: self.addVideo, listName: $0.name)}
                                    decodePList()
                                    if self.lastNowPL {
                                        nowPlayList.append(self.addVideo)
                                    }
                                    if self.rightAfterNowPL {
                                        if nowPlayList.isEmpty {
                                            nowPlayList.append(self.addVideo)
                                        } else {
                                            nowPlayList.insert(self.addVideo, at: videoOrder + 1)
                                        }
                                    }
                                    self.lastNowPL = false
                                    self.rightAfterNowPL = false
                                    self.addVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
                                } label: {
                                    Text("추가")
                                        .padding(10)
                                }
                                
                            }
                        }
                        .frame(width: 300, height: 250)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 10)
                    }
                    if self.alreadyHave {
                        VStack{
                            Text("이미 포함하고 있는 항목입니다.")
                                .padding(20)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 10)
                                .onAppear(){
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3 ) {
                                        self.alreadyHave = false
                                    }
                                }
                                .animation(.easeIn, value: self.alreadyHave)
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
}




//MARK: -  뷰
extension searcher {
    
    var border: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .padding(-20)
                .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 0.2)))
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(LinearGradient(gradient: .init(
                    colors: [
                        Color(red: 1, green: 112 / 255.0, blue: 0),
                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                    ]),startPoint: .topLeading,endPoint: .bottomTrailing),lineWidth: isEditing ? 4 : 2)
                .frame(height: 40)
                .padding(-20)
            
        }
    }
    
    
    
    var cheerView: some View {
        ZStack{
            VStack{
                if ment == "" {
                    Text("응원 멘트를 입력해주세요.")
                        .font(.system(size: 300, weight: .bold))
                        .minimumScaleFactor(0.3)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(.secondary )
                        .animation(.linear(duration: 1.0), value: self.colorIndex)
                } else {
                    Text(ment)
                        .font(.system(size: 300, weight: .bold))
                        .minimumScaleFactor(0.3)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundStyle(isAnimation ? cheerColor[colorIndex] : Color.primary)
                        .animation(.linear(duration: 1.0), value: self.colorIndex)
                        .onTapGesture {
                            rotateLandscape()
                        }
                }
                if isAnimation {
                    VStack{}.onAppear(){
                        chageColor()
                    }
                }
                if !isLandscape {
                    HStack{
                        TextField("응원 멘트를 입력해주세요", text: $ment, onEditingChanged: {isEditing = $0 })
                            .padding()
                            .onAppear(){
                                self.isAnimation = false
                                
                            }
                            .onDisappear(){
                                self.isAnimation = true
                            }
                        Button {
                            self.ment = ""
                        } label: {
                            if (self.ment.count > 0) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                                    .padding(.trailing, 5)
                            }
                        }
                    }
                }
            }
            VStack{
                Spacer()
                HStack{
                    Button {
                        self.audioManager.playClap()
                    } label: {
                        Image(systemName: "hands.clap.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .padding(.trailing,20)
                            .opacity(0.5)
                    }
                    Spacer()
                    if UIDevice.current.model == "iPad" {
                        Button {
                            rotateLandscape()
                        } label: {
                            Image(systemName: "text.bubble.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .padding(.trailing,20)
                                .opacity(0.5)
                        }
                    }
                    Button {
                        self.audioManager.playCrowd()
                    } label: {
                        Image(systemName: "shareplay")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .padding(.trailing,20)
                            .opacity(0.5)
                    }
                    
                }
                .frame(height: 50, alignment: .trailing)
                Spacer()
                    .frame(height: !isLandscape ? 50 : 10)
            }
        }
    }
}

//MARK: 함수
extension searcher {
    
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
    
    func chageColor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (self.cheerColor.count == colorIndex + 1) {
                self.colorIndex = 0
            } else {
                self.colorIndex += 1
            }
            chageColor()
        }
    }
    
    func addToNowPlaying(vid: LikeVideo) {
        if self.nowPlayList.contains(vid) {
            self.nowPlayList.remove(at: self.nowPlayList.firstIndex(of: vid)!)
        }
        self.nowPlayList.append(vid)
    }
    
    func saveRecent(video: LikeVideo) {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("recent", conformingTo: .json)
        if self.recent.contains(video) {
            self.recent.remove(at: self.recent.firstIndex(of: video)!)
        }
        if self.recent.count > 10 {
            self.recent.removeLast()
            self.recent.insert(video, at: 0)
        } else {
            if self.recent.isEmpty {
                self.recent.append(video)
            } else {
                self.recent.insert(video, at: 0)
            }
        }
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            try? FileManager.default.removeItem(at: fileurl)
        }
        let encoder = JSONEncoder()
        let myData = try? encoder.encode(self.recent)
        FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: myData)
    }
    
    func openRecent() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("recent", conformingTo: .json)
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            guard let js = NSData(contentsOf: fileurl) else { return }
            let decoder = JSONDecoder()
            let myData = try? decoder.decode([LikeVideo].self, from: js as Data)
            self.recent = myData!
        }
    }
    
    func decodePList() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("playlist", conformingTo: .json)
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            guard let js = NSData(contentsOf: fileurl) else { return }
            let decoder = JSONDecoder()
            let myData = try? decoder.decode([String].self, from: js as Data)
            self.playlist = myData!.map { playlists(name: $0)}
        }
    }
    
    func addVideoToPlist(item: LikeVideo, listName: String) {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("\(listName)", conformingTo: .json)
        //print(fileUrl)
        //let urlEncode = fileUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //let fileurl = URL(string: fileUrl)!
        print(fileurl)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path(percentEncoded: false)) {
                print(fileurl)
                let js = try Data(contentsOf: fileurl)
                let decoder = JSONDecoder()
                var myData = try? decoder.decode([LikeVideo].self, from: js as Data)
                print(myData?.count ?? 0)
                if myData!.contains(item) {
                    self.alreadyHave = true
                    return
                }
                myData?.append(item)
                print(myData?.count ?? 0)
                try FileManager.default.removeItem(at: fileurl)
                let data = try JSONEncoder().encode(myData)
                FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: data)
            } else {
                let myData = [item]
                let data = try JSONEncoder().encode(myData)
                FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: data)
                
            }
        }
        catch {
            print(error)
        }
    }
}

struct playlists: Hashable {
    var id = UUID()
    var name: String
    var isSelected: Bool = false
}
