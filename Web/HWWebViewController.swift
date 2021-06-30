//
//  HWWebViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/23.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import WebKit

class HWWebViewController: HawaBaseViewController, WKUIDelegate, WKNavigationDelegate {
    
    lazy var webView: WKWebView = {
        let a = WKWebView.init(frame: view.bounds)
        a.uiDelegate = self
        a.navigationDelegate = self
        return a
    }()
    
    var url: String? {
        didSet{
            if url != nil {
                let r = URLRequest.init(url: URL.init(string: url!)!)
                webView.load(r)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        if url != nil {
            let r = URLRequest.init(url: URL.init(string: url!)!)
            webView.load(r)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
    
    
}

