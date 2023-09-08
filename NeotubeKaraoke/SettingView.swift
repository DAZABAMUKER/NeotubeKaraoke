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
    @State var showCheer = false
    @State var karaoke: Karaoke = Karaoke.Tj
    @State var titleOfSong = ""
    @State var ment = ""
    @State var isEditing: Bool = false
    @StateObject private var getPopularChart = GetPopularChart()
    @State var isAnimation = false
    @State var cheerColor = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.indigo, Color.purple]
    @State var colorIndex = 0
    @State var refund = false
    let audioManager = AudioManager(file: Bundle.main.url(forResource: "clap", withExtension: "wav")!, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var entitlementManager: EntitlementManager
    
    @Binding var resolution: Resolution
    @Binding var isLandscape: Bool
    private let pasteboard = UIPasteboard.general
    
    private let devProfile: LocalizedStringKey = "Developer Profile"
    private let devBlog: LocalizedStringKey = "Developer's Blog"
    private let contact: LocalizedStringKey = "If you have any questions or requests from the developer, please contact us via email or blog on my profile"
    private let someone: LocalizedStringKey = "A paper-making university student developer"
    private let email: LocalizedStringKey = "Email: "
    private let kakaotalk: LocalizedStringKey = "KakaoTalk ID: "
    private let titleOfResolution: LocalizedStringKey = "Select prefer resolution"
    private let ifHigher: LocalizedStringKey = "If you select a resolution higher than 1080 rather than Basic, the loading time may increase."
    private let rmAds: LocalizedStringKey = "Remove Ads(To be updated...)"
    private let alertMic: LocalizedStringKey = "Please allow Microphone Usage."
    private let cancel: LocalizedStringKey = "Cancel"
    private let OK: LocalizedStringKey = "OK"
    private let searchNumberOfSongs: LocalizedStringKey = "Searching for number of karaoke songs."
    private let selResolution: LocalizedStringKey = "Selecting Resolution"
    private let searchSongTitle: LocalizedStringKey = "title of the song"
    private let numberOfSong: LocalizedStringKey = "Number of the song"
    private let title: LocalizedStringKey = "Title"
    private let artist: LocalizedStringKey = "Artist"
    private let noResults: LocalizedStringKey = "No results"
    private let manual: LocalizedStringKey = "Manual of NeotubeKaraoke"
    private let cheer: LocalizedStringKey = "Cheer for your friends"
    private let thanks: LocalizedStringKey = "Oh my gosh! I'm touched! 🥰"
    private let RMAds: LocalizedStringKey = "You can remove Ads!"
    private let RSPurchased: LocalizedStringKey = "Restore In-App purchases"
    private let RMAdsTitle: LocalizedStringKey = "Remove Ads"
    private let goOrBackTime: LocalizedStringKey = "Select go/backward time"
    
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
        NavigationStack{
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
                        Button {
                            UIApplication.shared.openURL(URL(string: "https://dazabamuker.tistory.com/entry/%EB%84%88%ED%8A%9C%EB%B8%8C-%EB%85%B8%EB%9E%98%EB%B0%A9-%EC%95%B1-%EC%82%AC%EC%9A%A9%EB%B2%95How-to-use-NeotubeKaraoke-App")!)
                        } label: {
                            Text(self.manual)
                        }

                    } header: {
                        Text("Contact")
                            .bold()
                            .font(.title)
                            .foregroundColor(.white)
                    } footer: {
                        Text(self.contact)
                    }
                    Section {
                        VStack {
                            Text(self.titleOfResolution)
                                .bold()
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(0)
                            Picker(self.selResolution, selection: $resolution) {
                                Text("Low").tag(Resolution.low)
                                Text("Basic").tag(Resolution.basic)
                                Text("1080").tag(Resolution.high)
                                Text("1080+").tag(Resolution.ultra)
                            }
                            .pickerStyle(.segmented)
                            Text(self.ifHigher)
                                .font(.footnote)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                        }
                        VStack {
                            Text(self.goOrBackTime)
                                .bold()
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(0)
                            Picker(self.goOrBackTime, selection: $goBackTime) {
                                Text("5s").tag(5.0)
                                Text("15s").tag(15.0)
                                Text("30s").tag(30.0)
                                Text("60s").tag(60.0)
                            }
                            .pickerStyle(.segmented)
                        }
                        Toggle(isOn: $micPermission) {
                            Text("Show music score")
                        }
                    }
                    
                    Section {
                        VStack{
                            if entitlementManager.hasPro {
                                Text(self.thanks)
                                    .font(.title3)
                                Divider()
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
                                Text(self.RMAds)
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
                                            Text("Please wait! It's still up in the air.")
                                        } else {
                                            HStack{
                                                Image(systemName: "hand.raised.fingers.spread")
                                                    .foregroundColor(.white)
                                                Text(product.displayName)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                HStack{
                                                    Text(product.displayPrice)
                                                        .foregroundColor(.white)
                                                }
                                                .padding(5)
                                                .padding(.horizontal, 10)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .strokeBorder(lineWidth: 3)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    Divider()
                                }
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
                                        Text(self.RSPurchased)
                                    }
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .foregroundColor(.white)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
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
                        Text(self.RMAdsTitle)
                    }
                    
                    Section{
                        Button {
                            self.showCheer.toggle()
                        } label: {
                            Text(self.cheer)
                        }
                        .sheet(isPresented: $showCheer) {
                            cheerView
                        }
                    }
                    
                    Section{
                        VStack{
                            Picker(self.searchNumberOfSongs, selection: $karaoke) {
                                Text("Tj").tag(Karaoke.Tj)
                                Text("KY").tag(Karaoke.KY)
                            }
                            TextField(self.searchSongTitle, text: $titleOfSong)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                                .onSubmit {
                                    if self.karaoke == .KY {
                                        self.getPopularChart.searchSongOfKY(val: titleOfSong)
                                    } else {
                                        self.getPopularChart.searchSongOfTj(val: titleOfSong)
                                    }
                                    
                                }
                        }
                    }
                    Section{
                        VStack{
                            HStack{
                                Text(self.numberOfSong)
                                    .bold()
                                    .frame(width: 80)
                                Text(self.title)
                                    .bold()
                                Spacer()
                                Text(self.artist)
                                    .bold()
                            }
                            .padding(.top, 5)
                            Divider()
                            if !self.getPopularChart.Titles.isEmpty {
                                ForEach(0..<self.getPopularChart.Titles.count, id: \.self) { index in
                                    VStack{
                                        HStack{
                                            Text(self.getPopularChart.Numbers[index])
                                                .frame(width: 80)
                                            Text(self.getPopularChart.Titles[index])
                                            Spacer()
                                            Text(self.getPopularChart.Singers[index])
                                        }
                                        Divider()
                                    }
                                }
                            } else if self.getPopularChart.Numbers.contains("검색결과를 찾을수 없습니다.") {
                                Text(self.noResults)
                            }
                        }
                    }
                    .alert(Text(self.alertMic), isPresented: $showAlert) {
                        Button {
                            self.showAlert = false
                            self.micPermission = false
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text(self.OK)
                        }
                        
                        Button {
                            self.showAlert = false
                            self.micPermission = false
                        } label: {
                            Text(self.cancel)
                        }
                    }
                    Spacer()
                        .frame(height: 100)
                }
                /*
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
                    .frame(width: 300, height: 50)
                }
                */
            }
            .preferredColorScheme(.dark)
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
    
    var cheerView: some View {
        ZStack{
            VStack{
                Text(ment)
                    .font(.system(size: 300, weight: .bold))
                    .minimumScaleFactor(0.3)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .foregroundColor(isAnimation ? cheerColor[colorIndex] : .white )
                    .animation(.linear(duration: 1.0), value: self.colorIndex)
                    .onTapGesture {
                        rotateLandscape()
                    }
                if isAnimation {
                    VStack{}.onAppear(){
                        chageColor()
                    }
                }
                if !isLandscape {
                    HStack{
                        TextField(self.cheer, text: $ment, onEditingChanged: {isEditing = $0 })
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
