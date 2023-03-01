//
//  Models.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/03.
//

import UIKit

class Models: ObservableObject {
    
    @Published var responseitems = [Video]()
    @Published var nothings = false
    @Published var stsCode = 0
    @Published var isResponseitems = false
    
    func getVideos(val: String = "노래방") {
        print(val)
        let urls = "https://www.googleapis.com/youtube/v3/search?part=\(Constant.API_PART)&q=\(val)&order=viewCount&type=video&maxResults=20&key=\(Constant.API_KEY)"
        let urlEncoded = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        
        guard url != nil else {
            return
        }
        
        //Get URL Session Object
        let session = URLSession.shared
        //let js =
        
        guard let js = NSDataAsset(name: "ex") else { return }
        print(js)
        //let data = try? Data(contentsOf: js!)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try? decoder.decode(Response.self, from: js.data)
        self.responseitems = response!.items!
        self.isResponseitems = true
        
        
        /*
        //Get dataTask form URL Session Object
        let dataTask = session.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                return
            }
            
            do {
                let httpResponse = response as? HTTPURLResponse
                let responsStatusCode = httpResponse?.statusCode ?? 0
                guard httpResponse?.statusCode ?? 000 < 300 else {
                    print(responsStatusCode)
                    print(responsStatusCode == 403 ? "quota 초과": "Error")
                    DispatchQueue.main.sync {
                        self.nothings = true
                        self.stsCode = responsStatusCode
                    }
                    return
                }
                //parsing the data into video onject
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(Response.self, from: data!)
                DispatchQueue.main.async {
                    if response.items != nil {
                        self.nothings = false
                        self.responseitems = response.items ?? []
                        self.isResponseitems = true
                        guard let TiTle = response.items?.first?.title else {
                            print("result is noting!")
                            self.nothings = true
                            print(self.nothings)
                            return
                        }
                        print(TiTle)
                    }
                }
                //dump(response)
            }
            catch {
                
            }
        }
        // kick off the task
        dataTask.resume()
         */
    }
}
