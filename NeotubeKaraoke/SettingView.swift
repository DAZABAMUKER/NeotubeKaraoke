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
    var body: some View {
        NavigationStack{
            List{
                Section{
                    Button{
                        self.profile = true
                    } label: {
                        Text("Developer Profile")
                    }
                    .sheet(isPresented: $profile) {
                        profileView
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                    Button {
                        self.sheet = true
                    } label: {
                        Text("Developer's Blog")
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
                    Text("개발자에게 질문이 있거나 요청이 있으시면 프로필의 이메일을 통하거나 블로그를 통해 연락하십시오.")
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
            
            Text("종이만드는 비전공 대학생 개발자")
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            Button {
                pasteboard.string = "wookis112@gmail.com"
            } label: {
                HStack{
                    Text("이메일: ")
                        .bold()
                    Text("wookis112@gmail.com")
                    Image(systemName: "rectangle.on.rectangle")
                }.tint(.white)
            }
            Button {
                pasteboard.string = "Dazabamuker"
            } label: {
                HStack{
                    Text("카카오톡 아이디: ")
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
