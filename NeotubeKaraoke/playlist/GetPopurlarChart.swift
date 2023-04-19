//
//  GetPopurlarChart.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/10.
//

import Foundation
import SwiftSoup

class GetPopularChart: ObservableObject {
    
    @Published var tjChartMusician = [String]()
    @Published var tjChartTitle = [String]()
    @Published var KYChartMusician = [String]()
    @Published var KYChartTitle = [String]()
    
    func tjKaraoke() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/tjsong/song_monthPopular.asp"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(decoding: data!, as: UTF8.self)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjKaraokePop() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/tjsong/song_monthPopular.asp?strType=2"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(decoding: data!, as: UTF8.self)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjKaraokeJPop() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/tjsong/song_monthPopular.asp?strType=3"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(decoding: data!, as: UTF8.self)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjParse(html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            print(document.charset())
            guard let body = document.body() else {
                return
            }
            var MusicianChart = try body.getElementById("BoardType1")?.getElementsByTag("tr").map{try $0.select("td:nth-child(4)")}.map{try $0.text()}
            let titleChart = try body.getElementById("BoardType1")?.getElementsByClass("left").map{try $0.text()}
            MusicianChart?.remove(at: 0)
            DispatchQueue.main.async {
                self.tjChartMusician = MusicianChart!
                self.tjChartTitle = titleChart!
            }
        }
        catch {
            print("tj Parse error:", error)
        }
    }
    func KYKaraoke() {
        self.KYChartTitle = [String]()
        self.KYChartMusician = [String]()
        let baseUrl = "https://kygabang.com/chart/new_week.php"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(decoding: data!, as: UTF8.self)
                self.KYParse(html: content)
                if content.contains("scode=") {
                    let firsts = content.ranges(of: "scode=")
                    let ends = content.ranges(of: "&&amp")
                    let index = content.distance(from: content.startIndex, to: firsts.last!.lowerBound)
                    let scode = String(content[content.index(firsts.first!.lowerBound, offsetBy: 6)...content.index(before: ends.first!.lowerBound)])
                    print(scode)
                    self.KYKaraokePages(page: 2, scode: scode)
                }
            }
        }.resume()
    }
    
    func KYKaraokePages(page: Int, scode: String) {
        if page == 6 {
            //print(self.KYChartTitle)
            //print(self.KYChartMusician)
            return
        }
        let baseUrl = "https://kygabang.com/chart/new_week.php?scode=\(scode)&&page=\(page)"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let content = String(decoding: data!, as: UTF8.self)
                self.KYParse(html: content)
                self.KYKaraokePages(page: page + 1, scode: scode)
            }
        }.resume()
    }
    func KYParse(html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            //print(document.charset())
            guard let body = document.body() else {
                return
            }
            //print(body)
            var titleChart = try body.getElementsByTag("tbody").get(0).getElementsByTag("tr").map{try $0.getElementsByClass("opbt")}.map{try $0.text()}
            var MusicianChart = try body.getElementsByTag("tbody").get(0).getElementsByTag("tr").map{try $0.getElementsByClass("ch_daily_05")}.map{try $0.text()}
            MusicianChart.remove(at: 0)
            titleChart.remove(at: 0)
            //print(MusicianChart)
            //print(titleChart)
            DispatchQueue.main.async {
                self.KYChartMusician.append(contentsOf: MusicianChart)
                self.KYChartTitle.append(contentsOf: titleChart)
            }
        }
        catch {
            print("KY Parse error:", error)
        }
    }
}
