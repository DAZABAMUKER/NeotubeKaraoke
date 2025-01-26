//
//  vlcTest.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/16/24.
//

import SwiftUI
import VLCKitSPM

struct vlcTest: View {
    @State var videoURL: URL? = URL(string: "https://rr1---sn-3u-20nr.googlevideo.com/videoplayback?expire=1737191087&ei=TxqLZ6jhKY2xvcAPndui8Qk&ip=59.22.159.5&id=o-AE632OPF2HK-xvfHacWd0RXYR_DhQePGrrDakEKT8rDI&itag=136&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&met=1737169487%2C&mh=H_&mm=31%2C29&mn=sn-3u-20nr%2Csn-3u-bh2z6&ms=au%2Crdu&mv=m&mvi=1&pl=16&rms=au%2Cau&initcwndbps=3850000&bui=AY2Et-PBvEHtJ981WXVfLDYAAV7HMpbvBoNn3T5-FiOjhpFpuhP0ffP702qQ37Rr715Y2La3v5wCgsGV&spc=9kzgDUYNZSxo-LTqdw8Z5dmBUapEhCK0Dl64LVqPmshAAn31aGf1nNdhowh1&vprv=1&svpuc=1&mime=video%2Fmp4&rqh=1&gir=yes&clen=40758206&dur=273.966&lmt=1709102429722189&mt=1737169032&fvip=3&keepalive=yes&fexp=51326932%2C51335594%2C51353498%2C51371294%2C51384461&c=IOS&txp=5309224&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cbui%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Crqh%2Cgir%2Cclen%2Cdur%2Clmt&sig=AJfQdSswRQIhAPmVjImbczkUTlXavo8mbkHNFD89GztAlFEkoRHNBbwgAiBC-MaXhxE-8E39Qpy-Bh624KUhR3cBXogJXinfTUvAkg%3D%3D&lsparams=met%2Cmh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Crms%2Cinitcwndbps&lsig=AGluJ3MwRAIgPFC4O100sZJ2rRDz9VThvjYZfQnj0B08PsnJNYD8BgECIEpVbUZOL3TxiRvRAG6owDqm1GCnjNq3Klhgif4g0QlI")
    @State var player = vlcPlayerController()
    var body: some View {
        VStack{
            VLCView(player: self.player)
                .onAppear(){
                    //player.loadVideo(url: videoURL)
                }
                .onTapGesture {
                    player.plays()
                }
            Button {
                player.plays()
            } label: {
                Text("play")
            }

        }
    }
}

#Preview {
    vlcTest()
}
