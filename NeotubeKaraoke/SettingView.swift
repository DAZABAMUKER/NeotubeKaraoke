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
    @State var ment = ""
    @State var isEditing: Bool = false
    @StateObject private var getPopularChart = GetPopularChart()
    @State var isAnimation = false
    @State var cheerColor = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.indigo, Color.purple]
    @State var colorIndex = 0
    @State var refund = false
    @State var audioManager = AudioManager()
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    private let pasteboard = UIPasteboard.general
    
    @Environment(\.colorScheme) var colorschome
    
    func rotateLandscape() {
        if !isLandscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.isLandscape = true
            } else {
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = true
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.isLandscape = false
            } else {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isLandscape = false
            }
        }
    }
    
    func chageColor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (self.cheerColor.count == colorIndex + 1) {
                self.colorIndex = 0
            } else {
                self.colorIndex += 1
            }
            chageColor()
        }
    }
    
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
                                                RoundedRectangle(cornerRadius: 20)
                                                    .strokeBorder(lineWidth: 3)
                                                //.foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                            HStack{
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
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(lineWidth: 3)
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
                
                Section{
                    //                        Button {
                    //                            self.showCheer.toggle()
                    //                        } label: {
                    //                            Text(self.cheer)
                    //                        }
                    //                        .sheet(isPresented: $showCheer) {
                    //                            cheerView
                    //                                .onAppear(){
                    //                                    self.audioManager.setEngine(file: Bundle.main.url(forResource: "clap", withExtension: "wav")!, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0, views: "SettingView")
                    //                                }
                    //                        }
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
                                .foregroundStyle(.orange)
                        }
                        .sheet(isPresented: $profile) {
                            profileView
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                        }
                        Button {
                            
                        } label: {
                            Text("앱 사용 법")
                                .foregroundStyle(.orange)
                        }
                        
                    }
                } header: {
                    Text("Contact")
                }
            }
            .listStyle(.plain)
        }
    }
    //
//    var contact: some View {
//        Section{
//            Button{
//                self.profile = true
//            } label: {
//                Text("종이만드는 비전공 대학생 개발자")
//            }
//            .sheet(isPresented: $profile) {
//                profileView
//                    .presentationDetents([.medium])
//                    .presentationDragIndicator(.visible)
//            }
//            Button {
//                self.sheet = true
//            } label: {
//                Text("개발자 블로그")
//            }
//            .sheet(isPresented: $sheet) {
//                MyWebView(UrlTOLoad: "https://dazabamuker.tistory.com")
//                    .presentationDetents([.large])
//                    .presentationDragIndicator(.visible)
//            }
//            Button {
//                UIApplication.shared.openURL(URL(string: "https://dazabamuker.tistory.com/entry/%EB%84%88%ED%8A%9C%EB%B8%8C-%EB%85%B8%EB%9E%98%EB%B0%A9-%EC%95%B1-%EC%82%AC%EC%9A%A9%EB%B2%95How-to-use-NeotubeKaraoke-App")!)
//            } label: {
//                Text("앱 사용법")
//            }
//        } header: {
//            Text("Contact")
//                .bold()
//                .font(.title)
//                .foregroundColor(.white)
//        } footer: {
//            Text("개발자에게 질문이 있거나 요청이 있으시면 프로필의 이메일을 통하거나 블로그를 통해 연락하십시오.")
//        }
//    }
//    
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
                    Text("wookis112@gmail.com")
                        .tint(colorschome == .dark ? .white : .black)
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
    
    var cheerView: some View {
        ZStack{
            VStack{
                if ment == "" {
                    Text("응원 멘트를 입력해주세요.")
                        .font(.system(size: 300, weight: .bold))
                        .minimumScaleFactor(0.3)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(.secondary )
                        .animation(.linear(duration: 1.0), value: self.colorIndex)
                } else {
                    Text(ment)
                        .font(.system(size: 300, weight: .bold))
                        .minimumScaleFactor(0.3)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(isAnimation ? cheerColor[colorIndex] : .white )
                        .animation(.linear(duration: 1.0), value: self.colorIndex)
                        .onTapGesture {
                            rotateLandscape()
                        }
                }
                if isAnimation {
                    VStack{}.onAppear(){
                        chageColor()
                    }
                }
                if !isLandscape {
                    HStack{
                        TextField("응원 멘트를 입력해주세요", text: $ment, onEditingChanged: {isEditing = $0 })
                            .padding()
                            .onAppear(){
                                self.isAnimation = false
                                
                            }
                            .onDisappear(){
                                self.isAnimation = true
                            }
                        Button {
                            self.ment = ""
                        } label: {
                            if (self.ment.count > 0) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                                    .padding(.trailing, 5)
                            }
                        }
                    }
                }
            }
            VStack{
                Spacer()
                HStack{
                    Button {
                        self.audioManager.playClap()
                    } label: {
                        Image(systemName: "hands.clap.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .padding(.trailing,20)
                            .opacity(0.5)
                    }
                    Spacer()
                    if UIDevice.current.model == "iPad" {
                        Button {
                            rotateLandscape()
                        } label: {
                            Image(systemName: "text.bubble.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .padding(.trailing,20)
                                .opacity(0.5)
                        }
                    }
                    Button {
                        self.audioManager.playCrowd()
                    } label: {
                        Image(systemName: "shareplay")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .padding(.trailing,20)
                            .opacity(0.5)
                    }
                    
                }
                .frame(height: 50, alignment: .trailing)
                Spacer()
                    .frame(height: !isLandscape ? 50 : 10)
            }
        }
    }
}
