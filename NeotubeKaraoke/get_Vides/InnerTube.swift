//
//  InnerTube.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/13/23.
//

import UIKit
import SwiftUI


let api_keys = [
    "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8",
    "AIzaSyCtkvNIR1HCEwzsqK6JuE6KqpyjusIRI30",
    "AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w",
    "AIzaSyC8UYZpvA2eknNex0Pjid0_eTLJoDu6los",
    "AIzaSyCjc_pVEDi4qsv5MtC2dMXzpIaDoRFLsxw",
    "AIzaSyDHQ9ipnphqTzDqZsbtd8_Ru4_kiKVQe2k"
]



@MainActor class InnerTube: ObservableObject {
    
    var use_Oath: Bool
    var allow_cache: Bool
    var context: Contexts!
    var api_key: String!
    var header: Header!
    var default_clients_client: Client!
    @Published var info: TubeResponse?
    @Published var infoReady = false
    @Published var HLSManifest = false
    
    @AppStorage("visitorData") var visitorData: String = ""
    
    
    init(client: String = "IOS", use_oath: Bool = false, allow_cache: Bool = false) {
        self.allow_cache = allow_cache
        self.use_Oath = use_oath
        guard let default_clients = NSDataAsset(name: "default_clients") else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let response = try decoder.decode(Default_clients.self, from: default_clients.data)
            self.api_key = response.ios.api_key
            self.context = response.ios.context
            self.header = response.ios.header
            //player(videoId: videoId)
        }
        catch {
            print("!!!!")
        }
        
        if self.use_Oath && self.allow_cache {
            
        }
        
        
    }
    
    
    func initialWebPageData(videoId: String) {
        //let endPointURL = URL(string: "https://www.youtube.com/embed/\(videoId)")!
        let endPointURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)")!

        var request = URLRequest(url: endPointURL)
        
        request.httpMethod = "GET"
        
        //MARK: Embed WEB
