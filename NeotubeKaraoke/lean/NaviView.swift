//
//  NaviView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/12.
//

import SwiftUI

struct NaviView: View {
    
    var title: String
    
    
    @Binding
    var BActivated: Bool
    
    init(BActivated: Binding<Bool> = .constant(true), title: String = "타이틀") {
        _BActivated = BActivated
        self.title = title
    }
    
    
    @State
    private var BIndex: Int = 0
    private let BColors = [
        Color.green,
        Color.yellow,
        Color.orange,
        Color.blue,
        Color.gray
    ]
    
    
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("\(title) \(BIndex + 1)")
                .fontWeight(.heavy)
                .font(.system(size: 30))
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
            Text("활성화 버튼 \(String(self.BActivated))")
                .padding(.all, 8)
                .fontWeight(.heavy)
                .font(.system(size: 25))
                .foregroundColor(self.BActivated ? BColors[BIndex] : Color.gray)
                .background(Color.black)
                .cornerRadius(10)
            Spacer()
        }.animation(.easeOut)
        .background(BColors[BIndex])
        .onTapGesture {
            if (self.BIndex == BColors.count - 1) {
                self.BIndex = 0
            } else {
                self.BIndex += 1
            }
        }
        
    }
}

struct NaviView_Previews: PreviewProvider {
    static var previews: some View {
        NaviView()
    }
}
