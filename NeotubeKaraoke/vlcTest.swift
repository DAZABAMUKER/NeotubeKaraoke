//
//  vlcTest.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 11/16/24.
//

import SwiftUI
import VLCKitSPM

struct vlcTest: View {
    @State var videoURL: URL? = URL(string: "https://rr1---sn-npoeenll.googlevideo.com/videoplayback?expire=1731795284&ei=88Q4Z_WzOYfUxN8PwN2gkAw&ip=2c0f%3Aeb58%3A601%3A7400%3A70f4%3Afbbf%3A564d%3A2a86&id=o-AKLpdf1zJPy9TvIXKsQT_RDui6yuL67sRI9tGIvgfIUS&itag=400&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&vprv=1&svpuc=1&mime=video%2Fmp4&rqh=1&gir=yes&clen=162357252&dur=207.323&lmt=1726467659179788&keepalive=yes&fexp=24350590,24350675,24350705,24350737,51299154,51312688,51326932&c=ANDROID_VR&txp=5532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cvprv%2Csvpuc%2Cmime%2Crqh%2Cgir%2Cclen%2Cdur%2Clmt&sig=AJfQdSswRQIhAKBIKUF9pGLjwQCOksbCFUGbgWwLO6ftggG7I-1YrmJYAiB8VZ3A0FsxVuuE_ZFAKOTGuO_drnYvhwQiv2n5fGPVSg%3D%3D&rm=sn-bgv02x8p8xoqp-v05l7e&rrc=79,80&req_id=33d8134fbf3ba3ee&cmsv=e&redirect_counter=2&cm2rm=sn-avnz7l&cms_redirect=yes&met=1731773745,&mh=9V&mip=115.22.123.42&mm=34&mn=sn-npoeenll&ms=ltu&mt=1731773325&mv=m&mvi=1&pl=18&rms=ltu,au&lsparams=met,mh,mip,mm,mn,ms,mv,mvi,pl,rms&lsig=AGluJ3MwRAIgTpX2ciYz9FGvrBuK6DnWmukxxFuMkeb6_CuIr4cvG-UCIA-4aq6HT8Hwef3weVVhMh3ZAhH0VfKsaieUuWqOdJ4Z")
    var body: some View {
        Image(systemName: "heart.fill")
    }
}

#Preview {
    vlcTest()
}
