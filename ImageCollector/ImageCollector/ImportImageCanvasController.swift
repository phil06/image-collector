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
    
    var imageURL: NSURL!

    @IBOutlet weak var placeholderLabel: NSTextField!
    @IBOutlet weak var imageCanvas: ImageCanvas!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var addProcessIndicator: NSProgressIndicator!
    @IBOutlet weak var descTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.title = "Add Image"
        self.descTextField.cell?.title = ""
        
        self.toggleButton(isProcessing: false)
        
        view.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
        
        allocNotification()
    }
    

    
    @IBAction func addImageToTag(_ sender: Any) {
        
        self.toggleButton(isProcessing: true)
        
        guard self.imageURL != nil else {
            AlertManager.shared.infoMessage(messageTitle: "이미지를 먼저 가져와주세요")
            self.toggleButton(isProcessing: false)
            return
        }
        
        NotificationCenter.default.post(name: .AddImageToTagCollection , object: self,
                                        userInfo: ["url": self.imageURL.absoluteString!,
                                                   "desc": self.descTextField.cell?.title])
    }
    
    private func toggleButton(isProcessing: Bool) {
        addProcessIndicator.isHidden = !isProcessing
        addButton.isHidden = isProcessing
        
        if isProcessing {
            addProcessIndicator.startAnimation(nil)
        } else {
            addProcessIndicator.stopAnimation(nil)
        }
    }
    
    @objc func stopAnimation() {
        self.toggleButton(isProcessing: false)
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
        imageCanvas.isLoading = true
        placeholderLabel.isHidden = true
    }
    
    //MARK: Notification
    func allocNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopAnimation), name: .DidCompleteAddImageToTagCollection , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .DidCompleteAddImageToTagCollection , object: nil)
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
            self.handleFile(with: imgUrl)
            self.imageURL = imgUrl

        }
        
        return false
        
    }
    
    func replacePlaceholder() {
        AlertManager.shared.infoMessage(messageTitle: "경로를 확인 할 수 없는 타입 입니다.")
        
        imageCanvas.isLoading = false
        placeholderLabel.isHidden = false
        
        self.imageURL = nil
    }
    
}
