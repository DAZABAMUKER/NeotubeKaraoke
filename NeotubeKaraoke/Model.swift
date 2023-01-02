//
//  Model.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//
import SwiftUI
import Foundation

protocol ModelDelegate {
    func videoFetched(_ videos: [Video])
}

class Model {
    
    //public var responseItems: [Video]? = []
    var delegate: ModelDelegate? = TableView.Coordinator()
    
    func getVideos(vals: String = "노래방") {
        
        print(vals)
        //Create URL object
        var urls = "https://www.googleapis.com/youtube/v3/search?part=\(Constant.API_PART)&q=\(vals)&key=\(Constant.API_KEY)"
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
        self.responseItems = response!.items!
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
                
                if response.items != nil {
                    DispatchQueue.main.async {
                        // Call the "videosFetched" method of the delegate
                        self.delegate?.videoFetched(response.items!)
                        print("~")
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
