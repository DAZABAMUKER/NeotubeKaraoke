//
//  MYVStackView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI

struct MYVStack: View {
    
    @Binding
    var BActivated: Bool
    
    init(BActivated: Binding<Bool> = .constant(true)) {
        _BActivated = BActivated
    }
    
    var body: some View {
        VStack{
            Text("1!")
                .fontWeight(.bold)
                .font(.system(size: 60))
            Text("2!")
                .fontWeight(.bold)
                .font(.system(size: 60))
            Text("3!")
                .fontWeight(.bold)
                .font(.system(size: 60))
        }
        .background(self.BActivated ? Color.red : Color.green)
        .padding(self.BActivated ? 10.0 : 0.0)
    }
    
}

struct MTVStack_Preview: PreviewProvider {
    static var previews: some View {
        MYVStack()
    }
}
