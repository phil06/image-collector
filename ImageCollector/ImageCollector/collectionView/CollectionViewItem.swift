//
//  CollectionViewItem.swift
//  ImageCollector
//
//  Created by NHNEnt on 29/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    
    let currentStyle = InterfaceStyle()

    var imageFile: ItemFile? {
        didSet {
            guard isViewLoaded else { return }
            
            imageView?.image = nil
            
            if let imageFile = imageFile {
                if imageFile.type == .IMAGE {
                    imageView?.image = imageFile.thumbnail
                } else {
                    imageView?.image = NSImage(named: "video_mark")
                }
            }
            
            textField?.isHidden = true
            imageView?.alphaValue = 1
        }
    }
    
    var desc: String? {
        didSet {
            guard isViewLoaded else { return }
            if let desc = desc {
                descText.title = desc
            }
        }
    }
    

    @IBOutlet weak var descText: NSTextFieldCell!
    
    
    @IBOutlet weak var initialIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        allocNotification()
        
        view.wantsLayer = true
        initialIndicator.isHidden = false
        initialIndicator.startAnimation(nil)
    }
    
    override func viewWillAppear() {

    }
    
    override func viewDidAppear() {
        if imageFile?.type == .VIDEO {
            initialIndicator.isHidden = true
            initialIndicator.stopAnimation(nil)
        }
    }
    
    func allocNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadImageView), name: .DidCompleteLoadImage , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .DidCompleteLoadImage , object: nil)
    }
    
    @objc func reloadImageView(notification: Notification) {
        if let data = notification.userInfo as? [String: String] {

            if imageFile?.cacheKey == data["cacheKey"] {
                self.imageView?.image = imageFile?.thumbnail
                initialIndicator.isHidden = true
                initialIndicator.stopAnimation(nil)
            }
        }
    }

    func toggleSelect(stat: Bool) {
        if stat {
            imageView?.alphaValue = 0.5
            textField?.isHidden = false
        } else {
            imageView?.alphaValue = 1
            textField?.isHidden = true
        }
    }
    
    func layoutIndicator() {
        
        guard imageFile?.type != .IMAGE else {
            initialIndicator.isHidden = true
            initialIndicator.stopAnimation(nil)
            return
        }
     
        if (imageFile?.isLoading)! {
            initialIndicator.isHidden = false
            initialIndicator.startAnimation(nil)
            return
        }
//        else {
//            initialIndicator.isHidden = true
//            initialIndicator.stopAnimation(nil)
//        }
        
        initialIndicator.isHidden = true
        initialIndicator.stopAnimation(nil)
    }
    
}
