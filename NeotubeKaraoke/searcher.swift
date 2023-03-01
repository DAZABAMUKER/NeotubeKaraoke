//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View{
    
    
    @State var vidId: String = ""
    @State var showplayer = false
    @State var inputVal: String = ""
    @State var isEditing: Bool = false
    
    @StateObject var models = Models()
    
    @State var ResponseItems = [Video]()
    
    @Binding var TBisOn: Bool
    @Binding var videoPlay: VideoPlay
    @Binding var reloads: Bool
    @Binding var tabIndex: TabIndex
    
    
    
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
                    VStack(spacing: 0){
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
                                .onAppear(){
                                    if TBisOn == false {
                                        TBisOn = true
                                    }
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
                                /*
                                videoPlay.closes = true
                                videoPlay = VideoPlay(videoId: responseitems.videoID)
                                reloads = true
                                tabIndex = .Profile
                                 */
                                self.vidId = responseitems.videoID
                            } label: {
                                TableCell(Video: responseitems)
                            }
                            
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
                        VStack{}.frame(height: 60).background(.red)
                    }
                    VideoPlay(videoId: self.vidId)
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
