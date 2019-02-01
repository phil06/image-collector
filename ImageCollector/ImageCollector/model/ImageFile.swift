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
        thumbnail = NSImage() //요기서 인디케이터 이미지로 설정한 후에... (디폴트)
        cacheKey = makeCacheKey(tagName: tagName)
        
        getThumbnailImage(url: url)
    }
    
    private func getThumbnailImage(url: URL) {
        SDWebImageManager.shared().imageCache?.queryCacheOperation(forKey: self.cacheKey, done: { (image, data, type) in
            if let downloadedImage = image {
                //캐시에 있으면 캐시에 있는걸 가져옴
                self.thumbnail = downloadedImage
                NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
            } else {
                //캐시에 없으면 url에서 가져옴
                SDWebImageManager.shared().loadImage(with: url , options: .cacheMemoryOnly, progress: { (a, b, url) in
    
                }, completed: { (image, data, error, type, bool, url) in
                    self.thumbnail = image!
                    SDWebImageManager.shared().imageCache?.store(image, forKey: self.cacheKey)
                    NotificationCenter.default.post(name: .DidCompleteLoadImage , object: self, userInfo: ["cacheKey": self.cacheKey])
                })
            }
        })
    }
    
    private func makeCacheKey(tagName: String) -> String {
        return String.init(format: "%@-%@", tagName, fileName)
    }

}
