//
//  TopChart.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/04/19.
//

import SwiftUI

struct TopChart: View {
    @Binding var inputVal: String
    @Binding var searching: Bool
    @State var showTjChart = true // tj 노래방 차트
    @State var showKYChart = false // 금영 노래방 차트
    @State var showtjPopChart = false
    @State var showTjJPopChart = false
    
    @State var searchToggle = false
    
    @StateObject private var getPopularChart = GetPopularChart()
    
    @State var scHeight = 0.0
    @State var scWidth = 0.0
    @State var karaoke: Karaoke = Karaoke.Tj
    @State var titleOfSong = ""
    
    //@Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            GeometryReader{ geometry in
                ZStack{Spacer()}.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    //print(geometry.size.height)
                }
                .onChange(of: geometry.size) { _ in
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            VStack{
                HStack(spacing: 0){
                    //Image(systemName: "crown")
                    Text("곡검색")
                        .foregroundStyle(.clear)
                        .padding()
                    Spacer()
                    Text("인기차트")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .bold()
                    Spacer()
                    Button {
                        self.searchToggle = true
                    } label: {
                        Text("곡검색")
                            .padding(5)
                            .padding(.horizontal, 5)
                            .foregroundStyle(.white)
                            .background{
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(.orange)
                            }
                            .padding()
                    }
                    .sheet(isPresented: self.$searchToggle, content: {
                        HStack{
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.clear)
                                .frame(height: 25)
                            Spacer()
                            Text("노래방 곡번호 검색")
                                .font(.title3)
                                .bold()
                                .padding()
                            Spacer()
                            Button{
                                self.searchToggle = false
                            } label: {
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                                    .foregroundStyle(.orange)
                                    .padding()
                            }
                        }
                        Picker("노래방 곡번호 검색", selection: $karaoke) {
                            Text("Tj").tag(Karaoke.Tj)
                            Text("KY").tag(Karaoke.KY)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        TextField("곡제목", text: $titleOfSong)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .onSubmit {
                                if self.karaoke == .KY {
                                    self.getPopularChart.searchSongOfKY(val: titleOfSong)
                                } else {
                                    self.getPopularChart.searchSongOfTj(val: titleOfSong)
                                }
                                
                            }
                            .padding(5)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .circular)
                                    .foregroundStyle(.secondary.opacity(0.2))
                            }
                            .padding(.horizontal, 10)
                            .padding(5)
                        
                        List{
                            Section{
                                VStack{
                                    HStack{
                                        Text("곡번호")
                                            .bold()
                                            .frame(width: 80)
                                        Text("제목")
                                            .bold()
                                        Spacer()
                                        Text("가수")
                                            .bold()
                                    }
                                    .padding(.top, 5)
                                    Divider()
                                    if !self.getPopularChart.Titles.isEmpty {
                                        ForEach(0..<self.getPopularChart.Titles.count, id: \.self) { index in
                                            VStack{
                                                HStack{
                                                    Text(self.getPopularChart.Numbers[index])
                                                        .frame(width: 80)
                                                    Text(self.getPopularChart.Titles[index])
                                                    Spacer()
                                                    Text(self.getPopularChart.Singers[index])
                                                }
                                                Divider()
                                            }
                                        }
                                    } else if self.getPopularChart.Numbers.contains("검색결과를 찾을수 없습니다.") {
                                        Text("검색결과를 찾을수 없습니다.")
                                    }
                                    Spacer()
                                        .frame(height: 40)
                                }
                            }
                        }
                    })
                    
                }
                //.padding(10)
                //                ScrollView(.horizontal){
                HStack{
                    //Spacer()
                    Button {
                        getPopularChart.tjKaraoke()
                        self.showTjChart = true
                        self.showKYChart = false
                        self.showtjPopChart = false
                        self.showTjJPopChart = false
                    } label: {
                        VStack{
                            Image("tjKaraoke")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                            
                            Text("TJ 가요")
                                .lineLimit(2)
                                .tint(.black)
                        }
                        .offset(x: 0, y: self.showTjChart ? -10 : 0)
                        .scaleEffect(self.showTjChart ? CGSize(width: 1.05, height: 1.05) :  CGSize(width: 1.0, height: 1.0))
                        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: self.showTjChart)
                        //.frame(height: 150)
                    }
                    //.shadow(color: Color.black.opacity(0.8), radius: 7)
                    .onAppear(){
                        getPopularChart.tjKaraoke()
                    }
                    //.padding(.horizontal, 10)
                    
                    Button {
                        getPopularChart.tjKaraokePop()
                        self.showTjChart = false
                        self.showKYChart = false
                        self.showtjPopChart = true
                        self.showTjJPopChart = false
                    } label: {
                        VStack{
                            Image("tjKaraoke")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                            
                            Text("KY Pop")
                                .tint(.black)
                        }
                        .offset(x: 0, y: self.showtjPopChart ? -10 : 0)
                        .scaleEffect(self.showtjPopChart ? CGSize(width: 1.05, height: 1.05) :  CGSize(width: 1.0, height: 1.0))
                        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: self.showtjPopChart)
                    }
                    //.shadow(color: Color.black.opacity(0.8), radius: 7)
                    //.padding(.horizontal, 10)
                    
                    Button {
                        getPopularChart.tjKaraokeJPop()
                        self.showTjChart = false
                        self.showKYChart = false
                        self.showtjPopChart = false
                        self.showTjJPopChart = true
                    } label: {
                        VStack{
                            Image("tjKaraoke")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                            
                            Text("KY J-Pop")
                                .tint(.black)
                        }
                        .offset(x: 0, y: self.showTjJPopChart ? -10 : 0)
                        .scaleEffect(self.showTjJPopChart ? CGSize(width: 1.05, height: 1.05) :  CGSize(width: 1.0, height: 1.0))
                        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: self.showTjJPopChart)
                    }
                    //.shadow(color: Color.black.opacity(0.8), radius: 7)
                    //.padding(.horizontal, 10)
                    Button {
                        getPopularChart.KYKaraoke()
                        self.showTjChart = false
                        self.showKYChart = true
                        self.showtjPopChart = false
                        self.showTjJPopChart = false
                    } label: {
                        VStack{
                            Image("KYkaraoke")
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: 80)
                            
                            Text("KY 가요")
                                .tint(.black)
                        }
                        .offset(x: 0, y: self.showKYChart ? -10 : 0)
                        .scaleEffect(self.showKYChart ? CGSize(width: 1.05, height: 1.05) :  CGSize(width: 1.0, height: 1.0))
                        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/, value: self.showKYChart)
                    }
                    //.shadow(color: Color.black, radius: 7)
                    //.padding(.horizontal, 10)
                    
                }
                //.border(.red)
                //                }
                //                .frame(height: 200)
                if showTjChart || showtjPopChart || showTjJPopChart {
                    List{
                        Section{
                            ForEach(0..<getPopularChart.tjChartTitle.count, id: \.self) { index in
                                Button {
                                    self.inputVal = "\(getPopularChart.tjChartTitle[index]) \(getPopularChart.tjChartMusician[index]) tj 노래방"
                                    self.searching = true
                                } label: {
                                    
                                    HStack{
                                        Text(String(Int(index) + 1))
                                        Text(getPopularChart.tjChartTitle[Int(index)])
                                        Spacer()
                                        Text(getPopularChart.tjChartMusician[Int(index)])
                                    }
                                    .foregroundColor(.black)
                                    //.bold()
                                }
                            }
                            VStack{}.frame(height: 70)
                        } header: {
                            VStack{
                                if showTjChart {
                                    Text("TJ 가요 Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                                if showtjPopChart {
                                    Text("TJ Pop Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                                if showTjJPopChart {
                                    Text("TJ J-Pop Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    //.listStyle(.plain)
                }
                if showKYChart {
                    List{
                        Section{
                            ForEach(0..<getPopularChart.KYChartTitle.count, id: \.self) { index in
                                Button {
                                    self.inputVal = "\(getPopularChart.KYChartTitle[index]) \(getPopularChart.KYChartMusician[index]) 금영 노래방"
                                    self.searching = true
                                } label: {
                                    HStack{
                                        Text(String(Int(index) + 1))
                                        Text(getPopularChart.KYChartTitle[Int(index)])
                                        Spacer()
                                        Text(getPopularChart.KYChartMusician[Int(index)])
                                    }
                                    .foregroundColor(.black)
                                    //.bold()
                                }
                            }
                            VStack{}.frame(height: 70)
                        } header: {
                            Text("금영 가요 Top100")
                                .bold()
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                        //.listStyle(.plain)
                    }
                    //.listStyle(.plain)
                }
            }
            .background(Color.secondary.opacity(0.1))
            .frame(width: self.scWidth)
        }
    }
}

struct TopChart_Previews: PreviewProvider {
    static var previews: some View {
        TopChart(inputVal: .constant("karaoke"), searching: .constant(false))
    }
}
