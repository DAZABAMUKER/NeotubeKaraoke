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
    @StateObject private var getPopularChart = GetPopularChart()
    private let KY: LocalizedStringKey = "KY karaoke Top 100"
    private let Tj: LocalizedStringKey = "Tj karaoke Top 100"
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack(spacing: 0){
                    //Image(systemName: "crown")
                    Text("인")
                        .font(.largeTitle)
                        .bold()
                    Text("기 ")
                        .font(.title)
                        .bold()
                    Text("차")
                        .font(.largeTitle)
                        .bold()
                    Text("트")
                        .font(.title)
                        .bold()
                    //Image(systemName: "crown")
                }
                .padding(10)
                ScrollView(.horizontal){
                    HStack{
                        Spacer()
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
                                    .frame(height: 100)
                                Text("TJ 가요 \nTop100")
                                    .lineLimit(2)
                                    .tint(.white)
                            }
                            .frame(height: 170)
                        }.shadow(color: Color.black.opacity(0.8), radius: 7)
                        .onAppear(){
                            getPopularChart.tjKaraoke()
                        }
                        .padding(.horizontal, 10)
                        
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
                                    .frame(height: 100)
                                Text("KY Pop \nTop100")
                                    .tint(.white)
                            }
                        }.shadow(color: Color.black.opacity(0.8), radius: 7)
                        .padding(.horizontal, 10)
                        
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
                                    .frame(height: 100)
                                Text("KY J-Pop \nTop100")
                                    .tint(.white)
                            }
                        }.shadow(color: Color.black.opacity(0.8), radius: 7)
                        .padding(.horizontal, 10)
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
                                    .frame(height: 100)
                                Text("KY 가요 \nTop100")
                                    .tint(.white)
                            }
                        }.shadow(color: Color.black, radius: 7)
                        .padding(.horizontal, 10)
                        
                    }
                }
                .frame(height: 200)
                if showTjChart || showtjPopChart || showTjJPopChart {
                    List{
                        Section{
                            ForEach(0..<getPopularChart.tjChartTitle.count, id: \.self) { index in
                                Button {
                                    self.inputVal = "\(getPopularChart.tjChartTitle[index]) \(getPopularChart.tjChartMusician[index]) tj 노래방"
                                    self.searching = true
                                } label: {
                                    /*
                                    LinearGradient(colors: [
                                        Color(red: 1, green: 112 / 255.0, blue: 0),
                                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                                    ],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing
                                    )
                                    .frame( height: 30)
                                    .mask(alignment: .center) {
                                        HStack{
                                            Text(String(Int(index) + 1))
                                            Text(getPopularChart.tjChartTitle[Int(index)])
                                            Spacer()
                                            Text(getPopularChart.tjChartMusician[Int(index)])
                                        }
                                        .bold()
                                    }
                                     */
                                    HStack{
                                        Text(String(Int(index) + 1))
                                        Text(getPopularChart.tjChartTitle[Int(index)])
                                        Spacer()
                                        Text(getPopularChart.tjChartMusician[Int(index)])
                                    }
                                    .foregroundColor(.orange)
                                    .bold()
                                }
                            }
                            VStack{}.frame(height: 70)
                        } header: {
                            VStack{
                                if showTjChart {
                                    Text("TJ 가요 Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                if showtjPopChart {
                                    Text("TJ Pop Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                if showTjJPopChart {
                                    Text("TJ J-Pop Top100")
                                        .bold()
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                if showKYChart {
                    List{
                        Section{
                            ForEach(0..<getPopularChart.KYChartTitle.count, id: \.self) { index in
                                Button {
                                    self.inputVal = "\(getPopularChart.KYChartTitle[index]) \(getPopularChart.KYChartMusician[index]) 금영 노래방"
                                    self.searching = true
                                } label: {
                                    /*
                                    LinearGradient(colors: [
                                        Color(red: 1, green: 112 / 255.0, blue: 0),
                                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                                    ],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing
                                    )
                                    .frame( height: 30)
                                    .mask(alignment: .center) {
                                        HStack{
                                            Text(String(Int(index) + 1))
                                            Text(getPopularChart.KYChartTitle[Int(index)])
                                            Spacer()
                                            Text(getPopularChart.KYChartMusician[Int(index)])
                                        }
                                        .bold()
                                    }
                                    */
                                    HStack{
                                        Text(String(Int(index) + 1))
                                        Text(getPopularChart.tjChartTitle[Int(index)])
                                        Spacer()
                                        Text(getPopularChart.tjChartMusician[Int(index)])
                                    }
                                    .foregroundColor(.orange)
                                    .bold()
                                }
                            }
                            VStack{}.frame(height: 70)
                        } header: {
                            Text("금영 가요 Top100")
                                .bold()
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        //.listStyle(.plain)
                    }
                }
            }
            .frame(width: geometry.size.width)
            .background(content: {
                ZStack{
                    LinearGradient(colors: [Color(red: 247/255, green: 208/255, blue: 96/255).opacity(0.5), .clear, .clear, .clear], startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.top)
                    VStack{
                        VStack{}
                            .frame(width: 10, height: 50)
                        Image(systemName: "crown")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .foregroundColor(.secondary)
                            .opacity(0.3)
                        Spacer()
                    }
                }
            })
            .preferredColorScheme(.dark)
        }
    }
}

struct TopChart_Previews: PreviewProvider {
    static var previews: some View {
        TopChart(inputVal: .constant("karaoke"), searching: .constant(false))
    }
}