//        request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
//        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
//        request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
//        request.setValue("https://www.youtube.com/", forHTTPHeaderField: "Referer")
//
//        // Innertube 관련 헤더
//        request.setValue("WEB_EMBEDDED_PLAYER", forHTTPHeaderField: "X-YouTube-Client-Name")
//        request.setValue("1.20250923.21.00", forHTTPHeaderField: "X-YouTube-Client-Version")

        //MARK: IOS
        
        request.setValue("com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
        request.setValue("https://www.youtube.com/", forHTTPHeaderField: "Referer")

        // Innertube 관련 헤더
        request.setValue("IOS", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("20.10.4", forHTTPHeaderField: "X-YouTube-Client-Version")

        do {

            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    let httpResponse = response as? HTTPURLResponse
                    let responsStatusCode = httpResponse?.statusCode ?? 0
                    print(endPointURL.absoluteString)
                    print(responsStatusCode ,"!!@@!!")
                    print(error as Any)
                    return
                }
                DispatchQueue.main.async {
                    do {
                        
                        guard var data = data else {return}
                        let html = String(data: data, encoding: .utf8) ?? ""
                        if let startRange = html.range(of: "ytcfg.set("),
                           let endRange = html.range(of: ");", range: startRange.upperBound..<html.endIndex) {
                            
                            let jsonSubstring = html[startRange.upperBound..<endRange.lowerBound]
                            
                            // Step 2: JSON 문자열로 변환
                            let jsonString = String(jsonSubstring)
                            //print("❌Json String: ",jsonString)
                            // Step 3: 파싱
                            let regex = try! NSRegularExpression(pattern: #""jsUrl"\s*:\s*"([^"]+)""#)
                            var jsUrl = ""
                            if let match = regex.firstMatch(in: jsonString, range: NSRange(jsonString.startIndex..., in: jsonString)) {
                                if let range = Range(match.range(at: 1), in: jsonString) {
                                    jsUrl = String(jsonString[range])
                                    print("✅Extracted jsUrl: \(jsUrl)")
                                }
                            }
                            if let jsonData = jsonString.data(using: .utf8) {
                                do {
//                                    if let playerStart = jsonString.range(of: "jsUrl\":\""),
//                                       let playerStart2 = jsonString.range(of: precdeing_regex, options: .regularExpression)?.lowerBound,
//                                       let playerEnd = jsonString.range(of: "js\"", range: playerStart.upperBound..<jsonString.endIndex){
//                                        let playerSubstring = jsonString[playerStart.upperBound..<playerEnd.lowerBound]
//                                        let playerString = String(playerSubstring)
//                                        print("✅ Parsed jsUrl :", playerString)
//                                    }
                                    let json = try JSONDecoder().decode(EmbedInitialData.self, from: jsonData)
                                    self.player(videoId: videoId, jsonData: json, jsUrl: jsUrl)
                                    guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {return}
                                    //print("✅ Parsed ytcfg:", json)
                                    //print("✅ Parsed ytcfg:", json)
                                } catch {
                                    print("❌ JSON Parsing error:", error)
                                }
                            }
                        }
                    } catch {
                        print(error, #function)
                    }
                }
            }.resume()
        } catch {
            print("Json error: ")
            print(error)
        }
    }
    
    func player(videoId: String, jsonData: EmbedInitialData, jsUrl: String) {
        if videoId == "노래방" {
            return
        }
//        guard let key = self.api_key else {
//            return
//        }
        let endPointURL = URL(string: "https://www.youtube.com/youtubei/v1/player?videoId=\(videoId)&key=\(jsonData.INNERTUBE_API_KEY ?? "")&contentCheckOk=True&racyCheckOk=True")!
        //let endPointURL = URL(string: "https://www.youtube.com/youtubei/v1/player?prettyPrint=false")!
        //print(endPointURL.absoluteString)
        //print(self.header.user_agent)
        var request = URLRequest(url: endPointURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        //MARK: EMbed WEB
//        request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
        request.setValue("https://www.youtube.com/", forHTTPHeaderField: "Referer")

        // Innertube 관련 헤더
        //MARK: EMbed WEB
//        request.setValue("56", forHTTPHeaderField: "X-YouTube-Client-Name")
//        request.setValue("1.20250923.21.00", forHTTPHeaderField: "X-YouTube-Client-Version")
        request.setValue("IOS", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("20.10.4", forHTTPHeaderField: "X-YouTube-Client-Version")

        do {
            let contextData = try JSONEncoder().encode(INNERTUBE_PostBody(context: jsonData.INNERTUBE_CONTEXT, videoId: videoId))
            request.httpBody = contextData
            
            //print(String(data: contextData, encoding: .utf8))
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    let httpResponse = response as? HTTPURLResponse
                    let responsStatusCode = httpResponse?.statusCode ?? 0
                    print(endPointURL.absoluteString)
                    print(responsStatusCode ,"!!@@!!")
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    do {
                        
                        guard var data = data else {return}
                        let html = String(data: data, encoding: .utf8) ?? ""
                        // Step 2: JSON 문자열로 변환
                        let jsonString = String(html)
                        
                        // Step 3: 파싱
                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                //guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {return}
                                let json = try JSONDecoder().decode(TubeResponse.self, from: jsonData)
                                guard let query = json.streamingData?.adaptiveFormats?.first?.signatureCipher else {return}
                                print("✅ tubeResponse:", query)
                                
                                var sigParams: [String: String] = [:]

                                for pair in query.components(separatedBy: "&") {
                                    let keyValue = pair.components(separatedBy: "=")
                                    if keyValue.count == 2 {
                                        let key = keyValue[0]
                                        let value = keyValue[1]
                                        sigParams[key] = value
                                    }
                                }
                                print(sigParams["url"])
                                
                                //let jsUrl = "https://youtube.com" + jsUrl
                                let jsUrl = "https://youtube.com/s/player/0004de42/player-plasma-ias-phone-en_US.vflset/base.js"
                                Parse().get_Parse(url: jsUrl, video: false, videoId: videoId, sigParam: sigParams)
                            } catch {
                                print("❌ JSON Parsing error:", error)
                            }
                        }
                        
                        print("!!!!!!!!!!!!!!!!!!!!")
//
//                        self.info = try JSONDecoder().decode(TubeResponse.self, from: data)
//                        if self.info?.playabilityStatus.status == "LOGIN_REQUIRED" {
//                            self.visitorData = self.info?.responseContext?.visitorData ?? ""
//                            //self.player(videoId: videoId)
//                        }
//                        if self.info?.streamingData?.hlsManifestUrl != nil {
//                            self.HLSManifest = true
//                            print("HLS Manifest url")
//                            //return
//                        }
//                        self.infoReady = true
                    }
                    catch {
                        print(error, #function)
                    }
                }
            }.resume()
        } catch {
            print("Json encode error: ")
            print(error)
        }
        
    }
    
}


struct EmbedInitialData: Codable {
    var INNERTUBE_API_KEY: String?
    var INNERTUBE_API_VERSION: String?
    var INNERTUBE_CLIENT_NAME: String?
    var INNERTUBE_CLIENT_VERSION: String?
    var INNERTUBE_CONTEXT_CLIENT_NAME: Int?
    var INNERTUBE_CONTEXT_CLIENT_VERSION: String?
    var INNERTUBE_CONTEXT_GL: String?
    var INNERTUBE_CONTEXT_HL: String?
    var INNERTUBE_CONTEXT: INNERTUBE_Context?
    var VISITOR_DATA: String?
}

struct INNERTUBE_PostBody: Codable {
    var context: INNERTUBE_Context?
    var videoId: String?
}

struct INNERTUBE_Context: Codable {
    var client: INNERTUBE_Context_Client?
}

struct INNERTUBE_Context_Client: Codable {
    var hl: String?
    var gl: String?
    var remoteHost: String?
    var visitorData: String?
    var userAgent: String?
    var clientName: String?
    var clientVersion: String?
    var osName: String?
    var osVersion: String?
    var originalUrl: String?
    var platform: String?
    var clientFormFactor: String?
    var browserName: String?
    var browserVersion: String?
    var acceptHeader: String?
    var deviceExperimentId: String?
    var rolloutToken: String?
    var deviceMake: String?
    var deviceModel: String?
}

