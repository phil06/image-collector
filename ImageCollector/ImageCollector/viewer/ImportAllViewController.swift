//
//  ImportAllViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 28/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class ImportAllViewController: NSViewController {
    
    var parser = XMLParser()
    var parseResult = ""
    
    var el_current = ""
    var el_isPassing = false
    
    var isPassedData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let url = "http://api.androidhive.info/pizza/?format=xml"
        let urlToSend = URL(string: url)
        
        parser = XMLParser(contentsOf: urlToSend!)!
        parser.delegate = self
        
        let success:Bool = parser.parse()
        
        if success {
            print("parse success!")
            print(parseResult)
        } else {
            print("parse fail!")
        }
        
    }
    
}

extension ImportAllViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        el_current = elementName
        if elementName == "id" || elementName == "name" || elementName == "cost" || elementName == "description" {
            if elementName == "name" {
                el_isPassing = true
            }
            isPassedData = true
        }
    }
    
    func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        if elementName == "id" || elementName == "name" || elementName == "cost" || elementName == "description" {
            if elementName == "name" {
                el_isPassing = false
            }
            isPassedData = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if el_isPassing {
            parseResult = parseResult + "\n\n" + string
        }
        
        if isPassedData {
            print(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        debugPrint("fail error:\(parseError)")
    }
}
