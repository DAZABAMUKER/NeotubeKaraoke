//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View {
    
    @State private var inputVal: String = ""
    @State private var isEditing: Bool = false
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack{
                Image("background")
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                LinearGradient(gradient: .init(
                    colors: [
                      Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)),
                      Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.00))
                    ]
                  ),
                  startPoint: .bottom,
                  endPoint: .top
                ).edgesIgnoringSafeArea(.all)
/*
                VStack{
                    Rectangle()
                        .frame(height: 120)
                        .edgesIgnoringSafeArea(.all)
                        .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        .shadow(radius: 10)
                    Spacer()
                }
                VStack{
                    Circle()
                        .frame(width: 80)
                        //.foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        .foregroundColor(Color.gray)
                        .shadow(radius: 10)
                        .offset(x:-170,y:-12)
                    Spacer()
                }*/
                VStack{
                    HStack{
                        Image(systemName: "music.mic.circle")
                            .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                            //.foregroundColor(Color.white)
                            .font(.system(size: 50))
                        TextField("", text: $inputVal, onEditingChanged: {isEditing = $0 })
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .background(border)
                            .foregroundColor(.white)
                            .padding(.trailing, 30)
                            .padding(.leading, 30)
                            .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: "검색"))
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
                            .frame(width: geometry.size.width, height: 120)
                            //.offset(y: -geometry.safeAreaInsets.bottom+10)
                            .edgesIgnoringSafeArea(.all)
                            .shadow(radius: 10)
                        
                    )
                    //.padding(.horizontal,-20)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                //.background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
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
