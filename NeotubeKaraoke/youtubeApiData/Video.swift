//
//  Video.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//
import SwiftUI
import Foundation
struct Video : Decodable{
    var videoID: String = ""
    var title: String = ""
    var thumbnail: String = ""
    var description: String = ""
    var published = Date()
    var channelTitle: String = ""
    var live = false
 
    enum CodingKeys: String, CodingKey {
        
        case snippet
        case thumbnails
        case high
        case ressourceId = "id"
        
        
        case videoID  = "videoId"
        case title
        case thumbnail = "url"
        case description
        case published = "publishedAt"
        case channelTitle
        case liveBroadcastContent
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        let finding = try snippetContainer.decode(String.self, forKey: .liveBroadcastContent)
        if finding == "live" {
            self.live = true
            return
        }
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        self.title = String(htmlEncodedString: self.title)!
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        self.description = String(htmlEncodedString: self.description)!
        self.published = try snippetContainer.decode(Date.self, forKey: .published)
        self.channelTitle = try snippetContainer.decode(String.self, forKey: .channelTitle)
        self.channelTitle = String(htmlEncodedString: self.channelTitle)!
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnail = try highContainer.decode(String.self, forKey: .thumbnail)
        let resourceIdContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .ressourceId)
        self.videoID = try resourceIdContainer.decode(String.self, forKey: .videoID)
        
    }
    
}

extension String {

    init?(htmlEncodedString: String) {

        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }

        self.init(attributedString.string)

    }

}
