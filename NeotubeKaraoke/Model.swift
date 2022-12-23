//
//  Model.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/29.
//

import Foundation

class Model {
    func getVideos() {
        
        //Create URL object
        let urls = Constant.API_URL
        let urlEncoded = urls.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        
        
        guard url != nil else {

            return
        }
        
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
                
                dump(response)
                print("did")
            }
            catch {
                
            }
        }
        // kick off the task
        dataTask.resume()
    }
}
