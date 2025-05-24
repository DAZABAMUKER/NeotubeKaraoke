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
    
    func player(videoId: String) {
//        guard let key = self.api_key else {
//            return
//        }
        //let endPointURL = URL(string: "https://www.youtube.com/youtubei/v1/player?videoId=\(videoId)&key=\(key)&contentCheckOk=True&racyCheckOk=True")!
        let endPointURL = URL(string: "https://www.youtube.com/youtubei/v1/player?prettyPrint=false")!
        //print(endPointURL.absoluteString)
        //print(self.header.user_agent)
        var request = URLRequest(url: endPointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("com.google.ios.youtube/19.45.4 (iPhone16,2; U; CPU iOS 18_1_0 like Mac OS X;)", forHTTPHeaderField: "User-Agent")
        request.setValue("\(self.visitorData)", forHTTPHeaderField: "X-Goog-Visitor-Id")

        do {
            let contextData = try JSONEncoder().encode(ContentContaioner(context: self.context, videoId: videoId))
            request.httpBody = contextData
            //print(String(data: contextData, encoding: .utf8))
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    print("!!@@!!")
                    return
                }
                DispatchQueue.main.async {
                    do {
                        guard let data = data else {return}
                        print(String(data: data ?? Data(), encoding: .utf8))
                        self.info = try JSONDecoder().decode(TubeResponse.self, from: data)
                        if self.info?.playabilityStatus.status == "LOGIN_REQUIRED" {
                            self.visitorData = self.info?.responseContext?.visitorData ?? ""
                            self.player(videoId: videoId)
                        }
                        if self.info?.streamingData?.hlsManifestUrl != nil {
                            self.HLSManifest = true
                            print("HLS Manifest url")
                            //return
                        }
                        self.infoReady = true
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
