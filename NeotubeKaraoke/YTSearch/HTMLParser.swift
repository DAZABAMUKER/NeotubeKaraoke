//
//  HTMLParser.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/03.
//

import Foundation
import SwiftSoup

class HTMLParser {
    
    public func search(value: String){
        
        let baseUrl = "https://m.youtube.com/results?search_query=" + value
        //let baseUrl = "http://mynf.codershigh.com"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        let dataTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(data: data!, encoding: .utf8)
                self.parse(html: content!)
            }
        }.resume()
    }
    
    func parse(html: String) {
        do {
            //let jsonData = try JSONEncoder().encode(html)
            let document: Document = try SwiftSoup.parse(html)
            guard let body = document.body() else {
                print("Failed to get body element")
                return
            }
            if html.contains("ytInitialData") {
                print("html.contains(ytInitialData)")
                let firsts = html.ranges(of: "ytInitialData")
                let ends = html.ranges(of: "';<")
                let index = html.distance(from: html.startIndex, to: firsts.first!.lowerBound)
                //print(html[ends.first!.lowerBound])
                //print(html[html.index(before: ends.first!.lowerBound)])
                //print(html[html.index(firsts.first!.lowerBound, offsetBy: 16)])
                let ytData = html[html.index(firsts.first!.lowerBound, offsetBy: 17)...html.index(before: ends.first!.lowerBound)].replacingOccurrences(of: "\\x22", with: "\"").replacingOccurrences(of: "\\x7b", with: "{").replacingOccurrences(of: "\\x7d", with: "}").replacingOccurrences(of: "\\x3d", with: "=").replacingOccurrences(of: "x5b", with: "[").replacingOccurrences(of: "x5d", with: "]").replacingOccurrences(of: "\\\"", with: "다자바무커").replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "다자바무커", with: "\\\"")
                //print(String(htmlEncodedString: String(ytData)))
                print(ytData)
                let ytJson = ytData.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(vidSearch.self, from: ytJson!)
                //print(html.distance(from: html.startIndex, to: firsrs.first.startindex))
                //print(html)
            }
            //let start = html.distance(from: html.startIndex, to: "ytInitialData".startIndex)
            print("\n\n")
            /*
            let titles = try body.select("#app > div.page-container > ytm-search > ytm-section-list-renderer > lazy-list > ytm-item-section-renderer > lazy-list > ytm-video-with-context-renderer").array()
            //let data = try titles?.first?.text()
            print(titles)
            
            for item in titles {
                let t = try item.select("ytm-media-item > div > div.media-item-info.cbox > div > a > h3 > span").text()
                print(t)
            }*/
            
        }
        catch {
            print(error)
        }
    }
}

/*
struct HeadLine: Decodable {
    let title: String
    enum CodingKeys: String, CodingKey {
        case title = "text"
        case runs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var runsContainer = try container.nestedUnkeyedContainer(forKey: .runs)
        let runsContainers = try runsContainer.nestedContainer(keyedBy: CodingKeys.self)
        self.title = try runsContainers.decode(String.self, forKey: .title)
    }
    
}

struct ShortBylineText: Decodable {
    let channelTitle: String
    
    enum CodingKeys: String, CodingKey {
        case channelTitle = "text"
        case runs
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var runsContainer = try container.nestedUnkeyedContainer(forKey: .runs)
        let runsContainers = try runsContainer.nestedContainer(keyedBy: CodingKeys.self)
        self.channelTitle = try runsContainers.decode(String.self, forKey: .channelTitle)
    }
}

struct LengthText: Decodable {
    let runTIme: String
    
    enum CodingKeys: String, CodingKey {
        case runTIme = "text"
        case runs
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var runsContainer = try container.nestedUnkeyedContainer(forKey: .runs)
        let runsContainers = try runsContainer.nestedContainer(keyedBy: CodingKeys.self)
        self.runTIme = try runsContainers.decode(String.self, forKey: .runTIme)
    }
}
*/

struct VideoWithContextRenderer: Decodable {
    var videoId: String = ""
    
