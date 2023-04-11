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
    @State var showTjChart = false // tj 노래방 차트
    @State var showKYChart = false // 금영 노래방 차트
    @Binding var nowPlayList: [LikeVideo]
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var inputVal: String
    @Binding var searching: Bool
    @Binding var isLandscape: Bool
    @StateObject private var getPopularChart = GetPopularChart()
    
    private let showNowPlaying: LocalizedStringKey = "Show now playing list"
    private let nowPlaying: LocalizedStringKey = "Now Playing List"
    private let createdList: LocalizedStringKey = "Created Playlist"
    private let addList: LocalizedStringKey = "Add Playlist"
    private let inputTilte: LocalizedStringKey = "Input your playlist title"
    private let OK: LocalizedStringKey = "OK"
    private let cancel: LocalizedStringKey = "Cancel"
    private let KY: LocalizedStringKey = "KY karaoke Top 100"
    private let Tj: LocalizedStringKey = "Tj karaoke Top 100"
    
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
                                .foregroundColor(.orange)
                        }
                    }
                    .background(.indigo.opacity(0.3))
                    
                    //MARK: 최근 재생목록
                    Text(self.showNowPlaying)
                        .bold()
                        .font(.title)
                        .padding(5)
                    ScrollView(.horizontal){
                        HStack{
                            
                            Button {
                                self.showNowPL.toggle()
                                self.showKYChart = false
                                self.showTjChart = false
                            } label: {
                                VStack{
                                    Image("playlist")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                    Text(self.nowPlaying)
                                }
                            }
                            .disabled(PLAppear)
                            Button {
                                getPopularChart.tjKaraoke()
                                showTjChart.toggle()
                                self.showKYChart = false
                                self.showNowPL = false
                            } label: {
                                VStack{
                                    Image("tjKaraoke")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                    Text(self.Tj)
                                }
                            }
                            Button {
                                getPopularChart.KYKaraoke()
                                showKYChart.toggle()
                                self.showTjChart = false
                                self.showNowPL = false
                            } label: {
                                VStack{
                                    Image("KYkaraoke")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .frame(height: 100)
                                    Text(self.KY)
                                }
                            }
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
                        if showNowPL || showTjChart || showKYChart {
                            Button {
                                self.showNowPL = false
                                self.showKYChart = false
                                self.showTjChart = false
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
                        if showNowPL {
                            List {
                                ForEach(nowPlayList, id: \.self) { list in
                                    Button {
                                        self.isReady = false
                                        videoPlay = VideoPlay(videoId: list.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape)
                                        reloads = true
                                        self.videoOrder = self.nowPlayList.firstIndex(of: list) ?? -1
                                        print("video order: ",videoOrder)
                                    } label: {
                                        ListView(Video: list)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            print("제거")
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
                        } else if showTjChart {
                            List{
                                ForEach(0..<getPopularChart.tjChartTitle.count, id: \.self) { index in
                                    Button {
                                        self.inputVal = "\(getPopularChart.tjChartTitle[index]) \(getPopularChart.tjChartMusician[index]) tj 노래방"
                                        self.searching = true
                                    } label: {
                                        LinearGradient(colors: [
                                            Color(red: 1, green: 112 / 255.0, blue: 0),
                                            Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                                        ],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing
                                        )
                                        .frame(width: geometry.size.width, height: 30)
                                        .mask(alignment: .center) {
                                            HStack{
                                                Text(String(index + 1))
                                                Text(getPopularChart.tjChartTitle[index])
                                                Spacer()
                                                Text(getPopularChart.tjChartMusician[index])
                                            }
                                            .bold()
                                        }
                                    }
                                }
                                VStack{}.frame(height: 70)
                            }
                            .listStyle(.plain)
                        } else if showKYChart {
                            List{
                                ForEach(0..<getPopularChart.KYChartTitle.count, id: \.self) { index in
                                    Button {
                                        self.inputVal = "\(getPopularChart.KYChartTitle[index]) \(getPopularChart.KYChartMusician[index]) 금영"
                                        self.searching = true
                                    } label: {
                                        LinearGradient(colors: [
                                            Color(red: 1, green: 112 / 255.0, blue: 0),
                                            Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                                        ],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing
                                        )
                                        .frame(width: geometry.size.width, height: 30)
                                        .mask(alignment: .center) {
                                            HStack{
                                                Text(String(index + 1))
                                                Text(getPopularChart.KYChartTitle[index])
                                                Spacer()
                                                Text(getPopularChart.KYChartMusician[index])
                                            }
                                            .bold()
                                        }
                                    }
                                }
                                VStack{}.frame(height: 70)
                            }
                            .listStyle(.plain)
                        } else {
                            List{
                                ForEach(self.playlist, id: \.self) { item in
                                    //TableCell(Video: video)
                                    NavigationLink {
                                        showList(listName: item, nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, videoOrder: $videoOrder, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape) // 해당 재생목록 영상 리스트 뷰로 이동
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
                }
            }
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
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    
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
                    videoPlay = VideoPlay(videoId: playlist.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape)
                    reloads = true
                    self.videoOrder = self.playlist.firstIndex(of: playlist) ?? -1
                    print("video order: ",videoOrder)
                } label: {
                    ListView(Video: playlist)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        print("제거")
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
                        videoPlay = VideoPlay(videoId: nowPlayList.first!.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape)
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
