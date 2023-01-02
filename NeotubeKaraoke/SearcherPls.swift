//
//  SearcherPls.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/01.
//

import SwiftUI

struct TableView: UIViewRepresentable {
    @Binding var isUpdating: Bool
    
    func makeUIView(context: Context) -> UITableView {
        let view = UITableView()
        return view
    }
    func updateUIView(_ uiView: UITableView, context: Context) {
        if isUpdating {
            
        }
    }
}
