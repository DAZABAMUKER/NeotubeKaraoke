//
//  FindingView.swift
//  tests
//
//  Created by 안병욱 on 2023/05/03.
//

import SwiftUI

struct FindingView: View {
    @StateObject var peers = ConnectPeer()
    @State var isbrowser = false
    @State var isAd = false
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        GeometryReader { geometry in
            ZStack{
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
                                peers.invite(peerID: peerID)
                            }
                    }
                }
                .frame(width: geometry.size.width)
            }
            HStack{
                Text("NearByConnect")
                    .bold()
                    .font(.title)
                    .padding()
                Spacer()
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
                        .foregroundColor(isAd ? .green : .red)
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
                        .foregroundColor(isbrowser ? .green : .red)
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FindingView_Previews: PreviewProvider {
    static var previews: some View {
        FindingView()
    }
}
