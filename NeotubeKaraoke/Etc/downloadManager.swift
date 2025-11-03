//
//  downloadManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/21.
//

import Foundation
import SwiftUI

class DownloadTask {
    
    @AppStorage("visitorData") var visitorData: String = ""
    
    var done = false
    
    func dowmloadtask(for url: URL, from start: Int, to end: Int, in session: URLSession, order num: Int, taskClass: MultiPartsDownloadTask, video: Bool) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        request.setValue("IOS", forHTTPHeaderField: "X-YouTube-Client-Name")
//        request.setValue("20.10.4", forHTTPHeaderField: "X-YouTube-Client-Version")
//        request.allHTTPHeaderFields?["Range"] = "bytes=\(start)-\(end - 1)"
//        request.setValue("com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)", forHTTPHeaderField: "User-Agent")
//        request.setValue("en-US,en", forHTTPHeaderField: "accept-language")
//        request.setValue("\(self.visitorData)", forHTTPHeaderField: "X-Goog-Visitor-Id")
//        request.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
//        request.setValue("https://www.youtube.com", forHTTPHeaderField: "Origin")
        
    
        request.setValue("28", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.allHTTPHeaderFields?["Range"] = "bytes=\(start)-\(end - 1)"
        request.setValue("com.google.android.apps.youtube.vr.oculus/1.60.19 (Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip", forHTTPHeaderField: "User-Agent")
        request.setValue("en-US,en", forHTTPHeaderField: "accept-language")
        //request.setValue("\(self.visitorData)", forHTTPHeaderField: "X-Goog-Visitor-Id")
        request.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
        request.setValue("https://www.youtube.com", forHTTPHeaderField: "Origin")
        
        session.downloadTask(with: request, completionHandler: { tempUrl, response, error in
            if error != nil || response == nil {
                //self.dowmloadtask(for: url, from: start, to: end, in: session, order: num, taskClass: taskClass, video: video)
                print(#function, "completionHandler error or response nil occur")
                return
            }
            guard let tempUrl = tempUrl else {
                print(#function, "tempUrl Unwrap error")
                return
            }
            do {
                print(response)
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("audio_\(num).\(video ? "mp4" : "m4a")")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                
                try FileManager.default.copyItem(at: tempUrl , to: fileUrl)
                //AudioManager().setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                self.done = true
                if taskClass.parts.filter({$0.done == true}).count == taskClass.numberOfRequests {
                    do {
                        if video {
                            DispatchQueue.main.sync {
                                taskClass.destination = doc.appendingPathComponent("audio.mp4")
                            }
                        }
                        try FileManager.default.merge(files: taskClass.urls, to: taskClass.destination)
                        DispatchQueue.main.async {
                            taskClass.que = true
                        }
                    }
                    catch {
                        print("merge error: ")
                    }
                }
            }
            catch {
                print(#function, error)
            }
        }).resume()
    }
}
class MultiPartsDownloadTask: ObservableObject{
    var parts: [DownloadTask] = []
    @Published var que = false 
    let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var urls = [URL]()
    let numberOfRequests = 20
    @Published var destination = URL(string: "https://dazabamuker.tistory.com")!
    init(parts: [DownloadTask] = [DownloadTask](), que: Int = 0) {
        self.parts = parts
        for i in 0..<numberOfRequests {
            let fileUrl = doc.appendingPathComponent("audio_\(i).m4a")
            self.urls.append(fileUrl)
        }
        self.destination = self.doc.appendingPathComponent("audio.m4a")
        print(self.destination)
    }
    func reset(parts: [DownloadTask] = [DownloadTask](), que: Int = 0) {
        self.que = false
        self.parts = parts
        for i in (0..<numberOfRequests).reversed() {
            let fileUrl = doc.appendingPathComponent("audio_\(i).m4a")
            self.urls.append(fileUrl)
        }
        self.destination = self.doc.appendingPathComponent("audio.m4a")
        print(self.destination)
    }
    func createDownloadParts(url: URL, size: Int, video: Bool) {
        //print(size)
        self.urls = []
        for i in 0..<numberOfRequests {
            if video {
                let fileUrl = doc.appendingPathComponent("audio_\(i).mp4")
                self.urls.append(fileUrl)
            } else {
                let fileUrl = doc.appendingPathComponent("audio_\(i).m4a")
                self.urls.append(fileUrl)
            }
            let start = Int(ceil(CGFloat(Int(i) * size) / CGFloat(numberOfRequests)))
            let end = Int(ceil(CGFloat(Int(i + 1) * size) / CGFloat(numberOfRequests)))
            let downloadTask = DownloadTask()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                downloadTask.dowmloadtask(for: url, from: start, to: end, in: URLSession(configuration: .default), order: i, taskClass: self, video: video)
                self.parts.append(downloadTask)
            }
            
        }
    }
}


extension FileManager {
  /// Merge the files into one (without deleting the files)
  func merge(files: [URL], to destination: URL, chunkSize: Int = 1000000) throws {
    FileManager.default.createFile(atPath: destination.path, contents: nil, attributes: nil)
    let writer = try FileHandle(forWritingTo: destination)
    try files.forEach({ partLocation in
      let reader = try FileHandle(forReadingFrom: partLocation)
      var data = reader.readData(ofLength: chunkSize)
      while data.count > 0 {
        writer.write(data)
        data = reader.readData(ofLength: chunkSize)
      }
      reader.closeFile()
    })
    writer.closeFile()
  }
}
