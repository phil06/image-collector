//
//  VideoViewController.swift
//  ImageCollector
//
//  Created by saera on 18/11/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import WebKit

class VideoViewController: NSViewController {

    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var desc: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    var url: String!
    var tag: String!
    var descText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        webview.alphaValue = 0.2
        indicator.isHidden = false
        indicator.startAnimation(nil)
        
        self.desc.cell?.title = self.descText
        
        let videoUrl = URL(string: self.url)!
        let myRequest = URLRequest(url: videoUrl)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.load(myRequest)
    }
    
    @IBAction func saveToFile(_ sender: Any) {
        let userInfo = ["desc": self.desc.cell?.title ]
        NotificationCenter.default.post(name: .WillUpdateCollectionItemDescription , object: self, userInfo: userInfo)
    }
}

extension VideoViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webview.alphaValue = 1
        indicator.stopAnimation(nil)
        indicator.isHidden = true
    }
}
