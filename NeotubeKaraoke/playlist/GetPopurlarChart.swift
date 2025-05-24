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
    @Published var Numbers = [String]()
    @Published var Titles = [String]()
    @Published var Singers = [String]()
    
    func searchSongOfTj(val: String) {
        let baseUrl = "http://m.tjmedia.com/tjsong/song_search_result.asp?strCond=1&natType=&strType=0&strText=\(val)"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        DispatchQueue.main.async {
            self.Numbers = []
            self.Titles = []
            self.Singers = []
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "TJ Data Failed") }
                let content = String(decoding: data, as: UTF8.self)
                self.searchTjSongParse(html: content)
            }
        }.resume()
    }
    
    func searchSongOfKY(val: String) {
        let baseUrl = "https://kysing.kr/search/?category=2&keyword=\(val)"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        DispatchQueue.main.async {
            self.Numbers = []
            self.Titles = []
            self.Singers = []
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "KY Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
                self.searchKYSongParse(html: content)
            }
        }.resume()
    }
    
    func tjKaraoke() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/chart/top100"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
                print(content)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjKaraokePop() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/chart/top100" //"https://www.tjmedia.com/tjsong/song_monthPopular.asp?strType=2"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "tj Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjKaraokeJPop() {
        self.tjChartMusician = [String]()
        self.tjChartTitle = [String]()
        let baseUrl = "https://www.tjmedia.com/tjsong/song_monthPopular.asp?strType=3"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "tj jpop Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
                self.tjParse(html: content)
            }
        }.resume()
    }
    
    func tjParse(html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            print(document.charset())
//            guard let body = document.body() else {
//                return
//            }
            
            let firstLinkTitles:Elements = try document.select(".flex-box").select("p").select("span") //.은 클래스
                    for i in firstLinkTitles {
                        print("title: ", try i.text())
                    }
            
            //var MusicianChart = try document.select("#wrap > div > div.content.chart > div.chart-top > ul > li:nth-child(2) > ul > li.grid-item.title > div > p:nth-child(3)")
            //print(try MusicianChart.map{try $0.text()})
            // .getElementById("BoardType1")?.getElementsByTag("tr").map{try $0.select("td:nth-child(4)")}.map{try $0.text()}
            //#wrap > div > div.content.chart > div.chart-top > ul > li:nth-child(2) > ul > li.grid-item.title > div > p:nth-child(3)
            
            //let titleChart = try body.getElementById("BoardType1")?.getElementsByClass("left").map{try $0.text()}
//            MusicianChart?.remove(at: 0)
//            DispatchQueue.main.async {
//                self.tjChartMusician = MusicianChart ?? []
//                self.tjChartTitle = titleChart ?? []
//            }
        }
        catch {
            print("tj Parse error:", error)
        }
    }
    
    func searchTjSongParse(html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            print(document.charset())
            guard let body = document.body() else {
                return
            }
            let numbers = try body.getElementById("BoardType1")?.getElementsByTag("tr").map{try $0.select("td:nth-child(1)")}.map{try $0.text()}
            guard let numbersUnwraped = numbers else {return}
            let singers = try body.getElementById("BoardType1")?.getElementsByTag("tr").map{try $0.select("td:nth-child(3)")}.map{try $0.text()}
            guard let singersUnwraped = singers else {return}
            let titles = try body.getElementById("BoardType1")?.getElementsByClass("left").map{try $0.text()}
            guard let titlesUnwraped = titles else {return}
            DispatchQueue.main.async {
                self.Numbers = numbersUnwraped.filter{!$0.isEmpty}
                self.Singers = singersUnwraped.filter{!$0.isEmpty}
                self.Titles = titlesUnwraped
                print(self.Numbers)
                print(self.Singers)
                print(self.Titles)
            }
            
        }
        catch {
            print("tj 곡 검색 오류: ", error)
        }
    }
    
    func searchKYSongParse(html: String) {
        do {
            let document = try SwiftSoup.parse(html)
            print(document.charset())
            guard let body = document.body() else {
                return
            }
            let numbers = try body.getElementsByClass("search_chart_num").map{try $0.text()}
            let singers = try body.getElementsByClass("search_chart_list clear").select("span.tit.mo-art").map{try $0.text()}
            let titles = try body.getElementsByClass("search_chart_list clear").select("li.search_chart_tit.clear > span:nth-child(1)").map{try $0.text()}
            DispatchQueue.main.async {
                self.Numbers = numbers.filter{$0 != "곡번호"}
                self.Singers = singers
                self.Titles = titles
                print(numbers)
                print(singers)
                print(titles)
            }
        }
        catch {
            print("KY 곡 검색 오류: ", error)
        }
    }
    
    func KYKaraoke() {
        self.KYChartTitle = [String]()
        self.KYChartMusician = [String]()
        let baseUrl = "https://kygabang.com/chart/new_week.php"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlEncoded) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
                self.KYParse(html: content)
                if content.contains("scode=") {
                    guard let firsts = content.ranges(of: "scode=").first?.lowerBound else {return}
                    guard let ends = content.ranges(of: "&&amp").first?.lowerBound else {return}
                    //let index = content.distance(from: content.startIndex, to: firsts.last!.lowerBound)
                    let scode = String(content[content.index(firsts, offsetBy: 6)...content.index(before: ends)])
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
        guard let url = URL(string: urlEncoded) else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                guard let data = data else { return print(#function, "tj jpop Data Unwarpping Failed") }
                let content = String(decoding: data, as: UTF8.self)
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
