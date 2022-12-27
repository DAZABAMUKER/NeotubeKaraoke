//
//  ContentView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    
    enum TabIndex {
        case Home
        case Setting
        case Profile
    }
    
    @State var tabIndex: TabIndex
    @State var LargerScale: CGFloat = 1.5
    
    var model = Model()
    
    func changeView(tabIndex: TabIndex) -> NaviView{
        switch tabIndex {
        case .Home:
            return NaviView(title: "홈")
            //return MyWebView(UrlTOLoad: "https://www.youtube.com")
        case .Profile:
            return NaviView(title: "프로필")
            //return MyWebView(UrlTOLoad: "https://www.google.com")
        case .Setting:
            return NaviView(title: "설정")
            //return MyWebView(UrlTOLoad: "https://www.daum.net")
        }
    }
    
    func CircleOffset(tabIndex: TabIndex, geometry: GeometryProxy) -> CGFloat {
        switch tabIndex {
        case .Profile:
            return -geometry.size.width / 3
        case .Home:
            return 0
        case .Setting:
            return geometry.size.width / 3
        }
    }
    
    func TabButtonSel(tabIndex: TabIndex, img: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            print("click")
            self.tabIndex = tabIndex
            withAnimation{self.tabIndex = tabIndex
            }}) {
            Image(systemName: img)
                .font(.system(size: 30))
                .scaleEffect(self.tabIndex == tabIndex ? self.LargerScale : 1.0)
                .foregroundColor(self.tabIndex == tabIndex ? Color.red : Color.gray)
                .frame(width: geometry.size.width / 3, height: 50)
                .offset(y: self.tabIndex == tabIndex ? -5 : 0)
        }
        .background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
    }
    
    
    var body: some View {
        let _ = model.getVideos()
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                changeView(tabIndex: self.tabIndex)
                /*
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.bottom + 60)
                    .offset(y: geometry.safeAreaInsets.bottom)
                    .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                    .shadow(radius: 10)
                 */
                TabView(selection: $tabIndex) {
                    searcher()
                    NaviView(title: "profile")
                        .tag(TabIndex.Profile)
                    NaviView(title: "setting")
                        .tag(TabIndex.Setting)
                }
                Circle()
                    .frame(width: 100)
                    .offset(x: self.CircleOffset(tabIndex: tabIndex, geometry: geometry), y: 25)
                    .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                    .animation(.easeOut)
                    .shadow(radius: 10)

                HStack(spacing: 0) {
                    TabButtonSel(tabIndex: .Profile, img: "person.fill", geometry: geometry)
                    TabButtonSel(tabIndex: .Home, img: "music.mic", geometry: geometry)
                    TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tabIndex: .Home)
    }
}
