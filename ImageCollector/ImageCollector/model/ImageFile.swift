//
//  ImageFile.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class ImageFile {
    private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    
    init (url: URL) {
        
        fileName = url.lastPathComponent
        
        let imageSource = CGImageSourceCreateWithURL(url.absoluteURL as CFURL, nil)
        
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return }
            thumbnail = getThumbnailImage(imageSource: imageSource)
        }
    }
    
    private func getThumbnailImage(imageSource: CGImageSource) -> NSImage? {
        let thumbnailOptions: [String : Any] = [
            String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
            String(kCGImageSourceThumbnailMaxPixelSize): 160
            ]
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
        return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
    }
}
