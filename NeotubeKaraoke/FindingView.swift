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
                    }
                }
                
                ZStack{
                    LinearGradient(colors: [.blue.opacity(0.7), .indigo.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    ForEach(0..<Int(geometry.size.height/150) + 1) { index in
                        Circle()
                            .stroke(lineWidth: 0.3)
                            .frame(width: 150 * CGFloat(index), height: 150 * CGFloat(index))
                            .opacity(1 - Double(index) / 10 )
                            .foregroundColor(.white)
                            .padding(.bottom, 50)
                    }
                }
                .frame(width: geometry.size.width)
                .edgesIgnoringSafeArea(.top)
                LazyVGrid(columns: self.columns, spacing: 0){
                    ForEach(peers.foundPeer, id: \.self) {peerID in
                        Text(peerID.displayName)
                            .PeerDevices(device: peerID, peers: $peers.connectedPeers)
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
            VStack{
                HStack{
                    Text("NearByConnect")
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
                        Text("Search Peers")
                    } icon: {
                        Image(systemName: "shared.with.you")
                    }
                }
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
                        .scaleEffect(0.8)
                }
                .background(.thinMaterial)
                .cornerRadius(12)
                .frame(height: 70)
                .padding(.horizontal)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FindingView_Previews: PreviewProvider {
    static var previews: some View {
        FindingView(addVideo: .constant(LikeVideo(videoId: "", title: "", thumbnail: "", channelTitle: "")), nowPlayList: .constant([]))
    }
}
