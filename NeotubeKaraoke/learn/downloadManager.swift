//
//  downloadManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/21.
//

import Foundation

fileprivate class DownloadTask {
    let request: URLSessionDownloadTask
    
    init(for url: URL, from start: Int64, to end: Int64, in session: URLSession, order num: Int) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Range"] = "bytes=\(start)-\(end - 1)"
        
        
        self.request = session.downloadTask(with: request, completionHandler: { tempUrl, response, error in
            do {
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("audio.m4a")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                print(fileUrl)
                AudioManager().setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                MultiPartsDownloadTask().que = true
            }
            catch {
                
            }
        })
    }
}
class MultiPartsDownloadTask: ObservableObject{
    fileprivate var parts = [DownloadTask]()
    public var que = false
    func createDownloadParts(url: URL, size: Int64) {
        let numberOfRequests = 1
        for i in 0..<numberOfRequests {
            let start = Int64(ceil(CGFloat(Int64(i) * size) / CGFloat(numberOfRequests)))
            let end = Int64(ceil(CGFloat(Int64(i + 1) * size) / CGFloat(numberOfRequests)))
            parts.append(DownloadTask(for: url, from: start, to: end, in: URLSession(configuration: .default), order: i))
        }
        parts.forEach({ $0.request.resume()})
        
    }
}
