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
    var ios: Client_response
}

struct Client_response: Codable{
    var context: Contexts
    var header: Header?
    var api_key: String?
    var videoId: String?
    
    
    
    enum CodingKeys: String, CodingKey {
        //case client
        case context
        case header
        case api_key
        case videoId
    }
    
}

struct Contexts: Codable {
    var client: Client
}

struct ContentContaioner: Codable {
    var context: Contexts
    var videoId: String?
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
    var osVersion: String?
    var osName: String?
    var userAgent: String?
    var deviceMake: String?
    var hl: String?
    var timezone: String?
    var utcOffsetMinutes: Int?
    
    enum CodingKeys: CodingKey {
        case clientName
        case clientVersion
        case deviceModel
        case androidSdkVersion
        case clientScreen
    }
}

struct TubeResponse: Codable {
    var playabilityStatus: Tubeavailability?
    var streamingData: TubeStreamingData?
    var videoDetails: VideoDetails?
    var responseContext: ResponseCOntext?
}

struct ResponseCOntext: Codable {
    var visitorData: String?
}


struct Tubeavailability: Codable {
    var status: String
    var playableInEmbed: Bool?
}

struct TubeStreamingData: Codable {
    var formats: [TubeFormats]?
    var adaptiveFormats: [TubeAdaptiveFormats]?
    var expiresInSeconds: String
    var hlsManifestUrl: String?
    var serverAbrStreamingUrl: String?
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
    var signatureCipher: String?
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
    var highReplication: Bool?
    var audioQuality: String?
    var audioSampleRate: String?
    var audioChannels: Int?
    var loudnessDb: Double?
    var signatureCipher: String?
    var codecs: String?
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
    var thumbnail : Thumbnails?

}
struct Thumbnails: Codable {
    var thumbnails: [ThumbnailImage]?
    
}

struct ThumbnailImage: Codable {
    var url: String?
    let width: Int?
    let height: Int?
}

struct TubeResponseBrowser: Codable {
    //var responsecontext: TUBE
    //var annotations
    var videodetails: VideoDetailsBrowser?
//    var storyboards
    var playabilitystatus: TubeavailabilityBrowser?
//    var frameworkupdates
//    var microformat
//    var messages
//    var playerconfig
//    var attestation
//    var videoqualitypromosupportedrenderers
//    var playerads
    var streamingdata: TubeStreamingDataBrowser?
//    var trackingparams
//    var adslots
//    var playbacktracking
//    var adbreakheartbeatparams
//    var adplacements
//    var cards
}



struct TubeavailabilityBrowser: Codable {
    var status: String?
    var playableInEmbed: Bool?
}

struct TubeStreamingDataBrowser: Codable {
    var formats: [TubeFormatsBrowser]?
    var adaptiveformats: [TubeAdaptiveFormatsBrowser]?
    var expiresinseconds: String?
    var hlsManifestUrl: String?
    var serverAbrStreamingUrl: String?
}

struct TubeFormatsBrowser: Codable {
    var itag: Int?
    var url: String?
    var mimetype: String?
    var bitrate: Int?
    var width: Int?
    var height: Int?
    var lastmodified: String?
    var contentlength: String?
    var quality: String?
    var fps: Int?
    var qualitylabel: String?
    var projectiontype: String?
    var averagebitrate: Int?
    var audioquality: String?
    var approxdurationMs: String?
    var audiosampleRate: String?
    var audiochannels: Int?
    var signaturecipher: String?
}

struct TubeAdaptiveFormatsBrowser: Codable {
    var itag: Int?
    var url: String?
    var mimetype: String?
    var bitrate: Int?
    var width: Int?
    var height: Int?
    var initrange: TubeAdaptiveFormatsRange?
    var indexrange: TubeAdaptiveFormatsRange?
    var lastModified: String?
    var contentlength: String?
    var quality: String?
    var fps: Int?
    var qualitylabel: String?
    var projectiontype: String?
    var averagebitrate: Int?
    var approxdurationMs: String?
    var highreplication: Bool?
    var audioquality: String?
    var audiosamplerate: String?
    var audiochannels: Int?
    var loudnessdb: Double?
    var signaturecipher: String?
    ///////
}

struct TubeAdaptiveFormatsRangeBrowser: Codable {
    var start: String?
    var end: String?
}
//struct streamingData: Decodable {
//    var format
//}

struct VideoDetailsBrowser: Codable {
    var videoId: String?
    var title: String?
    var lengthseconds: String?
    var thumbnail : Thumbnails?

}

