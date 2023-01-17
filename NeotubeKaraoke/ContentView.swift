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
    @State var sheeet: Bool = false
    
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
    func changeColor(tabIndex: TabIndex) -> Color{
        switch tabIndex {
        case .Home:
            return Color.red
        case .Setting:
            return Color.white
        case .Profile:
            return Color.green
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
            }) {
            Image(systemName: img)
                .font(.system(size: 30))
                .scaleEffect(self.tabIndex == tabIndex ? 1.7 : 1.0)
                .foregroundColor(self.tabIndex == tabIndex ? changeColor(tabIndex: tabIndex) : Color.gray)
                .frame(width: geometry.size.width / 3, height: 50)
                .offset(y: self.tabIndex == tabIndex ? -5 : 0)
                .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
        }
        .background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                TabView(selection: $tabIndex) {
                    searcher()
                        .toolbar(.hidden, for: .tabBar)
                        .tag(TabIndex.Home)
                    Text("안녕하세요")
                        .tag(TabIndex.Profile)
                    Text("반가워요")
                        .tag(TabIndex.Setting)
                        .onTapGesture {
                            self.sheeet = true
                        }.sheet(isPresented: $sheeet) {
                            learn()
                        }
                }
                Circle()
                    .frame(width: 100)
                    .offset(x: self.CircleOffset(tabIndex: tabIndex, geometry: geometry), y: 25)
                    .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                    .animation(.easeInOut(duration: 0.25), value: self.tabIndex)
                    .shadow(radius: 10)

                HStack(spacing: 0) {
                    TabButtonSel(tabIndex: .Profile, img: "person.fill", geometry: geometry)
                    TabButtonSel(tabIndex: .Home, img: "music.mic", geometry: geometry)
                    TabButtonSel(tabIndex: .Setting, img: "gear", geometry: geometry)
                    
                }.preferredColorScheme(.light)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tabIndex: .Home)
    }
}
