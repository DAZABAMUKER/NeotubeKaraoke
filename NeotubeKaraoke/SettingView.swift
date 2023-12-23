//
//  SettingView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/06.
//

import SwiftUI
import AVKit
import StoreKit

enum Resolution {
    case basic
    case high
    case ultra
    case low
}
enum Karaoke {
    case Tj
    case KY
}

struct SettingView: View {
    
    @AppStorage("micPermission") var micPermission: Bool = UserDefaults.standard.bool(forKey: "micPermission")
    @AppStorage("moveFrameTime") var goBackTime: Double = UserDefaults.standard.double(forKey: "moveFrameTime")
    
    @State var showAlert = false
    @State var sheet = false
    @State var profile = false
    @State var isEditing: Bool = false
    @StateObject private var getPopularChart = GetPopularChart()
    @State var refund = false
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    private let pasteboard = UIPasteboard.general
    
    //@Environment(\.colorScheme) var colorschome
    @Binding var colorMode: String
//    @Binding var colorSchemeOfSystem: ColorScheme
    
    
    
    
    var body: some View {
        VStack{
            if self.micPermission {
                VStack{}.onAppear(){
                    AVAudioSession.sharedInstance().requestRecordPermission { (status) in
                        if !status {
                            self.micPermission = false
                            self.showAlert = true
                        } else {
                            self.micPermission = true
                        }
                    }
                }
            }
            
            if !entitlementManager.hasPro {
                BannerAd()
                    .frame(height: 60)
            }
            List{
                Section {
                    VStack{
                        if entitlementManager.hasPro {
                            Text("헉!! 감동이에요! 🥰")
                                .font(.title3)
                            Button {
                                self.refund = true
                            } label: {
                                HStack{
                                    Spacer()
                                    Image(systemName: "shippingbox.and.arrow.backward.fill")
                                    Text("환불하기")
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(lineWidth: 3)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 50)
                                        .padding(.vertical, -10)
                                }
                                .padding(5)
                            }
                            .sheet(isPresented: $refund) {
                                MakeRefund(products: purchaseManager.products)
                            }
                        } else {
                            ForEach(purchaseManager.products) { product in
                                Button {
                                    Task{
                                        do {
                                            try await purchaseManager.purchase(product)
                                        }
                                        catch {
                                            print(#function, error)
                                        }
                                    }
                                } label: {
                                    if purchaseManager.products.isEmpty {
                                        Text("로딩중이에요. 잠시만 기다려주세요.")
                                    } else {
                                        HStack{
                                            Image(systemName: "video.slash.fill")
                                            //.foregroundColor(.white)
                                            Text(product.displayName)
                                            //.foregroundColor(.white)
                                            Spacer()
                                            HStack{
                                                Text(product.displayPrice)
                                                //.foregroundColor(.white)
                                            }
                                            .padding(5)
                                            .padding(.horizontal, 10)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(lineWidth: 2)
                                                //.foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                            HStack{
                                Image(systemName: "checkmark.circle")
                                Text("구매 복원하기")
                                Spacer()
                                Button {
                                    Task{
                                        do {
                                            try await AppStore.sync()
                                        }
                                        catch {
                                            print("구매복원 오류: ", error)
                                        }
                                    }
                                } label: {
                                    HStack{
                                        Image(systemName: "cart.fill")
                                        Text("구매 복원하기")
                                    }
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(lineWidth: 2)
                                        //.foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }.task {
                        do {
                            try await purchaseManager.loadProducts()
                        }
                        catch {
                            print("Loading Store Info error: ", error)
                        }
                    }
                } header: {
                    Text("광고 제거하기")
                }
                VStack {
                    Picker("해상도 선택", selection: $resolution) {
                        Text("Low").tag(Resolution.low)
                        Text("Basic").tag(Resolution.basic)
                        Text("1080").tag(Resolution.high)
                        Text("1080+").tag(Resolution.ultra)
                    }
                    .pickerStyle(.menu)
                    .tint(Color.orange)
                    Picker("영상 건너뛰기 시간 선택", selection: $goBackTime) {
                        Text("5s").tag(5.0)
                        Text("15s").tag(15.0)
                        Text("30s").tag(30.0)
                        Text("60s").tag(60.0)
                    }
                    .pickerStyle(.menu)
                    .tint(Color.orange)
                    Picker("다크모드", selection: $colorMode) {
                        Text("다크모드").tag("dark")
                        Text("라이트모드").tag("light")
                        Text("Auto").tag("auto")
                    }
                    .pickerStyle(.menu)
                    .tint(Color.orange)
                    Toggle(isOn: $micPermission) {
                        Text("내 노래 점수 보기")
                    }
                    .tint(Color.orange)
                    .alert(Text("마이크 접근을 허용해주세요."), isPresented: $showAlert) {
                        Button {
                            self.showAlert = false
                            self.micPermission = false
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("확인")
                        }
                        
                        Button {
                            self.showAlert = false
                            self.micPermission = false
                        } label: {
                            Text("취소")
                        }
                    }
                }
                
                
                
                Section{
                    //                        Button {
                    //                            self.showCheer.toggle()
                    //                        } label: {
                    //                            Text(self.cheer)
                    //                        }
                    //                        
                    VStack(alignment: .leading, spacing: 10){
                        HStack{
                            Text("앱 버전")
                            Spacer()
                            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                        }
                        Button{
                            self.profile = true
                        } label: {
                            Text("문의 하기")
                                //.foregroundStyle(.orange)
                        }
                        .sheet(isPresented: $profile) {
                            profileView
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                        }
                        Button {
                            
                        } label: {
                            Text("앱 사용 법")
                                //.foregroundStyle(.orange)
                        }
                        
                    }
                } header: {
                    Text("Contact")
                }
            }
            .listStyle(.plain)
        }
    }
    var profileView: some View {
        VStack(spacing: 10){
            Image("me")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .background(.white)
                .clipShape(Circle())
                .padding(5)
                .background{
                    Circle()
                        .stroke(lineWidth: 3.0)
                        .foregroundStyle(.orange)
                }
            
            Button {
                pasteboard.string = "wookis112@gmail.com"
            } label: {
                HStack{
                    Text("이메일: ")
                    Spacer()
                    Text(verbatim: "wookis112@gmail.com")
                    Image(systemName: "rectangle.on.rectangle")
                        .padding(.horizontal)
                }
                .foregroundStyle(.foreground)
            }
            .padding(.horizontal)
            Button {
                pasteboard.string = "Dazabamuker"
            } label: {
                HStack{
                    Text("카카오톡 ID:")
                    Spacer()
                    Text("Dazabamuker")
                    Image(systemName: "rectangle.on.rectangle")
                        .padding(.horizontal)
                }
                .foregroundStyle(.foreground)
            }
            .padding(.horizontal)
            Button {
                UIApplication.shared.open(URL(string: "https://dazabamuker.github.io/web-porfolio/")!)
            } label: {
                Text("개발자 포트폴리오")
                    .foregroundStyle(.background)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background{
                        RoundedRectangle(cornerRadius: 20)
                    }
            }
            .padding(.horizontal)
            .foregroundStyle(.foreground)
        }
    }
    
    
}
