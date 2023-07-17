//
//  PlayListView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/07.
//

import SwiftUI

struct PlayListView: View {
    
    //MARK: - PlayListView 변수
    @State var PLAppear: Bool = false
    @State var plusPlayList: Bool = false
    @State var pTitle: String = ""
    @State var playlist = [String]()
    @State var showNowPL = false // 현재 재생 목록 보여줄지 말자 결정하는 변수
    @Binding var nowPlayList: [LikeVideo]
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @Binding var clickVid: Bool
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var inputVal: String
    @Binding var searching: Bool
    @Binding var isLandscape: Bool
    @Binding var score: Int
    @Binding var recent: [LikeVideo]
    @Binding var nowVideo: LikeVideo
    
    private let showNowPlaying: LocalizedStringKey = "Show now playing list"
    private let nowPlaying: LocalizedStringKey = "Now Playing List"
    private let Recent: LocalizedStringKey = "Recent"
    private let createdList: LocalizedStringKey = "Created Playlist"
    private let addList: LocalizedStringKey = "Add Playlist"
    private let inputTilte: LocalizedStringKey = "Input your playlist title"
    private let OK: LocalizedStringKey = "OK"
    private let cancel: LocalizedStringKey = "Cancel"
    let heights = 100.0
    
    
    func addToNowPlaying(vid: LikeVideo) {
        if self.nowPlayList.contains(vid) {
            self.nowPlayList.remove(at: self.nowPlayList.firstIndex(of: vid)!)
        }
        self.nowPlayList.append(vid)
    }
    
