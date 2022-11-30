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
        let url = URL(string: Constant.API_URL)
        
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
            //parsing the data into video onject
        }
        
        // kick off the task
        dataTask.resume()
    }
}
