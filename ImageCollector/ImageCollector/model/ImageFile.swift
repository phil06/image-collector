//
//  ImageFile.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import SDWebImage

class ImageFile {
    private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var desc: String
    private(set) var cacheKey: String

    init(url: URL, tagName: String) {
        desc = ""
        fileName = url.lastPathComponent
        cacheKey = ""
        thumbnail = NSImage()
        cacheKey = makeCacheKey(tagName: tagName)
        
        getThumbnailImage(url: url)
    }
    
    private func getThumbnailImage(url: URL) {
        SDWebImageManager.shared().imageCache?.queryCacheOperation(forKey: self.cacheKey, options: .queryDataWhenInMemory, done: { (image, data, type) in
            if let downloadedImage = image {
                self.thumbnail = downloadedImage
                NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
            } else {
                SDWebImageManager.shared().loadImage(with: url , options: [.cacheMemoryOnly, .queryDataWhenInMemory], progress: { (a, b, url) in
                }, completed: { (image, data, error, type, bool, url) in
                    self.thumbnail = image!
                    SDWebImageManager.shared().imageCache?.store(image, imageData: data, forKey: self.cacheKey, toDisk: true)
                    NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
                })
            }
        })
    }
    
    private func makeCacheKey(tagName: String) -> String {
        return String.init(format: "%@-%@", tagName, fileName)
    }

}
