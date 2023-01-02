//
//  Constant.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//
import SwiftUI
import Foundation
struct Constant {
    
    static var API_KEY: String = "AIzaSyDegHUx5l5yGfcu3VK3zfhQmdS8iSChQzM"
    static var API_Q: String = "apple"
    static var API_PART: String = "snippet"
    static var API_URL: String = "https://www.googleapis.com/youtube/v3/search?part=\(API_PART)&q=\(API_Q)&key=\(API_KEY)"
    static var V_CellID: String = "videoCell"
    
}
