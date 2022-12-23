//
//  Video.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//

import Foundation
struct Video : Decodable{
    
    var videoID: String = ""
    var title: String = ""
    var thumbnail: String = ""
    var description: String = ""
    var published = Date()
 
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        case ressourceId
        
        
        case videoID  = "videoId"
        case title
        case thumbnail = "url"
        case description
        case published = "publishedAt"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        self.published = try snippetContainer.decode(Date.self, forKey: .published)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        
        let resourceIdContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .ressourceId)
        self.videoID = try resourceIdContainer.decode(String.self, forKey: .videoID)
    }
    
}
