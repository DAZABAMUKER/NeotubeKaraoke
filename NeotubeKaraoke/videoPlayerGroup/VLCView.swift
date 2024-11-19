//
//  VLCView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/17/24.
//

import SwiftUI
import MobileVLCKit

struct VLCView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewType = UIView
    @State var player: vlcPlayerController
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(context.coordinator.something))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        player.drawable = view
        return view
    }
    
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var parent: VLCView
        init(_ parent: VLCView) {
            self.parent = parent
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func something(){
            print("눌림")
        }
        
    }
}
