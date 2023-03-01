//
//  DownloadManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/01.
//

import Foundation
/// Represents the download of one part of the file
fileprivate class DownloadTask {
  /// The position (included) of the first byte
  let startOffset: Int64
  /// The position (not included) of the last byte
  let endOffset: Int64
  /// The byte length of the part
  var size: Int64 { return endOffset - startOffset }
  /// The number of bytes currently written
  var bytesWritten: Int64 = 0
  /// The URL task corresponding to the download
  let request: URLSessionDownloadTask
  /// The disk location of the saved file
  var didWriteTo: URL?

    init(url: URL, start: Int64, end: Int64, indexs: Int) {
    startOffset = start
    endOffset = end

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields?["Range"] = "bytes=\(start)-\(end - 1)"

      self.request = URLSession(configuration: .default).downloadTask(with: request, completionHandler: { tempUrl, response, error in
          do {
              let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
              let fileUrl = doc.appendingPathComponent("audio\(indexs).m4a")
              if FileManager.default.fileExists(atPath: fileUrl.path()) {
                  try FileManager.default.removeItem(at: fileUrl)
              }
              try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
              print(fileUrl)
          }
          catch{
              
          }
      })
  }
}
class DownloadManager: ObservableObject {
    fileprivate var parts = [DownloadTask]()
    
    func createDownloadParts(size: Int64, url: URL) {
        let numberOfRequests = 100
        for i in 0..<numberOfRequests {
            let start = Int64(ceil(CGFloat(Int64(i) * size) / CGFloat(numberOfRequests)))
            let end = Int64(ceil(CGFloat(Int64(i + 1) * size) / CGFloat(numberOfRequests)))
            parts.append(DownloadTask(url: url, start: start, end: end, indexs: i))
        }
        parts.forEach({ $0.request.resume() })
    }
}
