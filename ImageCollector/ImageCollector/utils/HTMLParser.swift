//
//  HTMLParser.swift
//  ImageCollector
//
//  Created by saera on 02/03/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import SwiftSoup

class HTMLParser: NSObject {
    
    var htmlContent: String!

    init(content: String) {
        htmlContent = content
    }
    
    func parsedIFrame() throws -> [String] {
        
        var frameTags: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            for frame in try doc.select("iframe") {
                let frameSrc = try frame.attr("src")
                frameTags.append(frameSrc)
            }
        } catch (let err)  {
            throw err
        }
        
        return frameTags
    }
    
    func parsed() throws -> [String] {
        
        var images: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            
//            //img src 인거...
//            for img in try doc.select("img") {
//                let imgSrc = try img.attr("src")
//                images.append(imgSrc)
//            }
            
            //a 로 감싸진 img 인거..
            for href in try doc.select("a") {
                if let hasImg = try href.select("img").first() {
                    let imgSrc = try href.attr("href")
                    debugPrint("img href = \(imgSrc)")
                    images.append(imgSrc)
                }
            }
            
        } catch (let err)  {
            throw err
        }

        return images
    }
}
