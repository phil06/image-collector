//
//  ImportImageCanvasController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class ImportImageCanvasController: NSViewController {
    
    let supportedClasses = [
        NSURL.self
    ]
    
    let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
        .urlReadingFileURLsOnly: true,
        .urlReadingContentsConformToTypes: [ kUTTypeImage ]
    ]

    @IBOutlet weak var placeholderLabel: NSTextField!
    @IBOutlet weak var imageCanvas: ImageCanvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.title = "Add Image"
        
        view.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
    }
    
    /// updates the canvas with a given image file
    private func handleFile(at url: URL) {
        let image = NSImage(contentsOf: url)
        OperationQueue.main.addOperation {
            self.handleImage(image)
        }
    }
    
    private func handleFile(with url: NSURL) {
        self.handleFile(at: url.absoluteURL!)
    }
    
    /// updates the canvas with a given image
    private func handleImage(_ image: NSImage?) {
        imageCanvas.image = image
    }
    
//    /// displays an error
//    private func handleError(_ error: Error) {
//        OperationQueue.main.addOperation {
//            if let window = self.view.window {
//                self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
//            } else {
//                self.presentError(error)
//            }
//        }
//    }
    
    /// displays a progress indicator
    private func prepareForUpdate() {
//        imageCanvas.isLoading = true
        placeholderLabel.isHidden = true
    }
    
}

extension ImportImageCanvasController: ImageCanvasDelegate {
    
    func draggingEntered(forImageCanvas imageCanvas: ImageCanvas, sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask.intersection([.copy])
    }
    
    func performDragOperation(forImageCanvas imageCanvas: ImageCanvas, sender: NSDraggingInfo) -> Bool {
        
        let pasteBoard = sender.draggingPasteboard
        
        //이미지에 링크가 걸렸으면 링크를 가져오고, 이미지만 있으면 이미지의 URL을 가져옴
        if let imgUrl = NSURL.init(from: pasteBoard) {
            
            self.prepareForUpdate()
            debugPrint("가져온 이미지 URL : \(imgUrl)")
            self.handleFile(with: imgUrl)
        }
        
        return false
        
    }
    
}
