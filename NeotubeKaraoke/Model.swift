//
//  Model.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//
import SwiftUI
import Foundation

class Model {
    var responseItems: [Video]!
    
    func getVideos(vals: String) -> [Video]{
        
        
        print(vals)
        //Create URL object
        var urls = "https://www.googleapis.com/youtube/v3/search?part=\(Constant.API_PART)&q=\(vals)&key=\(Constant.API_KEY)"
        let urlEncoded = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        
        /*guard url != nil else {
            return nil
        }*/
        
        //Get URL Session Object
        let session = URLSession.shared
        
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
                let response = try decoder.decode(Response.self, from: data! )
                self.responseItems = response.items!
                print(self.responseItems)
                dump(response)
            }
            catch {
                
            }
        }
        // kick off the task
        dataTask.resume()
        return responseItems
        
    }
}
