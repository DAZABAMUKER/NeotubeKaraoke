//
//  videoClass.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/03/01.
//
/*
import Foundation
import PythonKit
import PythonSupport

class VidClass: ObservableObject {
    
    @Published var isAppear = false
    @Published var title = ""
    var youtubeDL: YoutubeDL?
    var info: Info?
    var url: URL? {
        didSet {
            guard let url = url else {
                return
            }
            print(url)
            extractInfo(url: url)
        }
    }
    
    func extractInfo(url: URL) {
        guard let youtubeDL = youtubeDL else {
            loadPythonModule()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let info = try youtubeDL.extractInfo(url: url)
                DispatchQueue.main.async {
                    self.info = info
                    self.title = info?.title ?? "nil"
                    guard let formats = info?.formats else {
                        return
                    }
                    //print(info?.format?.url)
                    let bestVideo = formats.filter {!$0.isRemuxingNeeded && !$0.isTranscodingNeeded}.last
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded && $0.height == 1080}.last
                    //let bestVideo = formats.filter { $0.isVideoOnly && !$0.isTranscodingNeeded }.last
                    let bestAudio = formats.filter { $0.isAudioOnly && $0.ext == "m4a" }.last
                    print(bestAudio!, bestVideo!)
                    //print(self.info!)
                    guard let aUrl = bestAudio?.url else { return }
                    guard let vUrl = bestVideo?.url else { return }
                    print(vUrl)
                    //self.audioUrl = aUrl
                    //self.videoUrl = vUrl
                    //print(self.audioUrl)
                    self.loadAVAssets(url: aUrl, size: bestAudio?.filesize ?? 0)
                    //player.prepareToPlay(url: vUrl, audioManager: audioManager, fileSize: bestVideo?.filesize ?? 0)
                }
            }
            catch {
                guard let pyError = error as? PythonError, case let .exception(exception, traceback: _) = pyError else {
                    return
                }
                if (String(exception.args[0]) ?? "").contains("Unsupported URL: ") {
                }
            }
        }
    }
    
    func loadPythonModule() {
        guard FileManager.default.fileExists(atPath: YoutubeDL.pythonModuleURL.path) else {
            downloadPythonModule()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.youtubeDL = try YoutubeDL()
                DispatchQueue.main.async {
                    self.url.map { self.extractInfo(url: $0) }
                }
            }
            catch {
                print(#function, error)
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func downloadPythonModule() {
        YoutubeDL.downloadPythonModule { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    return
                }
                self.loadPythonModule()
            }
        }
    }
    
    func loadAVAssets(url: URL, size: Int64) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Range"] = "bytes=0-\(size)"
        let task: URLSessionDownloadTask = URLSession(configuration: .default).downloadTask(with: request) { tempUrl, urlResponse, error in
            
            do {
                let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileUrl = doc.appendingPathComponent("audio.m4a")
                if FileManager.default.fileExists(atPath: fileUrl.path()) {
                    try FileManager.default.removeItem(at: fileUrl)
                }
                try FileManager.default.copyItem(at: tempUrl!, to: fileUrl)
                print(fileUrl)
                //self.audioManager.setEngine(file: fileUrl, frequency: [32, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000], tone: 0.0)
                self.isAppear = true
            }
            catch {
                
            }
        }
        task.priority = URLSessionTask.highPriority
        task.resume()
    }
    
}
*/
