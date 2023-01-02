//
//  searcher.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/11/15.
//

import SwiftUI

struct searcher: View{

    
    @State private var inputVal: String = ""
    @State private var isEditing: Bool = false
    @State private var isUpdating: Bool = false
    
    
    public var ResponseItems: [Video]? = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("background")
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                LinearGradient(gradient: .init(
                    colors: [
                      Color(UIColor(red: 0, green: 0, blue: 0, alpha: 1.00)),
                      Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.00))
                    ]
                  ),
                  startPoint: .bottom,
                  endPoint: .top
                ).edgesIgnoringSafeArea(.all)
                
                
/*
                VStack{
                    Rectangle()
                        .frame(height: 120)
                        .edgesIgnoringSafeArea(.all)
                        .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        .shadow(radius: 10)
                    Spacer()
                }
                VStack{
                    Circle()
                        .frame(width: 80)
                        //.foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                        .foregroundColor(Color.gray)
                        .shadow(radius: 10)
                        .offset(x:-170,y:-12)
                    Spacer()
                }
                NavigationView{
        
                    List(videos, id : \.videoID){ Item in
                        //TableCell(Video: Item)
                        /*ForEach(videos, id: \.videoID) { video in
                            HStack() {
                                Image(video.thumbnail)
                                VStack(alignment: .leading) {
                                    Text(video.title)
                                        .bold()
                                        .lineLimit(2)
                                        .background(Color.green)
                                    Text(video.description)
                                        .lineLimit(1)
                                        .background(.blue)
                                }
                                .foregroundColor(Color.white)
                                Spacer()
                            }
                            .frame(width: geometry.size.width, height: 60)
                            //.background(.black)
                        }*/
                    }
                    //.frame(width: geometry.size.width, height: geometry.size.height - 60)
                    .background(Color.red)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.yellow)
                    .padding(.top, 60)
                    .listStyle(.plain)
                    .environment(\.defaultMinListRowHeight, 70)
                }
*/
                //MARK: - TableView
                TableView(isUpdating: $isUpdating)
                    .padding(.top, 60)
                VStack{
                    HStack{
                        Image(systemName: "music.mic.circle")
                            .foregroundColor(Color(UIColor(red: 1, green: 112 / 255.0, blue: 0, alpha: 1)))
                            //.foregroundColor(Color.white)
                            .font(.system(size: 50))
                        TextField("", text: $inputVal, onEditingChanged: {isEditing = $0 })
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .background(border)
                            .foregroundColor(.white)
                            .padding(.trailing, 30)
                            .padding(.leading, 30)
                            .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: "검색"))
                            .onSubmit {
                                let _ = Model().getVideos(vals: inputVal)
                                self.isUpdating = true
                                
                            }
                        Button {
                            self.inputVal = ""
                        } label: {
                            if (self.inputVal.count > 0) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .background(
                        Rectangle()
                            .foregroundColor(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)))
                            .frame(width: geometry.size.width, height: 120)
                            //.offset(y: -geometry.safeAreaInsets.bottom+10)
                            .edgesIgnoringSafeArea(.all)
                            .shadow(radius: 10)
                        
                    )
                    //.padding(.horizontal,-20)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                //.background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)))
                .preferredColorScheme(.dark)
            }
        }
    }
    
    var border: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .padding(-20)
                .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 0.2)))
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(LinearGradient(gradient: .init(
                    colors: [
                        Color(red: 1, green: 112 / 255.0, blue: 0),
                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                    ]
                ),
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing
                ),
                              lineWidth: isEditing ? 4 : 2
                )
                .frame(height: 40)
                .padding(-20)
            
        }
    }
}
struct TableView: UIViewRepresentable {
    @Binding var isUpdating: Bool
    
    var model = Model()
    func makeUIView(context: Context) -> UITableView {
        let view = UITableView()
        //model.delegate = context.coordinator
        return view
    }
    func updateUIView(_ uiView: UITableView, context: Context) {
        uiView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        uiView.delegate = context.coordinator
        uiView.dataSource = context.coordinator
        //model.delegate = context.coordinator
        
        if self.isUpdating {
            //uiView.reloadData()
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate, ModelDelegate {
        //MARK: - ModelDelegate method
        var table: UITableView!
        
        func videoFetched(_ videos: [Video]) {
            print("Food")
            self.videos = videos
            print("?")
            table.reloadData()
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            //let title = self.videos[indexPath.row].title
            //cell.textLabel?.text = title
            cell.textLabel?.text = _contents[indexPath.row]
            return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //return self.videos.count
            return _contents.count
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
        
        var videos = [Video]()
        var _contents = [
            "Apple", "Banana", "Melon", "Banana", "Melon", "Banana", "Melon", "Banana", "Melon"]
    }
}


struct searcher_Previews: PreviewProvider {
    static var previews: some View {
        searcher()
    }
}
