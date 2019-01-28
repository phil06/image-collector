//
//  MainViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//
//https://developer.apple.com/library/archive/samplecode/TableViewPlayground/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010727 참고

import Cocoa

//MARK: 코드중복 리펙토링 필요..
class MainViewController: NSViewController {
    
    var indicator: DisableIndicator!
    var tags: [Tags]!
    var itemBeginDrag: Tags!

    @IBOutlet weak var outlineTagView: NSOutlineView!

    
    
    
    //view가 window에 추가되기 전에 호출되기때문에 window의 title에 접근 할 수 없음
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
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

            setDirectories()
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
        
        let targetIdx = outlineTagView.selectedRow
        
        debugPrint("targetIdx : \(targetIdx)")
        
        if let tagName = AlertManager.shared.showAddTagAlert(messageText: "태그명을 입력해주세요",
                                                                       infoText: "선택한 태그 아래 위치에 추가됩니다. 선택한 태그가 없을경우 이전에 추가된 태그그룹의 최상단에 추가됩니다.",
                                                      okTitle: "추가",
                                                      cancelTitle: "취소",
                                                      suppressionTitle: targetIdx < 0 ? nil : "태그를 선택한 태그의 하위로 추가합니다.") {



            //하위의 하위일떈 어찌되려나... 인덱스가....
            //parent 체그가 필요하겠지...?
            if let addSub = tagName["suppression"] {
                self.tags[targetIdx].childs?.append(Tags(name: tagName["input"] as! String, idx: 0, child: [:]))
            } else {
                
                let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx))
                
                
                let newIdx = targetIdx < 0 ? 0 : targetIdx + 1
                debugPrint("targetIdx > \(targetIdx), newIdx > \(newIdx)")
                self.tags.insert(Tags(name: tagName["input"] as! String, idx: newIdx, child: [:]), at: newIdx)
            }



            outlineTagView.reloadData()
        }
        
    }
    
    func setDirectories() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            if let result = panel.url {
                let path = result.path
                self.view.window?.title = path
                UserDefaults.standard.set(path, forKey: UserDefaultKeys.filePath)
                indicator.isHidden = true
                
                AppSettingFileManager.shared.initFile()
            }
        } else {
            NSApplication.shared.terminate(self)
            return
        }
    }
    
    func fetchData() {
        tags = AppSettingFileManager.shared.readConvertedTagData()
        self.outlineTagView.reloadData()
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    @IBAction func test2(_ sender: Any) {
        
        
        AppSettingFileManager.shared.addField()
        
//        AppSettingFileManager.shared.convertTagData(data: self.tags)
        
        
  
    }
    
    @IBAction func test1(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.filePath)
    }
    
    
    
    
    
    
 
   
    
    
 
    
    
}



/* 봐야할 때가 올지도 모르는거..
 moveItem(at:inParent:to:inParent:)
    https://developer.apple.com/documentation/appkit/nsoutlineview/1530467-moveitem
 */


extension MainViewController: NSOutlineViewDataSource {
    // Tell the view how many children an item has
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard self.tags != nil else {
            return 0
        }
        
        if let tag = item as? Tags {
            return (tag.childs?.count)!
        }
        return tags.count
    }
    
    // Tell the view controller whether an item can be expanded (i.e. it has children) or not
    // (i.e. it doesn't)
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let tag = item as? Tags {
            return (tag.childs?.count)! > 0
        }
        return false
    }
    
    
    

    // Find and return the child of an item. If item == nil, we need to return a child of the
    // root node otherwise we find and return the child of the parent node indicated by 'item'
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let tags = item as? Tags {
            return tags.childs![index]
        }
        return self.tags[index]
    }





}

extension MainViewController: NSOutlineViewDelegate {
    // Add text to the view. 'item' will either be a Creature object or a string. If it's the former we just
    // use the 'type' attribute otherwise we downcast it to a string and use that instead.
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var text = ""
        if let tag = item as? Tags {
            text = tag.name
        } else {
            debugPrint("타입을 알쑤없쒀..")
        }

        // Create our table cell -- note the reference to 'creatureCell' that we set when configuring the table cell
        let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "tagCell"), owner: self) as! NSTableCellView
        tableCell.textField!.stringValue = text
        return tableCell
    }
    
    //support dran and drop
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        //이거 있어도 소용없어 보이는데...
        var text = ""
        if let tag = item as? Tags {
            text = tag.name
        } else {
            debugPrint("타입을 알쑤없쒀..")
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
        //MARK: 최상이 아이템은... item 값이 nil로 오네..?
        
        
        //내가 속해있는 아이템이 아닌.. target으로 지정한 앞으로 속할 아이템
//        if let tag = item as? Tags {

            outlineTagView.beginUpdates()
            
            var childIndex = index
            
            //기존 아이템 리스트에서 제거
            let oldParent = outlineTagView.parent(forItem: self.itemBeginDrag) as? Tags
            
            if oldParent == nil {
                var fromIndex: Int = 0
                for (idx, val) in self.tags.enumerated() {
                    if val == self.itemBeginDrag {
                        fromIndex = idx
                    }
                }
                self.outlineTagView.moveItem(at: fromIndex, inParent: nil, to: childIndex, inParent: nil)
                
                self.tags.remove(at: fromIndex)
                
                if (fromIndex < childIndex) {
                    childIndex = childIndex - 1;
                }
                
                self.tags.insert(self.itemBeginDrag, at: childIndex)
            } else {
                let tag = item as? Tags
                
                //상위 아이템이 있는 아이들
                var fromIndex: Int = 0
                for (idx, val) in (oldParent?.childs?.enumerated())! {
                    if val == self.itemBeginDrag {
                        fromIndex = idx
                    }
                }
                
                oldParent?.childs?.remove(at: fromIndex)
                
                //insert 되기 전에 delete해야 한다
                if (oldParent == tag) {
                    // Consider the item being deleted before it is being inserted.
                    // This is because we are inserting *before* childIndex, and *not* after it (which is what the move API does).
                    if (fromIndex < childIndex) {
                        childIndex = childIndex - 1;
                    }
                }
                
                tag!.childs?.insert(self.itemBeginDrag, at: childIndex)
            }
            
            
            outlineTagView.endUpdates()
            self.itemBeginDrag = nil
            
            outlineTagView.reloadData()
            
            
            
            return true

    }
}
