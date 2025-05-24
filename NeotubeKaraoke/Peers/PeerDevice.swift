//
//  PeerDevice.swift
//  tests
//
//  Created by 안병욱 on 2023/05/03.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

struct PeerDevice : ViewModifier {
    
    let device: MCPeerID
    @State var deviceName: String = ""
    @State var show = false
    @Binding var peers: [MCPeerID]
    @Binding var mcSession: MCSession
    @Binding var mcBrowser: MCNearbyServiceBrowser
    @Binding var addVideo: LikeVideo
    
    func sel() {
        if device.displayName.contains("iPhone") {
            self.deviceName = "iphone"
        } else if device.displayName.contains("iPad") {
            self.deviceName = "ipad"
        }
    }
    
    public func body(content: Content) -> some View {
        ZStack{
            VStack{
                Image(systemName: self.deviceName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .padding()
                    .foregroundStyle(peers.contains(device) ? .green : Color.accentColor)
                    
                content
                    .foregroundStyle(peers.contains(device) ? .green : Color.accentColor)
                    .onAppear(){
                        self.sel()
                    }
            }
            .onTapGesture {
                if peers.contains(device) {
                    self.show.toggle()
                } else {
                    mcBrowser.invitePeer(device, to: mcSession, withContext: nil, timeout: 3)
                }
                print("tapped")
            }
            if self.show {
                HStack{
                    Button {
                        do {
                            guard let data = "clap".data(using: .utf8) else {return}
                            try mcSession.send(data, toPeers: [device], with: .reliable)
                        }
                        catch {
                            print("clap error: ", error)
                        }
                    } label: {
                        Image(systemName: "hands.clap.fill")
                    }
                    .padding(7)
                    Divider()
                    Button {
                        do {
                            guard let data = "환호".data(using: .utf8) else {return}
                            try mcSession.send(data, toPeers: [device], with: .reliable)
                        }
                        catch {
                            print("환호 error:", error)
                        }
                    } label: {
                        Image(systemName: "shareplay")
                    }
                    .padding(7)
                    Divider()
                    Button {
                        do {
                            let data = try JSONEncoder().encode(self.addVideo)
                            try mcSession.send(data, toPeers: [device], with: .reliable)
                        }
                        catch {
                            print(error)
                        }
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                    }
                    .padding(7)
                }
                .background(.black.opacity(0.8))
                .cornerRadius(10)
                .tint(.white)
                .frame(height: 30)
                .offset(x:0, y: -80)
            }
        }
    }
}

extension View {
    func PeerDevices(device: MCPeerID, peers: Binding<[MCPeerID]>, mcSession: Binding<MCSession>, mcBrowser: Binding<MCNearbyServiceBrowser>, addVideo: Binding<LikeVideo>) -> some View {
        self.modifier(PeerDevice(device: device, peers: peers, mcSession: mcSession, mcBrowser: mcBrowser, addVideo: addVideo))
    }
}
