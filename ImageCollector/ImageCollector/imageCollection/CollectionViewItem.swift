//
//  CollectionViewItem.swift
//  ImageCollector
//
//  Created by NHNEnt on 29/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    let fileDicKeyImagePath = "path"
    let fileDicKeyDescription = "desc"
    let fileDicKeyThumbnailImagePath = "thumbPath"
    
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
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
