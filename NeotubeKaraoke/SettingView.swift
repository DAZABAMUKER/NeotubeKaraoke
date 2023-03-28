//
//  SettingView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/06.
//

import SwiftUI

struct SettingView: View {
    @State var sheet = false
    @State var profile = false
    
    private let pasteboard = UIPasteboard.general
    
    private let devProfile: LocalizedStringKey = "Developer Profile"
    private let devBlog: LocalizedStringKey = "Developer's Blog"
    private let contact: LocalizedStringKey = "If you have any questions or requests from the developer, please contact us via email or blog on my profile"
    private let someone: LocalizedStringKey = "A paper-making university student developer"
    private let email: LocalizedStringKey = "Email: "
    private let kakaotalk: LocalizedStringKey = "KakaoTalk ID: "
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    Button{
                        self.profile = true
                    } label: {
                        Text(self.devProfile)
                    }
                    .sheet(isPresented: $profile) {
                        profileView
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                    Button {
                        self.sheet = true
                    } label: {
                        Text(self.devBlog)
                    }
                    .sheet(isPresented: $sheet) {
                        MyWebView(UrlTOLoad: "https://dazabamuker.tistory.com")
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
                } header: {
                    Text("Contact")
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                } footer: {
                    Text(self.contact)
                }
            }
        }.preferredColorScheme(.dark)
    }
    
    var profileView: some View {
        VStack(spacing: 10){
            Image("me")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .background(content: {
                    Color.white
                })
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text(self.someone)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            Button {
                pasteboard.string = "wookis112@gmail.com"
            } label: {
                HStack{
                    Text(self.email)
                        .bold()
                    Text("wookis112@gmail.com")
                    Image(systemName: "rectangle.on.rectangle")
                }.tint(.white)
            }
            Button {
                pasteboard.string = "Dazabamuker"
            } label: {
                HStack{
                    Text(self.kakaotalk)
                        .bold()
                    Text("Dazabamuker")
                    Image(systemName: "rectangle.on.rectangle")
                }.tint(.white)
            }
            
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
