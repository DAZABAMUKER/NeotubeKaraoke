//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View{
    
    @State var showplayer = false
    @State var inputVal: String = ""
    @State var isEditing: Bool = false
    @State var likeModal: Bool = false
    @StateObject var models = Models()
    @State var playlist = [playlists]()
    @State var ResponseItems = [Video]()
    @State var addVideo: LikeVideo!
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var tabIndex: TabIndex
    @Binding var vidFull: Bool
    
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
    
    func getLike() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("playlist", conformingTo: .json)
        
    }
    
    func addVideoToPlist(item: LikeVideo, listName: String) {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("\(listName)", conformingTo: .json)
        print(fileurl)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path()) {
                guard let js = NSData(contentsOf: fileurl) else { return }
                let decoder = JSONDecoder()
                var myData = try? decoder.decode([LikeVideo].self, from: js as Data)
                print(myData?.count ?? 0)
                myData?.append(item)
                print(myData?.count ?? 0)
                try FileManager.default.removeItem(at: fileurl)
                let data = try JSONEncoder().encode(myData)
                FileManager.default.createFile(atPath: fileurl.path(), contents: data)
            } else {
                let myData = [item]
                let data = try JSONEncoder().encode(myData)
                FileManager.default.createFile(atPath: fileurl.path(), contents: data)
            }
        }
        catch {
            print(error)
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                if models.isResponseitems {
                    VStack{}.onAppear(){
                        self.ResponseItems = models.responseitems
                        models.isResponseitems = false
                    }
                }
                ZStack{
                    VStack(spacing: 9){
                        //MARK: - SearchBar
                        HStack{
                            Image(systemName: "music.mic.circle")
                                .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                                .font(.system(size: 50))
                                .padding(.leading, 10)
                                .padding(.bottom, 5)
                            TextField("", text: $inputVal, onEditingChanged: {isEditing = $0 })
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .background(border)
                                .foregroundColor(.white)
                                .padding(.trailing, 30)
                                .padding(.leading, 20)
                                .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: "검색"))
                                .onSubmit {
                                    let _ = models.getVideos(val: inputVal)
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
                        
                        //MARK: - 아이패드인지 디비이스 확인
                        .background() {
                            if UIDevice.current.model == "iPad" {
                                Color(UIColor(red: 71/255, green: 60/255, blue: 51/255, alpha: 1))
                                    .padding(.top, -geometry.safeAreaInsets.top)
                            } else {
                                Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1))
                                    .padding(.top, -geometry.safeAreaInsets.top)
                            }
                        }
                        //MARK: - 리스트
                        List(self.ResponseItems, id: \.videoID){ responseitems in
                            /*
                             NavigationLink(destination: videoPlay) {
                             TableCell(Video: responseitems)
                             //Text("nil")
                             }
                             */
                            Button {
                                //videoPlay.closes = true
                                videoPlay = VideoPlay(videoId: responseitems.videoID, vidFull: $vidFull)
                                reloads = true
                                print("리로드")
                                
                            } label: {
                                ZStack{
                                    TableCell(Video: responseitems)
                                    HStack(spacing: 0){
                                        Spacer()
                                        Image(systemName: "ellipsis")
                                            .rotationEffect(Angle(degrees: 90))
                                            .tint(.secondary)
                                            .frame(width: 50, height: 70)
                                            .background(.black.opacity(0.01))
                                            .onTapGesture {
                                                self.likeModal = true
                                                self.addVideo = LikeVideo(videoId: responseitems.videoID, title: responseitems.title, thumnail: responseitems.thumbnail, channelTitle: responseitems.channelTitle)
                                                print("long")
                                            }
                                    }
                                }
                            }
//                            .onLongPressGesture {
//                                print("long")
//                                self.likeModal = true
//                            }
                            //.background(.blue)
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
                        // 검색결과 없을 경우 Alert 띄음.
                        .alert(isPresented: $models.nothings) {
                            Alert(title: Text(models.stsCode == 0 ? "검색결과 없음." : models.stsCode == 403 ? "Quota Exceeded Error" : String(models.stsCode)+" Error"))
                        }
                        VStack{}.frame(height: 135).background(.red)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    
                    //MARK: 재생목록 추가 뷰
                    if self.likeModal {
                        VStack(spacing: 0){
                            Text("재생목록에 추가하기")
                                .padding(10)
                                .font(.title2)
                            List {
                                Text("현재 재생목록 마지막에 추가")
                                    .listRowBackground(Color.black.opacity(0.5))
                                Text("현재 노래 다음에 추가")
                                    .listRowBackground(Color.black.opacity(0.5))
                                ForEach(0..<self.playlist.count) { i in
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
                                } label: {
                                    Text("추가")
                                        .padding(10)
                                }
                                Divider()
                                    .frame(width: 60,height: 50)
                                Button {
                                    self.likeModal = false
                                } label: {
                                    Text("닫기")
                                        .padding(10)
                                }
                            }
                        }
                        .frame(width: 300, height: 250)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
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
