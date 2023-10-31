//
//  yt_main.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation

class Yt_main {
    
    var url: String
    var extract = Extract()
    
    init(url: String) {
        self.url = url
    }
    
    func streams() -> StreamQuary {
        check_availability()
        return StreamQuary()
    }
    
    func check_availability() {
        //extract.
    }
    
    func get_Parse() {
        
    }
}
