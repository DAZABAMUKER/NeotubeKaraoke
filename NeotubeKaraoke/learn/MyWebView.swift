import SwiftUI
import WebKit

struct MyWebView: UIViewRepresentable {
    
    var UrlTOLoad: String = "https://www.youtube.com/results?search_query=go"
    
    //var webView: WKWebView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let Webview = WKWebView(frame: .zero, configuration: config)
        Webview.navigationDelegate = context.coordinator
        
        guard let url = URL(string: UrlTOLoad) else {
            return WKWebView()
        }
        
        Webview.load(URLRequest(url: url))
        
        return Webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<MyWebView>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        private let parser = HTMLParser()
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.innerHTML;") { [weak self] result, error in
                guard let html = result as? String, error == nil else {
                    print("Failed to get HTML")
                    return
                }
                self?.parser.parse(html: html)
            }
        }
    }
    
    
    
    
}

struct MyWebView_Preview: PreviewProvider {
    static var previews: some View {
        MyWebView()
        //.edgesIgnoringSafeArea(.all)
    }
}