    //MARK: - PlayListView 함수
    //playlist.json에서 플레이리스트들 가져옴.
    func decodePList() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("playlist", conformingTo: .json)
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            guard let js = NSData(contentsOf: fileurl) else { return }
            let decoder = JSONDecoder()
            let myData = try? decoder.decode([String].self, from: js as Data)
            self.playlist = myData!
        }
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
            }
            self.recent.insert(video, at: 0)
        }
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            try? FileManager.default.removeItem(at: fileurl)
        }
        let encoder = JSONEncoder()
        let myData = try? encoder.encode(self.recent)
        FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: myData)
    }
    
    // 플레이리스트 생성 함수
    func savePlayList(title: String) {
        if !title.isEmpty {
            self.playlist.append(title)
        }
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("playlist", conformingTo: .json)
        let data = try! JSONEncoder().encode(self.playlist)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path()) {
                try FileManager.default.removeItem(at: fileurl)
            }
            FileManager.default.createFile(atPath: fileurl.path(), contents: data)
        } catch {
            print("playlist encode:", error)
        }
        decodePList()
    }
    
    
    //MARK: - 바디
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack(alignment: .leading){
                    //MARK: 네비게이션 바
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
                            .onAppear(){
                                decodePList() // 네비게이션 그려지면 플레이리스트 가져오기
                            }
                        Button {
                            self.plusPlayList = true // 플레이리스트 추가위한 Alert 트리거
                        } label: {
                            Image(systemName: "plus.app")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .padding(.horizontal ,20)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 70)
                    //.background(.thinMaterial)
                    
                    //MARK: 최근 재생목록
                    ScrollView(.horizontal){
                        HStack{
                            Text(self.Recent)
                                .bold()
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.headline)
                                .padding(5)
                                .padding(.leading, 10)
                                .frame(height: 150)
                            ForEach(recent, id: \.self) { recent in
                                Button {
                                    self.isReady = false
                                    self.clickVid = true
                                    videoPlay = VideoPlay(videoId: recent.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                                    reloads = true
                                    self.nowVideo = LikeVideo(videoId: recent.videoId, title: recent.title, thumbnail: recent.thumbnail, channelTitle: recent.channelTitle)
                                    self.nowPlayList.append(self.nowVideo)
//                                    addToNowPlaying(vid: LikeVideo(videoId: recent.videoId, title: recent.title, thumbnail: recent.thumbnail, channelTitle: recent.channelTitle))
//                                    self.videoOrder = self.nowPlayList.firstIndex(of: recent) ?? -1
                                    self.videoOrder = self.nowPlayList.count - 1
                                    saveRecent(video: recent)
                                    print("video order: ", videoOrder)
                                } label: {
                                    VStack{
                                        AsyncImage(url: URL(string: recent.thumbnail)) { image in
                                            image.image?.resizable()
                                                .resizable()
                                                .frame(width: heights/9*16, height: heights/9*12)
                                                .clipShape(Rectangle().size(width: heights/9*16, height: heights).offset(x: 0, y: heights/6))
                                                .frame(width: heights/9*16, height: heights)
                                                .shadow(color: .black,radius: 10, x: 0, y: 10)
                                        }
                                        Text(recent.title)
                                            .lineLimit(2)
                                            .frame(width: 160)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(height: 150)
                                }
                                .padding(.horizontal, 8)
                            }
                            /*
                            Button {
                                self.showNowPL.toggle()
                            } label: {
                                VStack{
                                    Image("playlist")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                    Text(self.nowPlaying)
                                }
                            }
                             */
                        }
                        .tint(.white)
                        .font(.caption)
                    }
                    
                    //MARK: 재생목록 리스트
                    LinearGradient(colors: [Color.white, Color.secondary.opacity(0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width, height: 1)
                    HStack{
                        Text(showNowPL ? self.nowPlaying : self.createdList)
                            .font(.title3)
                            .bold()
                            .padding(5)
                        Spacer()
                        if showNowPL {
                            Button {
                                self.showNowPL = false
                            } label: {
                                Text("Back")
                                    .tint(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .frame(height: 30)
                    LinearGradient(colors: [Color.white, Color.secondary.opacity(0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width, height: 1)
                    NavigationStack{
                        List{
                            NavigationLink{
                                List {
                                    ForEach(nowPlayList, id: \.self) { list in
                                        Button {
                                            self.isReady = false
                                            self.clickVid = true
                                            videoPlay = VideoPlay(videoId: list.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                                            reloads = true
                                            self.videoOrder = self.nowPlayList.firstIndex(of: list) ?? -1
                                            saveRecent(video: list)
                                            print("video order: ", videoOrder)
                                        } label: {
                                            ListView(Video: list)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                self.nowPlayList.remove(at: self.nowPlayList.firstIndex(of: list)!)
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                            .tint(.red)
                                        }
                                        .disabled(!isReady)
                                    }
                                    VStack{}.frame(height: 70)
                                }
                                .listStyle(.plain)
                                .environment(\.defaultMinListRowHeight, 80)
                            } label: {
                                HStack{
                                    Image("playlist")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 30)
                                    Text(self.nowPlaying)
                                }
                            }
                            ForEach(self.playlist, id: \.self) { item in
                                //TableCell(Video: video)
                                NavigationLink {
                                    showList(listName: item, nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, clickVid: $clickVid, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score, recent: $recent) // 해당 재생목록 영상 리스트 뷰로 이동
                                        .onAppear(){
                                            self.PLAppear = true
                                        }
                                        .onDisappear(){
                                            self.PLAppear = false
                                        }
                                } label: {
                                    Text(item)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        //재생목록 제거
                                        print("제거")
                                        let listIndex = self.playlist.firstIndex(of: item)
                                        self.playlist.remove(at: listIndex!)
                                        savePlayList(title: "")
                                        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                        let existPlaylist = doc.appendingPathComponent(item, conformingTo: .json)
                                        do {
                                            if FileManager.default.fileExists(atPath: existPlaylist.path(percentEncoded: false)) {
                                                try FileManager.default.removeItem(atPath: existPlaylist.path(percentEncoded: false))
                                            }
                                        } catch {
                                            print("removePList Error:",error)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                    
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .preferredColorScheme(.dark)
                
                
                //MARK: 재생목록 추가 뷰
                if self.plusPlayList {
                    VStack{}
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background {
                            Color.black.opacity(0.1)
                        }
                        .onTapGesture {
                            hideKeyboard()
                        }
                    VStack(spacing: 0){
                        Text(self.addList)
                            .font(.title2)
                            .padding()
                        //Divider()
                        TextField(self.inputTilte, text: $pTitle)
                            .background(content: {
                                Spacer()
                                    .frame(width: 300,height: 50)
                                    .background(.black.opacity(0.3))
                            })
                            .padding()
                            .onSubmit {
                                if !self.pTitle.isEmpty {
                                    savePlayList(title: self.pTitle)
                                    self.plusPlayList = false
                                    self.pTitle = ""
                                }
                            }
                        Divider()
                        HStack{
                            Button {
                                if !self.pTitle.isEmpty {
                                    savePlayList(title: self.pTitle)
                                    self.plusPlayList = false
                                    self.pTitle = ""
                                }
                            } label: {
                                Text(self.OK)
                            }
                            .padding()
                            Divider()
                                .frame(width: 60,height: 50)
                            Button {
                                self.plusPlayList = false
                                self.pTitle = ""
                            } label: {
                                Text(self.cancel)
                            }
                            .padding()
                        }
                    }
                    .frame(width: 300)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
                    .offset(y: -100)
                    .shadow(radius: 10)
                }
            }
            .background(content: {
                LinearGradient(colors: [Color(red: 152/255, green: 216/255, blue: 170/255).opacity(0.5), .clear, .clear, .clear], startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.top)
            })
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


//MARK: - LikeVideo 라이크 뷰 영상 구조체
struct LikeVideo: Codable, Hashable {
    let videoId: String
    let title: String
    let thumbnail: String
    let channelTitle: String
    var runTime: String = ""
}

//MARK: - 해당 재생목록 영상 리스트 뷰

struct showList: View {
    
    var listName: String
    @State var playlist = [LikeVideo]()
    @Binding var nowPlayList: [LikeVideo]
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @Binding var clickVid: Bool
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    @Binding var score: Int
    @Binding var recent: [LikeVideo]
    
    //MARK: 해당 재생목록 파일 읽어오기
    func getLists() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent(listName, conformingTo: .json)
        //var fileUrl = doc.absoluteString + "\(listName).json"
        //print(fileUrl)
        print(fileurl)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path(percentEncoded: false)) {
                guard let js = NSData(contentsOf: fileurl) else { return }
                let decoder = JSONDecoder()
                guard let myData = try? decoder.decode([LikeVideo].self, from: js as Data) else {
                    return
                }
                self.playlist = myData
            } else {
            }
        }
    }
    
    func saveLists() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent(listName, conformingTo: .json)
        let encoder = JSONEncoder()
        print(fileurl)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path(percentEncoded: false)) {
                try? FileManager.default.removeItem(atPath: fileurl.path(percentEncoded: false))
            }
            let myData = try? encoder.encode(self.playlist)
            FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: myData)
        }
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
            }
            self.recent.insert(video, at: 0)
        }
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            try? FileManager.default.removeItem(at: fileurl)
        }
        let encoder = JSONEncoder()
        let myData = try? encoder.encode(self.recent)
        FileManager.default.createFile(atPath: fileurl.path(percentEncoded: false), contents: myData)
    }
    
    //MARK: showList 바디
    var body: some View {
        VStack{}.onAppear(){
            getLists() // 재생목록 영상(LikeVideo) 가져오기
        }
        List{
            ForEach(playlist, id: \.self) { playlist in
                Button {
                    self.nowPlayList = self.playlist // 재생할 영상이 속한 재생목록으로 재생목록 변경
                    self.isReady = false
                    self.clickVid = true
                    videoPlay = VideoPlay(videoId: playlist.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                    reloads = true
                    self.videoOrder = self.playlist.firstIndex(of: playlist) ?? -1
                    print("video order: ",videoOrder)
                    saveRecent(video: playlist)
                } label: {
                    ListView(Video: playlist)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        self.playlist.remove(at: self.playlist.firstIndex(of: playlist)!)
                        saveLists()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)

                }
                .disabled(!isReady)
            }
            VStack{}.frame(height: 70)
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 80)
        .navigationTitle(Text(listName))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack{
                    Button {
                        self.nowPlayList.append(contentsOf: playlist)
                    } label: {
                        Image(systemName: "text.insert")
                    }
                    .disabled(playlist.isEmpty)
                    Button {
                        self.nowPlayList = playlist
                        videoPlay = VideoPlay(videoId: nowPlayList.first!.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                        reloads = true
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .disabled(playlist.isEmpty)
                }
            }
        }
    }
}
