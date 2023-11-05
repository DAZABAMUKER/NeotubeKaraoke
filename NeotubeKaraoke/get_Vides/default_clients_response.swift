//
//  default_clients_response.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/13/23.
//

import Foundation

struct Default_clients: Codable {
    var WEB: Client_response
    var ANDROID: Client_response
    var IOS: Client_response
    
    var WEB_EMBED: Client_response
    var ANDROID_EMBED: Client_response
    var IOS_EMBED: Client_response
    
    var WEB_MUSIC: Client_response
    var ANDROID_MUSIC: Client_response
    var IOS_MUSIC: Client_response
    
    var WEB_CREATOR: Client_response
    var ANDROID_CREATOR: Client_response
    var IOS_CREATOR: Client_response
    
    var MWEB: Client_response
    var TV_EMBED: Client_response
}

struct Client_response: Codable{
    var context: Contexts
    var header: Header
    var api_key: String
    
    enum CodingKeys: String, CodingKey {
        //case client
        case context
        case header
        case api_key
    }
    
}

struct Contexts: Codable {
    var client: Client
}

struct ContentContaioner: Codable {
    var context: Contexts
}

struct Header: Codable {
    var user_agent: String
    
    enum CodingKeys: String, CodingKey {
        case user_agent = "User-Agent"
    }
}
struct Client: Codable {
    var clientName: String
    var clientVersion: String?
    var deviceModel: String?
    var androidSdkVersion: Int?
    var clientScreen: String?
    
    enum CodingKeys: CodingKey {
        case clientName
        case clientVersion
        case deviceModel
        case androidSdkVersion
        case clientScreen
    }
}

struct TubeResponse: Codable {
    var playabilityStatus: Tubeavailability
    var streamingData: TubeStreamingData
    var videoDetails: VideoDetails
}

struct Tubeavailability: Codable {
    var status: String
    var playableInEmbed: Bool
}

struct TubeStreamingData: Codable {
    var formats: [TubeFormats]?
    var adaptiveFormats: [TubeAdaptiveFormats]?
    var expiresInSeconds: String
    var hlsManifestUrl: String?
}

struct TubeFormats: Codable {
    var itag: Int?
    var url: String?
    var mimeType: String?
    var bitrate: Int?
    var width: Int?
    var height: Int?
    var lastModified: String?
    var contentLength: String?
    var quality: String?
    var fps: Int?
    var qualityLabel: String?
    var projectionType: String?
    var averageBitrate: Int?
    var audioQuality: String
    var approxDurationMs: String?
    var audioSampleRate: String?
    var audioChannels: Int?
}

struct TubeAdaptiveFormats: Codable {
    var itag: Int?
    var url: String?
    var mimeType: String?
    var bitrate: Int?
    var width: Int?
    var height: Int?
    var initRange: TubeAdaptiveFormatsRange?
    var indexRange: TubeAdaptiveFormatsRange?
    var lastModified: String?
    var contentLength: String?
    var quality: String?
    var fps: Int?
    var qualityLabel: String?
    var projectionType: String?
    var averageBitrate: Int?
    var approxDurationMs: String?
    var audioQuality: String?
    ///////
}

struct TubeAdaptiveFormatsRange: Codable {
    var start: String
    var end: String
}
//struct streamingData: Decodable {
//    var format
//}

struct VideoDetails: Codable {
    var videoId: String?
    var title: String?
    var lengthSeconds: String?
}
