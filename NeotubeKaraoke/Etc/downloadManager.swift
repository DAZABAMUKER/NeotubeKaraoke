//
//  downloadManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/02/21.
//

import Foundation

class DownloadTask {
    var done = false
    
    func dowmloadtask(for url: URL, from start: Int64, to end: Int64, in session: URLSession, order num: Int, taskClass: MultiPartsDownloadTask) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Range"] = "bytes=\(start)-\(end - 1)"
        session.downloadTask(with: request, completionHandler: { tempUrl, response, error in
            do {
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("audio_\(num).m4a")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                //AudioManager().setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                self.done = true
                if taskClass.parts.filter({$0.done == true}).count == taskClass.numberOfRequests {
                    do {
                        try FileManager.default.merge(files: taskClass.urls, to: taskClass.destination)
                        taskClass.que = true
                    }
                    catch {
                        print("merge error: ")
                    }
                }
            }
            catch {
                
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
    var destination = URL(string: "https://dazabamuker.tistory.com")!
    init(parts: [DownloadTask] = [DownloadTask](), que: Int = 0) {
        self.parts = parts
        for i in 0..<numberOfRequests {
            let fileUrl = doc.appendingPathComponent("audio_\(i).m4a")
            self.urls.append(fileUrl)
        }
        self.destination = self.doc.appendingPathComponent("audio.m4a")
        print(self.destination)
    }
    func createDownloadParts(url: URL, size: Int64) {
        print(size)
        for i in 0..<numberOfRequests {
            let start = Int64(ceil(CGFloat(Int64(i) * size) / CGFloat(numberOfRequests)))
            let end = Int64(ceil(CGFloat(Int64(i + 1) * size) / CGFloat(numberOfRequests)))
            let downloadTask = DownloadTask()
            downloadTask.dowmloadtask(for: url, from: start, to: end, in: URLSession(configuration: .default), order: i, taskClass: self)
            parts.append(downloadTask)
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
