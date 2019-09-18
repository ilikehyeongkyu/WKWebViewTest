//
//  ViewController.swift
//  WebViewTest
//
//  Created by Hank.Lee on 18/09/2019.
//  Copyright © 2019 hyeongkyu. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    private let jsCodeToInject = """
        // m.daum.net 의 검색 input에 임의의 텍스트를 삽입한다.
        function testInjectedJavascript() {
            $("input#q.tf_keyword")[0].value = 'hooray! javascript is INJECTED!';
        }

        // native 영역에서 pushViewController를 실행한다.
        function pushViewController() {
            webkit.messageHandlers.kakaoWebViewController.postMessage('pushViewController');
        }
        """
    
    private lazy var webView: WKWebView = {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "kakaoWebViewController")
        
        let userScript = WKUserScript(source: jsCodeToInject, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "WebView"
        
        addWebView()
        loadURL()
    }
    
    private func addWebView() {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            view.topAnchor.constraint(equalTo: webView.topAnchor),
            view.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
            ])
        webView.navigationDelegate = self
    }
    
    private func loadURL() {
        let url = URL(string: "https://www.daum.net")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func addMenuButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(showMenu))
    }
    
    @objc private func showMenu() {
        let alert = UIAlertController(title: "Test", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "js: testInjectedJavascript()", style: .default, handler: { (action) in
            let jsCode = "testInjectedJavascript();"
            self.evaluateJavaScript(jsCode: jsCode)
        }))
        
        alert.addAction(UIAlertAction(title: "js: pushViewController()", style: .default, handler: { (action) in
            let jsCode = "pushViewController();"
            self.evaluateJavaScript(jsCode: jsCode)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func evaluateJavaScript(jsCode: String) {
        print("evaluate javascripti = \n\(jsCode)")
        
        webView.evaluateJavaScript(jsCode, completionHandler: { (result, error) in
            guard let error = error else {
                print("yeah!, evaluate javascript no error!")
                return
            }
            print("WTF!, javascript error = \(error)")
        })
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview did finish navigation")
        addMenuButton()
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if "pushViewController" == message.body as? String {
            navigationController?.pushViewController(SecondViewController(), animated: true)
        }
    }
}
