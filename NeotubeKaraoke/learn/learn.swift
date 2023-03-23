//
//  learn.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI

struct learn: View {
    
    @State
    private var isActivated: Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack{
                HStack{
                    MYVStack(BActivated: $isActivated)
                    MYVStack(BActivated: $isActivated)
                    MYVStack(BActivated: $isActivated)
                }
                .padding(isActivated ? 30.0 : 10.0)
                .background(isActivated ? Color.yellow : Color.orange)
                .onTapGesture {
                    print("클릭됌")
                    withAnimation {
                        self.isActivated.toggle()
                    }
                }
                NavigationLink(destination: NaviView(BActivated: $isActivated)) {
                    Text("페이지 이동!")
                }
                .padding(20)
                .fontWeight(.heavy)
                .font(.system(size: 30))
                .background(Color.yellow)
                .foregroundColor(Color.white)
                .cornerRadius(30)
//                HStack{
//                    NavigationLink(destination: MyWebView(UrlTOLoad: "https://www.naver.com"){
//                        Text("네이버")
//                            .background(Color.green)
//                            //.padding(.top,10)
//                            .cornerRadius(20)
//                            .fontWeight(.bold)
//                            .font(.system(size: 30))
//                            .foregroundColor(Color.white)
//                    }
//                    NavigationLink(destination: MyWebView(UrlTOLoad: "https://www.google.com")) {
//                        Text("구글")
//                            .background(Color.blue)
//                            //.padding(.all,0)
//                            .cornerRadius(20)
//                            .fontWeight(.bold)
//                            .font(.system(size: 30))
//                            .foregroundColor(Color.white)
//                    }
//                    NavigationLink(destination: MyWebView(UrlTOLoad: "https://www.youtube.com")) {
//                        Text("유튜브")
//                            .background(Color.red)
//                            //.padding(.all,0)
//                            .cornerRadius(20)
//                            .fontWeight(.bold)
//                            .font(.system(size: 30))
//                            .foregroundColor(Color.white)
//                    }
//                    
//                }
            }
        }
        
    }
}


struct learn_Previews: PreviewProvider {
    static var previews: some View {
        learn()
    }
}
