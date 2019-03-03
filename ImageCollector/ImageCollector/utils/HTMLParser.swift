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
    
    func parsed() throws -> [String] {
        
        var images: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(htmlContent)
            for img in try doc.select("img") {
                let imgSrc = try img.attr("src")
                images.append(imgSrc)
            }
        } catch (let err)  {
            throw err
        }

        return images
    }
}