    var vidLength: String = ""
    var channelTitle: String = ""
    var title: String = ""
    
    enum CodingKeys: CodingKey {
        case videoId
        case lengthText
        case shortBylineText
        case headline
        
        case videoWithContextRenderer
    }
    
    enum YtBaseCodingKeys: String, CodingKey {
        case values = "text"
        case runs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("do")
        let videoContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .videoWithContextRenderer)
        print("GO GO GO")
        self.videoId = try videoContainer.decode(String.self, forKey: .videoId)
        
        let lengthTextContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .lengthText)
        var lengthTextRunsContainer = try lengthTextContainer.nestedUnkeyedContainer(forKey: .runs)
        let lengthTextRunsContainers = try lengthTextRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.vidLength = try lengthTextRunsContainers.decode(String.self, forKey: .values)
        
        let shortBylineTextContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .shortBylineText)
        var shortBylineTextRunsContainer = try shortBylineTextContainer.nestedUnkeyedContainer(forKey: .runs)
        let shortBylineTextRunsContainers = try shortBylineTextRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.channelTitle = try shortBylineTextRunsContainers.decode(String.self, forKey: .values)
        
        let headlineContainer = try videoContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self, forKey: .headline)
        var headlineRunsContainer = try headlineContainer.nestedUnkeyedContainer(forKey: .runs)
        let headlineRunsContainers = try headlineRunsContainer.nestedContainer(keyedBy: YtBaseCodingKeys.self)
        self.title = try headlineRunsContainers.decode(String.self, forKey: .values)
        print(title)
    }
    
}

struct vidSearch:  Decodable {
    //let videoWithContextRenderer: VideoWithContextRenderer
    let result: [VideoWithContextRenderer]
    enum CodingKeys: String, CodingKey {
        case contents
        case items = "videoWithContextRenderer"
    }
    private enum RootContainerKeys: CodingKey {
        case contents
        case sectionListRenderer
    }
    private enum SectionListContainerKeys: CodingKey {
        case contents
    }
    private enum ItemSectionContainerKeys: CodingKey {
        case contents
        case itemSectionRenderer
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootContainerKeys.self)
        var contents1Container = try container.nestedContainer(keyedBy: RootContainerKeys.self, forKey: .contents)
        let sectionListContainer = try contents1Container.nestedContainer(keyedBy: SectionListContainerKeys.self, forKey: .sectionListRenderer)
        var contents2Container = try sectionListContainer.nestedUnkeyedContainer(forKey: .contents)
        let contens2Containers = try contents2Container.nestedContainer(keyedBy: ItemSectionContainerKeys.self)
        let itemSectionContainer = try contens2Containers.nestedContainer(keyedBy: CodingKeys.self, forKey: .itemSectionRenderer)
        //var contents3Container = try itemSectionContainer.nestedContainer(keyedBy: CodingKeys.self,forKey: .contents)
        //let contents3Containers = try contents3Container.nestedContainer(keyedBy: CodingKeys.self)
        //self.videoWithContextRenderer = try contents3Containers.decode(VideoWithContextRenderer.self, forKey: .items)
        self.result = try itemSectionContainer.decode([VideoWithContextRenderer].self, forKey: .contents)
        //print(self.videoWithContextRenderer.videoId)
        //print(self.videoWithContextRenderer.headline.title)
        /*
        let contents2Container = try sectionListContainer.nestedContainer(keyedBy: SectionListContainerKeys.self, forKey: .contents)
        var contents2Containers = try contents2Container.nestedUnkeyedContainer(forKey: .contents)
        let itemSectionContainer = try contents2Containers.nestedContainer(keyedBy: ItemSectionContainerKeys.self)
        let contents3Container = try itemSectionContainer.nestedContainer(keyedBy: ItemSectionContainerKeys.self, forKey: .contents)
        var contents3Containers = try contents3Container.nestedUnkeyedContainer(forKey: .contents)
        self.videoWithContextRenderer = try contents3Containers.decode(VideoWithContextRenderer.self)
        */
    }
    
}
