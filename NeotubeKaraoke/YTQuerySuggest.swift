//
//  YTQuerySuggest.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 4/14/24.
//

import Foundation
import SwiftUI

class YTQuerySuggest: ObservableObject {
    
    @Published var results = [String]()
    
    public func requestQuery(query: String = "노래방") {
        var query = query
        DispatchQueue.main.async {
            self.results = []
        }
        if query.isEmpty {
            return
        }
        print(query)
        let baseUrl = "https://suggestqueries.google.com/complete/search?hl=ko&ds=yt&hjson=t&client=youtube&q=" + query
        //let baseUrl = "http://mynf.codershigh.com"
        let urlEncoded = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlEncoded)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            // if there were any error
            if error != nil || data == nil {
                print(error as Any)
                return
            }
            do {
                let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)
                var strUTF8 = String(data: data!, encoding: String.Encoding(rawValue: encodingEUCKR)) ?? ""
                
                while strUTF8.contains("[\"") {
                    let first = strUTF8.ranges(of: "[\"")
                    let last = strUTF8.ranges(of: "\",")
                    let word = strUTF8[strUTF8.index(first.first!.lowerBound, offsetBy: 2)...strUTF8.index(before: last.first!.lowerBound)]
                    print(word)
                    DispatchQueue.main.async {
                        let pre = String(word)
                        var value = pre
                        if !pre.contains("노래방") {
                            value += " 노래방"
                        }
                        self.results.append(value)
                    }
                    strUTF8.removeSubrange(strUTF8.index(first.first!.lowerBound, offsetBy: 1)...strUTF8.index(last.first!.lowerBound, offsetBy: 1))
                }
                if !strUTF8.contains("[\"") {
                    print("Done!!")
                }
            }
        }.resume()
    }
}

struct ShowQuery: ViewModifier {
    @Binding var query: String
    @Binding var editing: Bool
    @State var scHeight = 300.0
    @State var queryOld: String = ""
    @StateObject var suggestedQuery = YTQuerySuggest()
    var model: Models
    
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func body(content: Content) -> some View {
        VStack{
            content
            if editing {
                List(suggestedQuery.results, id: \.self){ suggest in
                    Button {
                        model.getVideos(val: suggest)
                        self.query = suggest
                        self.editing = false
                        hideKeyboard()
                    } label: {
                        Text(suggest)
                    }

                }
                .listStyle(.plain)
                .frame(height: query.isEmpty ? 0.0 : scHeight)
            }
            if query != queryOld {
                VStack{}
                    .onAppear(){
                        self.queryOld = self.query
                        suggestedQuery.requestQuery(query: query)
                        
                    }
            }
        }
    }
}
