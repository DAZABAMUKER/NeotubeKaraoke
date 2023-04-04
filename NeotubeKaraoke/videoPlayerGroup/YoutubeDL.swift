
import Foundation
import PythonKit
import PythonSupport

public struct Info: CustomStringConvertible {
    let info: PythonObject
    
    var dict: [String: PythonObject]? {
        Dictionary(info)
    }
    
    public var title: String? {
        dict?["title"].flatMap { String($0) }
    }
    public var formats: [Format] {
        let array: [PythonObject]? = dict?["formats"].flatMap { Array($0) }
        let dicts: [[String: PythonObject]?]? = array?.map { Dictionary($0) }
        return dicts?.compactMap { $0.flatMap { Format(format: $0) } } ?? []
    }
    
    public var description: String {
        "\(dict?["title"] ?? "no title?")"
    }
    public var vidID: String? {
        dict?["webpage_url"].flatMap{ String($0)}
    }
}

//let chunkSize: Int64 = 10_000_000

@dynamicMemberLookup
public struct Format: CustomStringConvertible {
    public let format: [String: PythonObject]
    
    public var url: URL? { self[dynamicMember: "url"].flatMap { URL(string: $0) } }
    public var height: Int? { format["height"].flatMap { Int($0) } }
    
    public var filesize: Int64? { format["filesize"].flatMap { Int64($0) } }
    
    public var isAudioOnly: Bool { self.vcodec == "none" }
    
    public var isVideoOnly: Bool { self.acodec == "none" }
    
    public var description: String {
        "\(format["format"] ?? "no format?") \(format["ext"] ?? "no ext?") \(format["vcodec"] ?? "no vcodec?") \(format["filesize"] ?? "no size?")"
    }
    
    public subscript(dynamicMember key: String) -> String? {
        format[key].flatMap { String($0) }
    }
}

public let defaultOptions: PythonObject = [
    "format": "bestvideo,bestaudio[ext=m4a]",
    "nocheckcertificate": true,
]

open class YoutubeDL: NSObject {
    public enum Error: Swift.Error {
        case noPythonModule
    }
    
    public static var shouldDownloadPythonModule: Bool {
        do {
            _ = try YoutubeDL()
            return false
        }
        catch Error.noPythonModule {
            return true
        }
        catch {
            guard let error = error as? PythonError,
                  case let .exception(e, _) = error,
                  e.description == "No module named 'youtube_dl'" else { // FIXME: better way?
                return false
            }
            return true
        }
    }
    
    public static let latestDownloadURL = URL(string: "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp")!
    
    public static var pythonModuleURL: URL = {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("yt_dlp") else { fatalError() }
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            print(directory)
        }
        catch {
            fatalError(error.localizedDescription)
        }
        return directory.appendingPathComponent("yt_dlp")
    }()
    
    public let version: String?
    
    internal let pythonObject: PythonObject
    
    internal let options: PythonObject
    
    public init(options: PythonObject = defaultOptions) throws {
        guard FileManager.default.fileExists(atPath: Self.pythonModuleURL.path) else {
            throw Error.noPythonModule
        }
        
        let sys = try Python.attemptImport("sys")
        if !(Array(sys.path) ?? []).contains(Self.pythonModuleURL.path) {
            sys.path.insert(1, Self.pythonModuleURL.path)
        }
        
        runSimpleString("""
            class Pop:
                pass
            
            import subprocess
            subprocess.Popen = Pop
            """)
        
        let pythonModule = try Python.attemptImport("yt_dlp")
        pythonObject = pythonModule.YoutubeDL(options)
        
        self.options = options
        
        version = String(pythonModule.version.__version__)
        print(version ?? "version info: nil")
    }
    
    open func extractInfo(url: URL) throws -> (Info?) {
        print(#function, url)
        let info = try pythonObject.extract_info.throwing.dynamicallyCall(withKeywordArguments: ["": url.absoluteString, "download": false, "process": true])
        
        return (Info(info: info))
    }
    
    open func getSearchResults(val: String) {
        do {
            let reslults = try pythonObject.extract_info.throwing.dynamicallyCall(withKeywordArguments: ["": "ytsearch:\(val)", "download": false, "process": true])
            print(Info(info: reslults).vidID)
        }
        catch{
            print(error)
        }
    }
    
    public static func downloadPythonModule(from url: URL = latestDownloadURL, completionHandler: @escaping (Swift.Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location else {
                completionHandler(error)
                return
            }
            do {
                do {
                    try FileManager.default.removeItem(at: pythonModuleURL)
                }
                catch {
                    print(error)
                }
                
                try FileManager.default.moveItem(at: location, to: pythonModuleURL)
                
                completionHandler(nil)
            }
            catch {
                print("모듈 다운 오류")
                print(#function, error)
                completionHandler(error)
            }
        }
        
        task.resume()
    }
}
