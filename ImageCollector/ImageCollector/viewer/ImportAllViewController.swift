//
//  ImportAllViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 28/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import WebKit

class ImportAllViewController: ExNSViewController {
    
    enum VIEW_TYPE {
        case WEBVIEW, COLLECTIONVIEW
    }
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var inputUrl: NSTextField!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var returnBtn: NSButton!
    @IBOutlet weak var addBtn: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.configureCollectionView()
        self.toggleView(type: VIEW_TYPE.WEBVIEW)
    }

    @IBAction func extractImages(_ sender: Any) {
        
        webview.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML") { innerHTML, error in
            let htmlParser = HTMLParser(content: innerHTML as! String)
            do {
                let images = try htmlParser.parsed()
                
                if images.count < 1 {
                    AlertManager.shared.infoMessage(messageTitle: "can't found images")
                    return
                }
                
                
                DispatchQueue.main.async {
                    self.collectionImageLoader.fetchData(urlList: images)
                    self.collectionView.reloadData()
                    
                    self.toggleView(type: VIEW_TYPE.COLLECTIONVIEW)
                    
                    self.collectionView.selectAll(nil)
                }
                
                
                
            } catch (let err) {
                self.handleError(err)
            }
        }
    }
    
    @IBAction func returnToWebView(_ sender: Any) {
        self.toggleView(type: VIEW_TYPE.WEBVIEW)
    }
    
    @IBAction func addSelectedToFile(_ sender: Any) {
        for index in collectionView.selectionIndexPaths {
            let imageFile = collectionImageLoader.imageURLForIdexPath(indexPath: index)
//            debugPrint("selected image > \(imageFile.imageUrl)")
            NotificationCenter.default.post(name: .AddImageToTagCollection , object: self, userInfo: ["url": imageFile.imageUrl])
        }
    }
    
    @IBAction func loadUrl(_ sender: Any) {
        let url = URL(string: self.inputUrl!.stringValue)
        let myRequest = URLRequest(url: url!)
        webview.load(myRequest)
    }
    
    private func toggleView(type: VIEW_TYPE) {
        switch type {
        case .WEBVIEW:
            self.webview.isHidden = false
            self.collectionView.isHidden = true
            self.scrollView.isHidden = true
            self.returnBtn.isHidden = true
            self.addBtn.isHidden = true
        case .COLLECTIONVIEW:
            self.webview.isHidden = true
            self.collectionView.isHidden = false
            self.scrollView.isHidden = false
            self.returnBtn.isHidden = false
            self.addBtn.isHidden = false
        }
    }
    
    //MARK: collection view
    private func configureCollectionView() {
        // 1
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 130.0, height: 130.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        // 2
        view.wantsLayer = true
        // 3
        collectionView.layer?.backgroundColor = NSColor.black.cgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
    }
    

}

