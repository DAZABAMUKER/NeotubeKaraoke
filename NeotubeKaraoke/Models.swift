//
//  Models.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/03.
//

import UIKit

class Models: ObservableObject {
    @Published var responseitems = [Video]()
    
    func getVideos(val: String = "노래방") {
        print(val)
        var urls = "https://www.googleapis.com/youtube/v3/search?part=\(Constant.API_PART)&q=\(val)&order=viewCount&type=video&maxResults=20&key=\(Constant.API_KEY)"
        let urlEncoded = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        
        guard url != nil else {
            return
        }
        
        //Get URL Session Object
        let session = URLSession.shared
        /*
        let js = Bundle.main.url(forResource: "ex", withExtension: "json")
        let data = try? Data(contentsOf: js!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try? decoder.decode(Response.self, from: data!)
        self.responseitems = response!.items!
        
        */
        
        //Get dataTask form URL Session Object
        let dataTask = session.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                return
            }
            do {
                //parsing the data into video onject
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(Response.self, from: data!)
                DispatchQueue.main.async {
                    if response.items != nil {
                        self.responseitems = response.items!
                        print("meNOW")
                        print(self.responseitems[0].channelTitle)
                        self.objectWillChange.send()
                    }
                }
                
                print(response.items![0].title)
                //dump(response)
            }
            catch {
                
            }
        }
        // kick off the task
        dataTask.resume()
    }
}
