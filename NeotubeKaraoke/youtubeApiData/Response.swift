//
//  Response.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/23.
//
import Foundation

struct Response: Decodable {
    var items: [Video]?
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Video].self, forKey: .items)
    }
}
