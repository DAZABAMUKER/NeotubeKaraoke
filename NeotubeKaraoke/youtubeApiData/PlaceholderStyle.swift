//
//  PlaceholderStyle.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/27.
//

import SwiftUI
public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: LocalizedStringKey
    @Environment(\.colorScheme) var colorScheme

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.secondary)
                .padding(.horizontal, 25)
            }
            content
            .padding(5.0)
        }
    }
}
