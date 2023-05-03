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
    @Binding var peers: [MCPeerID]
    
    func sel() {
        if device.displayName.contains("iPhone") {
            self.deviceName = "iphone"
        } else if device.displayName.contains("iPad") {
            self.deviceName = "ipad"
        }
    }
    
    public func body(content: Content) -> some View {
        VStack{
            Image(systemName: self.deviceName)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
                .padding()
                .foregroundColor(peers.contains(device) ? .green : .white)
            content
                .foregroundColor(peers.contains(device) ? .green : .white)
                .onAppear(){
                    self.sel()
                }
        }
    }
}

extension View {
    func PeerDevices(device: MCPeerID, peers: Binding<[MCPeerID]>) -> some View {
        self.modifier(PeerDevice(device: device, peers: peers))
    }
}
