//
//  InnerTube.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/13/23.
//

import UIKit


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
    
    
    init(client: String = "ANDROID_EMBED", use_oath: Bool = false, allow_cache: Bool = false) {
        self.allow_cache = allow_cache
        self.use_Oath = use_oath
        guard let default_clients = NSDataAsset(name: "default_clients") else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let response = try decoder.decode(Default_clients.self, from: default_clients.data)
            self.api_key = response.ANDROID_CREATOR.api_key
            self.context = response.ANDROID_CREATOR.context
            self.header = response.ANDROID_CREATOR.header
            //player(videoId: videoId)
        }
        catch {
            print("!!!!")
        }
        
        if self.use_Oath && self.allow_cache {
            
        }
        
        
    }
    
    func player(videoId: String) {
        guard let key = self.api_key else { return }
        let endPointURL = URL(string: "https://www.youtube.com/youtubei/v1/player?videoId=\(videoId)&key=\(key)&contentCheckOk=True&racyCheckOk=True")!
        
        //print(self.header.user_agent)
        var request = URLRequest(url: endPointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue(self.header.user_agent, forHTTPHeaderField: "User-Agent")
        do {
            let contextData = try JSONEncoder().encode(ContentContaioner(context: self.context))
            request.httpBody = contextData
            //print(String(data: contextData, encoding: .utf8))
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    return
                }
                DispatchQueue.main.async {
                    do {
                        //print("1")
                        //print(String(data: data!, encoding: .utf8))
                        self.info = try JSONDecoder().decode(TubeResponse.self, from: data!)
                        self.infoReady = true
                        //print("2")
                        //print(tubeResponse.streamingData.formats.first?.contentLength)
                        //print(tubeResponse.streamingData.formats.last?.url)
                        //print(String(data: data!, encoding: .utf8))
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
