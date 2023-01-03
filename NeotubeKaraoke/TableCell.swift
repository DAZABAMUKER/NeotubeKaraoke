//
//  TableCell.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/28.
//

import SwiftUI

struct TableCell: View {
    
    private var Video: Video
    private var image: UIImageView!
    init(Video: Video ) {
        self.Video = Video
    }
    
    var body: some View {
        GeometryReader{ geometry in
            HStack() {
                AsyncImage(url: URL(string: Video.thumbnail)){ image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "music.note.tv")
                }
                    .aspectRatio(480/360, contentMode: .fit)
                    .frame(height: 70)
                    .padding(.leading, -13)
                VStack(alignment: .leading) {
                    Text(Video.title)
                        .bold()
                        .lineLimit(2)
                        //.background(Color.green)
                        .font(.system(size: 20))
                    Text(Video.channelTitle)
                        .lineLimit(1)
                        //.background(.blue)
                        .font(.system(size: 12))
                }
                .foregroundColor(Color.white)
                Spacer()
            }
            .frame(width: geometry.size.width, height: 60)
            //.background(.black)
        }
    }
}
/*
struct TableCell_preview: PreviewProvider {
    static var previews: some View {
        TableCell()
    }
}*/
