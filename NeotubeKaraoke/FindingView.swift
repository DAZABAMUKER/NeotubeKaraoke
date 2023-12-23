//
//  FindingView.swift
//  tests
//
//  Created by 안병욱 on 2023/05/03.
//

import SwiftUI
import MultipeerConnectivity

struct FindingView: View {
    @StateObject var peers = ConnectPeer()
    @State var isbrowser = false
    @State var isAd = false
    @State var isOn = false
    @State var showPopOver = false
    @State var connectedPeers = [MCPeerID]()
    @Binding var addVideo: LikeVideo
    @Binding var nowPlayList: [LikeVideo]
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if connectedPeers != peers.connectedPeers {
                    VStack{}.onAppear(){
                        self.connectedPeers = peers.connectedPeers
                    }
                }
                
                if peers.receivedVideo.videoId != "nil" && self.nowPlayList.last != peers.receivedVideo {
                    VStack{}.onAppear(){
                        self.nowPlayList.append(peers.receivedVideo)
                        peers.receivedVideo = LikeVideo(videoId: "nil", title: "None", thumbnail: "nil", channelTitle: "None")
                    }
                }
                
                ZStack{
                    //Color.blue.opacity(0.7)
                    Image(systemName: "person.line.dotted.person")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue.opacity(0.5))
                        .frame(width: 80)
                        .offset(x: 0, y: -30)
                    ForEach(0..<Int(geometry.size.height/150) + 2) { index in
                        Circle()
                            .stroke(lineWidth: 0.6)
                            .frame(width: 150 * CGFloat(index), height: 150 * CGFloat(index))
                            .foregroundColor(Color.blue.opacity(0.7))
                            .opacity(1 - Double(index) / 10 )
                            .padding(.bottom, 50)
                    }
                }
                .frame(width: geometry.size.width)
                .edgesIgnoringSafeArea(.top)
                LazyVGrid(columns: self.columns, spacing: 0){
                    ForEach(peers.foundPeer, id: \.self) {peerID in
                        Text(peerID.displayName)
                            .PeerDevices(device: peerID, peers: $peers.connectedPeers, mcSession: $peers.mcSession, mcBrowser: $peers.mcNearbyServiceBrowser, addVideo: $addVideo)
                            .frame(width: 150)
                            .onTapGesture {
                                if connectedPeers.contains(peerID) {
                                    do {
                                        let data = try JSONEncoder().encode(self.addVideo)
                                        try peers.mcSession.send(data, toPeers: [peerID], with: .reliable)
                                    }
                                    catch {
                                        print(error)
                                    }
                                } else {
                                    peers.invite(peerID: peerID)
                                }
                            }
                            
                    }
                }
                .frame(width: geometry.size.width)
            }
            VStack(spacing: 0){
                HStack{
                    Text("디바이스 연결")
                        .foregroundStyle(.blue)
                        .bold()
                        .font(.title)
                        .padding()
                    Spacer()
                    
                    
                    /*
                     Button {
                     if isAd {
                     self.isAd = false
                     peers.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
                     } else {
                     peers.mcNearbyServiceAdvertiser.startAdvertisingPeer()
                     self.isAd = true
                     }
                     } label: {
                     Image(systemName: "shared.with.you")
                     .resizable()
                     .scaledToFit()
                     .frame(height: 30)
                     .foregroundColor(isAd ? .green : .secondary)
                     .shadow(radius: 10)
                     }
                     Button {
                     if isbrowser {
                     peers.mcNearbyServiceBrowser.stopBrowsingForPeers()
                     self.isbrowser = false
                     } else {
                     peers.mcNearbyServiceBrowser.startBrowsingForPeers()
                     self.isbrowser = true
                     }
                     } label: {
                     Image(systemName: "safari.fill")
                     .resizable()
                     .scaledToFit()
                     .frame(height: 30)
                     .foregroundColor(isbrowser ? .green : .secondary)
                     .shadow(radius: 10)
                     }
                     .padding()
                     */
                }
                Toggle(isOn: $isOn) {
                    Label {
                        Text("디바이스 찾기")
                            .foregroundStyle(.blue)
                    } icon: {
                        Image(systemName: "shared.with.you")
                            .foregroundStyle(.blue)
                    }
                }
                //.frame(width: 100)
                .padding(.horizontal)
                if self.isOn {
                    VStack{}.onAppear(){
                        peers.mcNearbyServiceAdvertiser.startAdvertisingPeer()
                        peers.mcNearbyServiceBrowser.startBrowsingForPeers()
                    }
                } else {
                    VStack{}.onAppear(){
                        peers.mcNearbyServiceAdvertiser.stopAdvertisingPeer()
                        peers.mcNearbyServiceBrowser.stopBrowsingForPeers()
                    }
                }
                HStack{
                    ListView(Video: self.addVideo)
                        //.scaleEffect(0.8)
                }
                .background(.thinMaterial)
                .cornerRadius(12)
                .frame(height: 70)
                .padding()
            }
        }
        //.preferredColorScheme(.dark)
    }
}

struct FindingView_Previews: PreviewProvider {
    static var previews: some View {
        FindingView(addVideo: .constant(LikeVideo(videoId: "", title: "", thumbnail: "", channelTitle: "")), nowPlayList: .constant([]))
    }
}
