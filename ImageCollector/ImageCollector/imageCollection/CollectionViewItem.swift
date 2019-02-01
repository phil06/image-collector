//
//  CollectionViewItem.swift
//  ImageCollector
//
//  Created by NHNEnt on 29/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            if let imageFile = imageFile {
                imageView?.image = imageFile.thumbnail
                textField?.stringValue = imageFile.fileName
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        allocNotification()
        
        view.wantsLayer = true
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
                self.view.layoutSubtreeIfNeeded()
            }
        }
    
    }
    
}
