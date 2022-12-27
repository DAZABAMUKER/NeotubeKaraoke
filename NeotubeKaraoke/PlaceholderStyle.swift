//
//  PlaceholderStyle.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/27.
//

import SwiftUI
public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(Color.white)
                .padding(.horizontal, 35)
            }
            content
            .padding(5.0)
        }
    }
}
