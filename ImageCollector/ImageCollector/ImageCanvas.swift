//
//  ImageCanvas.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

//MARK: isLoading 은 나중에 구현하기... 일단 기능 먼저..
class ImageCanvas: NSView {

    @IBOutlet weak var delegate: ImportImageCanvasController!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    var image: NSImage? {
        set {
            if newValue == nil {
                imageView.image = nil
                delegate.replacePlaceholder()
                return
            }
            
            imageView.image = newValue
            isLoading = false
            
            let constrainedSize = newValue!.aspectFitSizeForMaxDimension(Appearance.maxDimension)
            imageView.image?.size = constrainedSize
            
            needsLayout = true
        }
        get {
            return imageView.image
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            imageView.isEnabled = !isLoading
            progressIndicator.isHidden = !isLoading
            if isLoading {
                progressIndicator.startAnimation(nil)
            } else {
                progressIndicator.stopAnimation(nil)
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
    }
    
    override func awakeFromNib() {
        imageView.unregisterDraggedTypes()
        progressIndicator.isHidden = true // explicitly hiding the indicator in order not to catch mouse events

    }
    

    

}

extension ImageCanvas: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return (context == .outsideApplication) ? [.copy] : []
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        var result: NSDragOperation = []
        if let delegate = delegate {
            result = delegate.draggingEntered(forImageCanvas: self, sender: sender)
        }
        return result
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return delegate?.performDragOperation(forImageCanvas: self, sender: sender) ?? true
    }

}
