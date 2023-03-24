//
//  PlayListView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/07.
//

import SwiftUI

struct PlayListView: View {
    
    //MARK: - PlayListView 변수
    @State var plusPlayList: Bool = false
    @State var pTitle: String = ""
    @State var playlist = [String]()
    
    @Binding var nowPlayList: [LikeVideo]
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var vidFull: Bool
    @Binding var vidEnd: Bool
    @Binding var videoOrder: Int
    
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
                    Text("Recent")
                        .bold()
                        .font(.title)
                        .padding(5)
                    ScrollView(.horizontal){
                        HStack{
                            VStack{
                                ZStack{
                                    Image(systemName: "music.note.list")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .padding(20)
                                        .background(.green)
                                    //.opacity(0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .rotationEffect(.degrees(-15))
                                    Image(systemName: "music.note.list")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .padding(20)
                                        .background(.orange)
                                    //.opacity(0.5)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .rotationEffect(.degrees(-5))
                                    //.padding(20)
                                    Image(systemName: "music.note.list")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .padding(20)
                                        .background(.linearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .rotationEffect(.degrees(10))
                                        .padding(20)
                                }
                                Text("현재 재생목록")
                            }
                            Button {
                                if !self.nowPlayList.isEmpty {
                                    videoPlay = VideoPlay(videoId: nowPlayList[0].videoId, vidFull: $vidFull, vidEnd: $vidEnd)
                                } else {
                                    print("재생할 음악 없음.")
                                }
                            } label: {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .tint(.white)
                                    .padding()
                            }
                        }
                    }
                    
                    //MARK: 재생목록 리스트
                    LinearGradient(colors: [Color.white, Color.secondary.opacity(0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width, height: 1)
                    Text("생성된 재생목록")
                        .font(.title3)
                        .bold()
                        .padding( 5)
                    LinearGradient(colors: [Color.white, Color.secondary.opacity(0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width, height: 1)
                    NavigationView{
                        List{
                            ForEach(self.playlist, id: \.self) { item in
                                //TableCell(Video: video)
                                NavigationLink {
                                    showList(listName: item, nowPlayList: $nowPlayList, videoPlay: $videoPlay, reloads: $reloads, vidFull: $vidFull, vidEnd: $vidEnd, videoOrder: $videoOrder) // 해당 재생목록 영상 리스트 뷰로 이동
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
                    VStack(spacing: 0){
                        Text("재생목록 추가")
                            .font(.title2)
                            .padding()
                        //Divider()
                        TextField("타이틀을 입력하세요", text: $pTitle)
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
                                Text("확인")
                            }
                            .padding()
                            Divider()
                                .frame(width: 60,height: 50)
                            Button {
                                self.plusPlayList = false
                                self.pTitle = ""
                            } label: {
                                Text("취소")
                            }
                            .padding()
                        }
                    }
                    .frame(width: 300)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15))
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
    let thumnail: String
    let channelTitle: String
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
                let myData = try? decoder.decode([LikeVideo].self, from: js as Data)
                self.playlist = myData!
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
                    videoPlay = VideoPlay(videoId: playlist.videoId, vidFull: $vidFull, vidEnd: $vidEnd)
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
                        self.nowPlayList = playlist
                    } label: {
                        Image(systemName: "shuffle")
                    }
                    Button {
                        self.nowPlayList = playlist
                    } label: {
                        Image(systemName: "play.fill")
                    }
                }
            }
        }
    }
}
