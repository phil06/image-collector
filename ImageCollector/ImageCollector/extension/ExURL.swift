//
//  ExNSURL.swift
//  ImageCollector
//
//  Created by saera on 22/08/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

extension URL {
    func makeCacheKey(tagName: String) -> String {
        return String.init(format: "%@-%@", tagName, self.lastPathComponent)
    }
}
