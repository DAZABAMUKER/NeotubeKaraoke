//
//  SettingView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/06.
//

import SwiftUI

enum Resolution {
    case basic
    case high
    case ultra
}

struct SettingView: View {
    @State var sheet = false
    @State var profile = false
    @Binding var resolution: Resolution
    
    private let pasteboard = UIPasteboard.general
    
    private let devProfile: LocalizedStringKey = "Developer Profile"
    private let devBlog: LocalizedStringKey = "Developer's Blog"
    private let contact: LocalizedStringKey = "If you have any questions or requests from the developer, please contact us via email or blog on my profile"
    private let someone: LocalizedStringKey = "A paper-making university student developer"
    private let email: LocalizedStringKey = "Email: "
    private let kakaotalk: LocalizedStringKey = "KakaoTalk ID: "
    private let titleOfResolution: LocalizedStringKey = "Select prefer resolution"
    private let ifHigher: LocalizedStringKey = "If you select a resolution higher than 1080 rather than Basic, the loading time may increase."
    private let rmAds: LocalizedStringKey = "Remove Ads"
    
    var body: some View {
        NavigationStack{
            VStack{
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
                    VStack {
                        Text(self.titleOfResolution)
                            .bold()
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(0)
                        Picker("해상도 선택", selection: $resolution) {
                            Text("Basic").tag(Resolution.basic)
                            Text("1080").tag(Resolution.high)
                            Text("1080+").tag(Resolution.ultra)
                        }
                        .pickerStyle(.segmented)
                        Text(self.ifHigher)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    
                }
                Button {
                    
                } label: {
                    HStack{
                        Text(self.rmAds)
                            .foregroundColor(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 300, height: 50)
                            }
                    }
                }
                Spacer()
                    .frame(height: 100)
            }.preferredColorScheme(.dark)
        }
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
