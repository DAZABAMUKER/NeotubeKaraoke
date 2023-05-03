//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI
import PythonKit

struct searcher: View{
    
   
    @State var showplayer = false
    @State var isEditing: Bool = false
    @State var likeModal: Bool = false
    @StateObject var models = Models()
    @StateObject var ytSearch = HTMLParser()
    @State var playlist = [playlists]()
    @State var ResponseItems = [Video]()
    @State var ytVideos = [LikeVideo]()
    @State var addVideo: LikeVideo!
    @State var lastNowPL = false
    @State var rightAfterNowPL = false
    @State var alreadyHave = false
    
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var tabIndex: TabIndex
    @Binding var vidFull: Bool
    @Binding var nowPlayList: [LikeVideo]
    @Binding var vidEnd: Bool
    @Binding var videoOrder: Int
    @Binding var isReady: Bool
    @Binding var resolution: Resolution
    @Binding var searching: Bool
    @Binding var inputVal: String
    @Binding var isLandscape: Bool
    @Binding var score: Int
    @Binding var recent: [LikeVideo]
    
    private let search: LocalizedStringKey = "Search"
    private let addToList: LocalizedStringKey = "Add to Playlist"
    private let lastList: LocalizedStringKey = "Add to last of now playing list"
    private let rANowPlaying: LocalizedStringKey = "Add right after to now playing"
    private let add: LocalizedStringKey = "Add"
    private let cancel: LocalizedStringKey = "Cancel"
    private let already: LocalizedStringKey = "Playlist already have this video."
    
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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                /*
                if models.isResponseitems {
                    VStack{}.onAppear(){
                        self.ResponseItems = models.responseitems
                        models.isResponseitems = false
                    }
                }
                 */
                
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
                                    BannerAd()
                                        .frame(width: geometry.size.width, height: 70)
                                    ForEach(self.ytVideos, id: \.videoId){ responseitems in
                                        Button {
                                            //videoPlay.closes = true
                                            if self.isReady {
                                                self.vidEnd = true
                                                self.isReady = false
                                                videoPlay = VideoPlay(videoId: responseitems.videoId, vidFull: $vidFull, vidEnd: $vidEnd, isReady: $isReady, resolution: $resolution, isLandscape: $isLandscape, score: $score)
                                                reloads = true
                                                //print("리로드")
                                                self.nowPlayList.append(LikeVideo(videoId: responseitems.videoId, title: responseitems.title, thumbnail: responseitems.thumbnail, channelTitle: responseitems.channelTitle))
                                                self.videoOrder = nowPlayList.count - 1
                                                saveRecent(video: responseitems)
                                            }
                                        } label: {
                                            ZStack{
                                                ListView(Video: responseitems)
                                                    .padding(.leading, 15)
                                                HStack(spacing: 0){
                                                    Spacer()
                                                    Image(systemName: "ellipsis")
                                                        .rotationEffect(Angle(degrees: 90))
                                                        .tint(.secondary)
                                                        .frame(width: 50, height: 70)
                                                        .background(.black.opacity(0.01))
                                                        .onTapGesture {
                                                            self.likeModal = true
                                                            self.addVideo = LikeVideo(videoId: responseitems.videoId, title: responseitems.title, thumbnail: responseitems.thumbnail, channelTitle: responseitems.channelTitle, runTime: responseitems.runTime)
                                                            print("long")
                                                        }
                                                }
                                            }
                                        }
                                        .disabled(!isReady)
                                    }
                                    BannerAd()
                                        .frame(width: geometry.size.width, height: 70)
                                    VStack{}
                                        .frame(height: 200)
                                }
                                .background(Color.black.opacity(0.6))
                            }
                            //.frame(width:geometry.size.width,height: geometry.size.height - 60)
                            .background(){
                                Image("clear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width)
                                    .opacity(0.3)
                            }
                            .padding(.top, -8)
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 80)
                            .preferredColorScheme(.dark)
                            //VStack{}.frame(height: 135).background(.red)
                        } else {
                            ZStack{
                                Image("clear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width)
                                    .padding(.top, -200)
                                    .opacity(0.3)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .preferredColorScheme(.dark)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    VStack{
                        HStack{
                            //MARK: - SearchBar
                            ZStack{
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                                    .font(.system(size: 50))
                                    .padding(.leading, 10)
                                    .padding(.bottom, 5)
                                    .rotationEffect(Angle(degrees: vidFull ? 360 : 0))
                                    .animation(.easeInOut, value: vidFull)
                                Image(systemName: "music.mic")
                                    .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                                    .font(.system(size: 25))
                                    .padding(.leading, 10)
                                    .padding(.bottom, 5)
                            }
                            .onAppear(){
                                openRecent()
                            }
                            TextField("", text: $inputVal, onEditingChanged: {isEditing = $0 })
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .background(border)
                                .foregroundColor(.white)
                                .padding(.trailing, 30)
                                .padding(.leading, 20)
                                .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: self.search))
                                .onSubmit {
                                    let _ = models.getVideos(val: inputVal)
                                    //getResults(val: inputVal)
                                    //loadytsr()
                                    //getSome()
                                    //self.ytSearch.search(value: self.inputVal)
                                }
                            
                            Button {
                                self.inputVal = ""
                            } label: {
                                if (self.inputVal.count > 0) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 20))
                                }
                            }
                        }
                        .onAppear(){
                            decodePList()
                        }
                        .background() {
                            Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1))
                                .edgesIgnoringSafeArea(.horizontal)
                                .frame(width: geometry.size.width)
                                .padding(.top, -geometry.safeAreaInsets.top)
                        }
                        Spacer()
                    }
                    if self.isEditing {
                        VStack{
                            Spacer()
                                .frame(height: 60)
                            VStack{}
                                .frame(width: geometry.size.width, height: geometry.size.height-60)
                                .background {
                                    Color.black.opacity(0.1)
                                }
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                    }
                    
                    //MARK: 재생목록 추가 뷰
                    if self.likeModal {
                        VStack(spacing: 0){
                            Text(self.addToList)
                                .padding(15)
                                .bold()
                                //.font(.title)
                            List {
                                Button {
                                    self.lastNowPL.toggle()
                                } label: {
                                    HStack{
                                        Text(self.lastList)
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
                                        Text(self.rANowPlaying)
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
                                } label: {
                                    Text(self.add)
                                        .padding(10)
                                }
                                Divider()
                                    .frame(width: 60,height: 50)
                                Button {
                                    self.likeModal = false
                                } label: {
                                    Text(self.cancel)
                                        .padding(10)
                                }
                            }
                        }
                        .frame(width: 300, height: 250)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    if self.alreadyHave {
                        VStack{
                            Text(self.already)
                                .padding(20)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
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
}

struct playlists: Hashable {
    var id = UUID()
    var name: String
    var isSelected: Bool = false
}
