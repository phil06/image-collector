//
//  MainViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//
//https://developer.apple.com/library/archive/samplecode/TableViewPlayground/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010727

import Cocoa

//MARK: reload, scroll 페이지 넘어갈때 확인
class MainViewController: NSViewController {
    
    var indicator: DisableIndicator!
    var tags: [Tags]!
    var itemBeginDrag: Tags!

    @IBOutlet weak var outlineTagView: NSOutlineView!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let path = UserDefaults.standard.string(forKey: UserDefaultKeys.filePath) {
            self.view.window?.title = path
        } else {
  
            indicator = NSView.loadFromNib(nibName: "DisableIndicator", owner: self) as? DisableIndicator
            
            view.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            indicator.message.stringValue = "저장 위치가 설정되어야 사용 가능합니다"

            if let path = PanelManager.shared.openDefaultPathPanel() {
                //view가 window에 추가되기 전에 호출되서 viewDidLoad에선 window의 title에 접근 할 수 없음
                self.view.window?.title = path
                indicator.isHidden = true
            }
        }
        
        self.fetchData()
        
        outlineTagView.delegate = self
        outlineTagView.dataSource = self
        outlineTagView.registerForDraggedTypes([.string])
    }
    
    override func viewWillDisappear() {
        AppSettingFileManager.shared.convertTagData(data: self.tags)
    }
    
    @IBAction func openImportWindow(_ sender: Any) {
        let vc = ImportImageCanvasController()
        self.presentAsModalWindow(vc)
    }
    
    @IBAction func addTag(_ sender: Any) {
        
        var targetIdx = outlineTagView.selectedRow

        if let tagName = AlertManager.shared.showAddTagAlert(messageText: "태그명을 입력해주세요",
                                                                       infoText: "선택한 태그 아래 위치에 추가됩니다. 선택한 태그가 없을경우 이전에 추가된 태그그룹의 최상단에 추가됩니다.",
                                                      okTitle: "추가",
                                                      cancelTitle: "취소",
                                                      suppressionTitle: targetIdx < 0 ? nil : "태그를 선택한 태그의 하위로 추가합니다.") {

            let selectedItem = outlineTagView.item(atRow: targetIdx) as! Tags

            //하위로 추가할때
            if tagName["suppression"] != nil {
                selectedItem.childs?.insert(Tags(name: tagName["input"] as! String, idx: 0), at: 0)
            } else {
                let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx))
                
                if let parent = parentOfSelected as? Tags {

                    if let foundIdx = findGroupIndexByKey(arr: parent.childs!, keyToFind: selectedItem.key) {
                        targetIdx = foundIdx
                    }
                    
                    let newIdx = targetIdx < 0 ? 0 : targetIdx + 1
                    parent.childs?.insert(Tags(name: tagName["input"] as! String, idx: newIdx), at: newIdx)
                    
                } else {

                    if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: selectedItem.key) {
                        targetIdx = foundIdx
                    }

                    let newIdx = targetIdx < 0 ? 0 : targetIdx + 1
                    self.tags.insert(Tags(name: tagName["input"] as! String, idx: newIdx), at: newIdx)
                }
            }

            outlineTagView.reloadData()
        }
        
    }
    

    
    @IBAction func deleteTag(_ sender: Any) {
        var targetIdx = outlineTagView.selectedRow
        
        guard targetIdx >= 0 else {
            AlertManager.shared.infoMessage(messageTitle: "선택된 태그가 없습니다.")
            return
        }
        
        let selectedItem = outlineTagView.item(atRow: targetIdx) as! Tags
        
        let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx)) as? Tags
        
        if AlertManager.shared.confirmDeleteTag() {
            if parentOfSelected == nil {
                //root에서 삭제
                if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: selectedItem.key) {
                    targetIdx = foundIdx
                }
                self.tags.remove(at: targetIdx)
            } else {
                //부모에서 삭제
                parentOfSelected!.deleteChild(key: selectedItem.key)
            }
            
        }
        
        self.outlineTagView.reloadData()
    }
    
    @IBAction func save(_ sender: Any) {
        AppSettingFileManager.shared.convertTagData(data: self.tags)
    }
    

    
    func fetchData() {
        tags = AppSettingFileManager.shared.readConvertedTagData()
        self.outlineTagView.reloadData()
    }
    
    func findGroupIndexByKey(arr: [Tags], keyToFind: String) -> Int? {
        for (idx, item) in arr.enumerated() {
            if item.key == keyToFind {
                return idx
            }
        }
        return nil
    }
 
}

extension MainViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard self.tags != nil else {
            return 0
        }
        
        if let tag = item as? Tags {
            return (tag.childs?.count)!
        }
        return tags.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let tag = item as? Tags {
            return (tag.childs?.count)! > 0
        }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let tags = item as? Tags {
            return tags.childs![index]
        }
        return self.tags[index]
    }
}

extension MainViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var text = ""
        if let tag = item as? Tags {
            text = tag.name
        }

        let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "tagCell"), owner: self) as! NSTableCellView
        tableCell.textField!.stringValue = text
        return tableCell
    }
    
    //support dran and drop
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        var text = ""
        if let tag = item as? Tags {
            text = tag.name
        }

        let pasteBoard = NSPasteboardItem()
        pasteBoard.setString(text, forType: .string)

        return pasteBoard
    }
    
    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        self.itemBeginDrag = nil
        if draggedItems.count == 1 {
            self.itemBeginDrag = draggedItems.last as? Tags
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if self.itemBeginDrag == nil {
            return NSDragOperation()
        }
        
        var tag = item as? Tags
        
        while (tag != nil) {
            if (tag == self.itemBeginDrag) {
                return NSDragOperation()
            }

            tag = outlineTagView.parent(forItem: tag) as? Tags
        }
        return NSDragOperation.move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        var targetIdx = index

        let oldParent = outlineTagView.parent(forItem: self.itemBeginDrag) as? Tags
        
        var fromIndex: Int = 0
        let tag = item as? Tags
        
        if oldParent == nil {
            
            if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: self.itemBeginDrag.key) {
                fromIndex = foundIdx
            }
            self.tags.remove(at: fromIndex)

        } else {
            if let foundIdx = findGroupIndexByKey(arr: (oldParent?.childs)!, keyToFind: self.itemBeginDrag.key) {
                fromIndex = foundIdx
            }
            oldParent?.childs?.remove(at: fromIndex)
        }
        
        if (oldParent == tag) {
            if (fromIndex < targetIdx) {
                targetIdx = targetIdx - 1;
            }
        }
        
        if tag == nil {
            self.tags.insert(self.itemBeginDrag, at: targetIdx)
        } else {
            tag?.childs?.insert(self.itemBeginDrag, at: targetIdx < 0 ? 0 : targetIdx)
        }
        
        self.itemBeginDrag = nil
        
        outlineTagView.reloadData()
    
        return true

    }
}
