//
//  TableCell.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/28.
//

import SwiftUI

struct TableCell: View {
    
    private var Video: [Video]?
    
    init(Video: [Video]? = nil) {
        self.Video = Video
    }
    
    var body: some View {
        GeometryReader{ geometry in
            HStack() {
                /*ZStack(){
                    Rectangle()
                        .fill(LinearGradient(colors: [
                            Color.pink,
                            Color(red: 253 / 255, green: 138 / 255, blue: 138 / 255)
                        ], startPoint: .top, endPoint: .bottom))
                        .aspectRatio(16/9, contentMode: .fill)
                        .scaledToFit()
                        .cornerRadius(8)
                        
                    Image(systemName: "music.note.tv")
                        .resizable()
                        .frame(height: 50)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(Color.white)
                }*/
                
                VStack(alignment: .leading) {
                    Text("Title")
                        .bold()
                        .lineLimit(2)
                        .background(Color.green)
                    Text("musition")
                        .lineLimit(1)
                        .background(.blue)
                }
                .foregroundColor(Color.white)
                Spacer()
            }
            .frame(width: geometry.size.width, height: 60)
            //.background(.black)
        }
    }
}

struct TableCell_preview: PreviewProvider {
    static var previews: some View {
        TableCell()
    }
}
