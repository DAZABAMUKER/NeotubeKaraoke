//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View{
    

    
    @State var inputVal: String = ""
    @State var isEditing: Bool = false
    
    @StateObject var models = Models()
    
    @State var ResponseItems = [Video]()
    
    
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geometry in
                VStack{
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
                    if models.responseitems.isEmpty {
                        List(self.ResponseItems, id: \.videoID){ responseitems in
                            NavigationLink(destination: VideoPlay(videoId: responseitems.videoID)) {
                                TableCell(Video: responseitems)
                                //Text("nil")
                            }
                            //.background(.blue)
                        }
                        .frame(width:geometry.size.width,height: geometry.size.height - 60)
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
                    } else {
                        List(models.responseitems, id: \.videoID){ responseitems in
                            NavigationLink(destination: VideoPlay(videoId: responseitems.videoID)) {
                                TableCell(Video: responseitems)
                                //Text("nil")
                                    .onAppear(){
                                        self.ResponseItems = models.responseitems
                                        
                                    }
                            }
                            //.background(Color.blue)
                        }
                        .frame(width:geometry.size.width,height: geometry.size.height - 60)
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
struct searcher_Previews: PreviewProvider {
    static var previews: some View {
        searcher()
    }
}
