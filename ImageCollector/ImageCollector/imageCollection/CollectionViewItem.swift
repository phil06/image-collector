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

    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            
            if let imageFile = imageFile {
                imageView?.image = imageFile.thumbnail
            } else {
                imageView?.image = nil
            }
            
            textField?.isHidden = true
            imageView?.alphaValue = 1
        }
    }
    
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
                self.view.layoutSubtreeIfNeeded()
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
    
}
