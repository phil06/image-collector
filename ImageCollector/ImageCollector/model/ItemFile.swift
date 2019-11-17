//
//  ImageFile.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import SDWebImage

class ItemFile {
    private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var fileUrl: String
    private(set) var cacheKey: String
    var isLoading: Bool!
    var type: SourceType = SourceType.IMAGE

    init(item: String, tagName: String, type: SourceType = SourceType.IMAGE) {
        self.type = type
        
        if type == .IMAGE {
            let itemUrl = URL.init(string: item)!
            
            fileUrl = itemUrl.absoluteString
            fileName = itemUrl.lastPathComponent
            cacheKey = ""
            thumbnail = NSImage()
            isLoading = true
            cacheKey = itemUrl.makeCacheKey(tagName: tagName)
            debugPrint("image url : \(self.fileUrl)")
            getThumbnailImage(url: itemUrl)
        } else {
            fileUrl = item
            fileName = ""
            cacheKey = ""
            thumbnail = NSImage()
            isLoading = true
            cacheKey = ""
        }
    }
    
    
    
    private func getThumbnailImage(url: URL) {
        SDWebImageManager.shared.imageCache.queryImage(forKey: self.cacheKey, options: .queryMemoryData, context: nil, completion: { (image, data, type) in
            if let downloadedImage = image {
                self.thumbnail = downloadedImage
                self.isLoading = false
                NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
            } else {
//                .fromCacheOnly
                SDWebImageManager.shared.loadImage(with: URL.init(string: self.fileUrl)! , options: [ .queryMemoryData], progress: { (a, b, url) in
                    
                }, completed: { (image, data, error, type, bool, url) in
                    self.thumbnail = image!
                    self.isLoading = false
                    SDWebImageManager.shared.imageCache.store(image, imageData: data, forKey: self.cacheKey, cacheType: .disk, completion: nil)
                    NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
                })
            }
        })
    }
    
    private func makeCacheKey(tagName: String) -> String {
        return String.init(format: "%@-%@", tagName, fileName)
    }

}
