import SwiftUI
import WebKit

struct MyWebView: UIViewRepresentable {
    
    var UrlTOLoad: String
    
    func makeUIView(context: Context) -> WKWebView {
        let Webview = WKWebView()
        
        guard let url = URL(string: UrlTOLoad) else {
            return WKWebView()
        }
        
        Webview.load(URLRequest(url: url))
        
        return Webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<MyWebView>) {
        
    }
    
    struct MyWebView_Preview: PreviewProvider {
        static var previews: some View {
            MyWebView(UrlTOLoad: "https://dazabamuker.tistory.com")
                .edgesIgnoringSafeArea(.all)
        }
    }
    
}
