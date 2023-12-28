//
//  ManualView.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 12/25/23.
//

import SwiftUI

struct ManualList: View {
    @AppStorage("userOnboarded") var userOnboarded: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var cheer = ["cheer 1","cheer 2","cheer 3","cheer 4","cheer 5"]
    var cheerMent = [
        "마이크 모양의 버튼을 누르세요.",
        "입력창에 친구를 응원할 멘트를 입력하세요.",
        "노래하는 친구에게 보여주어 응원해주세요!",
        "차트 뷰에서 곡검색을 버튼을 눌러 곡을 검색하세요",
        "노래방 곡번호를 검색하여 빠르게 예약이 가능합니다."
    ]
    
    var NearByConnect = ["NearByConnect 1","NearByConnect 2","NearByConnect 3"]
    var NBCMent = [
        "⠇을 누르고 영상공유하기를 선택하세요.",
        "연결할 디바이스 모두 디바이스 찾기를 켜고 파란색인 디바이스를 선택한 후 초록색으로 변하면 열결된 것입니다.",
        "연두색으로 변한 상태에서 한번 더 눌러 이미지의 버튼을 누르면 예약됩니다."
    ]
    
    var wheel = ["Wheel 1", "Wheel 2" ,"Wheel 3" ,"Wheel 4"]
    var wheelMent = [
        "휠을 탭한 상태에서 휠의 색이 변하면 음정과 템포를 조절할 수 있습니다.",
        "휠의 음정을 선택한 상태에서 휠을 좌우로 움직이면 음정이 변합니다.",
        "휠의 템포를 선택한 상태에서 휠을 좌우로 움직이면 음정이 변합니다.",
        "영상의 좌우를 더블탭하여 앞뒤 15초로 이동할 수 있습니다."
        
    ]
    
    var body: some View {
        NavigationStack{
            List{
                NavigationLink("노래방에서 사용가능한 기능") {
                    ManualView(manualImage: cheer, manualMent: cheerMent, title: "노래방에서 사용가능한 기능")
                }
                NavigationLink("다른 애플기기에 예약하기") {
                    ManualView(manualImage: NearByConnect, manualMent: NBCMent, title: "다른 애플기기에 예약하기")
                }
                NavigationLink("템포 및 음정 조작법") {
                    ManualView(manualImage: wheel, manualMent: wheelMent, title: "템포 및 음정 조작법")
                }
            }
            .listStyle(.plain)
            .foregroundStyle(.orange)
            .navigationTitle("너튜브 노래방 사용법")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                if !userOnboarded {
                    Button {
                        userOnboarded = true
                        dismiss()
                    } label: {
                        Text("닫기")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
    }
}

struct ManualView: View {
    
    
    var manualImage: [String]
    var manualMent: [String]
    var title: String
    
    var body: some View {
        VStack{
            Text(title)
                .font(.title)
                .bold()
            TabView{
                ForEach(0...(manualImage.count-1), id: \.self){ viewNum in
                    ScrollView{
                        VStack{
                            Image(manualImage[viewNum])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 500)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Text(manualMent[viewNum])
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                }
            }.tabViewStyle(.page)
        }
    }
}

#Preview {
    ManualList()
}
