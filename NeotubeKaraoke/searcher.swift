//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View{
    

    
    @State private var inputVal: String = ""
    @State private var isEditing: Bool = false
    
    @StateObject var models = Models()
    
    @State var ResponseItems = [Video]()
    
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                //let _ = models.getVideos()
                Image("background")
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                LinearGradient(gradient: .init(
                    colors: [
                      Color(UIColor(red: 0, green: 0, blue: 0, alpha: 1.00)),
                      Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.00))
                    ]
                  ),
                  startPoint: .bottom,
                  endPoint: .top
                ).edgesIgnoringSafeArea(.all)
                
                
                NavigationView {
                    VStack{
                        //MARK: - SearchBar
                        HStack{
                            Image(systemName: "music.mic.circle")
                                .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                                //.foregroundColor(Color.white)
                                .font(.system(size: 50))
                                .padding(.leading, 10)
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
                            .background(
                                Rectangle()
                                    .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)))
                                    .frame(width: geometry.size.width, height: 120)
                                    .edgesIgnoringSafeArea(.all)
                                    .shadow(radius: 10)
                        )
                        //MARK: - 리스트
                        if models.responseitems.count == 0 {
                            List(self.ResponseItems, id: \.videoID){ responseitems in
                                NavigationLink(destination: VideoPlay(videoId: responseitems.videoID)) {
                                    //TableCell(Video: responseitems)
                                    Text("nil")
                                }
                            }
                            .background(Color.black)
                            .scrollContentBackground(.hidden)
                            .listRowBackground(Color.yellow)
                            .padding(.top, -8)
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 80)
                            .preferredColorScheme(.dark)
                        } else {
                            List(models.responseitems, id: \.videoID){ responseitems in
                                NavigationLink(destination: VideoPlay(videoId: responseitems.videoID)) {
                                    TableCell(Video: responseitems)
                                        .onAppear(){
                                            self.ResponseItems = models.responseitems
                                        }
                                }
                            }
                            .background(Color.black)
                            .scrollContentBackground(.hidden)
                            .listRowBackground(Color.yellow)
                            .padding(.top, -8)
                            .listStyle(.plain)
                            .environment(\.defaultMinListRowHeight, 80)
                            .preferredColorScheme(.dark)
                        }
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
                    ]
                ),
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing
                ),
                              lineWidth: isEditing ? 4 : 2
                )
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
