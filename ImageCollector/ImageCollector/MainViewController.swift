//
//  MainViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    var indicator: DisableIndicator!

    @IBOutlet weak var outlineTagView: NSScrollView!
    
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
    }
    
    @IBAction func openImportWindow(_ sender: Any) {
        let vc = ImportImageCanvasController()
        self.presentAsModalWindow(vc)
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
    

    
    
    @IBAction func test2(_ sender: Any) {
        
        var tags = [Tags]()
        
        //MARK: 계층구조를 어떻게 만들지???? 고민좀 해봐야 함... 
        let tagsDic = ["2019": nil,
//                       "2018": [ ["4월":nil], ["5월":nil], ["6월":nil], ["7월":nil], ["8월":nil] ],
//                       "2016": [ ["11월":nil], ["12월":nil] ],
                       "2015": nil]
        
        for (key, val) in tagsDic {
            let newItem = Tags(name: key, key: String.init(format: "%@-key", key), child: val)
        }
        
        
//        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
//        let dict = NSDictionary(contentsOfFile: path!)
//
//        let tableData = dict!.object(forKey: "NSHumanReadableCopyright")
//
//        debugPrint("tableData >>> \(tableData)")
  
    }
    
    @IBAction func test1(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.filePath)
    }
    
    
    
    
    
    
    //MARK: for TEST
    
    @IBAction func accessDirectory(_ sender: Any) {
        // FileManager 인스턴스 생성
        let fileManager = FileManager()
        
        // 해당 디렉토리 경로
        let desktopPath = "/Users/nhnent/Desktop"
        
        do {
            // contentsOfDirectory(atPath:)가 해당 디렉토리 안의 파일 리스트를 배열로 반환
            let contents = try fileManager.contentsOfDirectory(atPath: desktopPath)
            
            // subpathsOfDirectory(atPath:)가 해당 디렉토리의 하위에 있는 모든 파일을 배열로 반환
            let deeperContents = try fileManager.subpathsOfDirectory(atPath: desktopPath)
            
            print(contents)
            print(deeperContents)
        } catch let error as NSError {
            print("Error access directory: \(error)")
        }
    }
    
    @IBAction func makeDirectory(_ sender: Any) {
        // FileManagerTest.swift
        // FileManager 인스턴스 생성
        let fileManager = FileManager()
        
        // document 디렉토리의 경로 저장
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 해당 디렉토리 이름 지정
        let dataPath = documentsDirectory.appendingPathComponent("FileManger Directory")
        
        do {
            // 디렉토리 생성
            try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
            
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    @IBAction func createFile(_ sender: Any) {
        // FileManagerTest.swift에 추가
        do {
            // FileManagerTest.swift
            // FileManager 인스턴스 생성
            let fileManager = FileManager()
            
            // document 디렉토리의 경로 저장
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // 해당 디렉토리 이름 지정
            let dataPath = documentsDirectory.appendingPathComponent("FileManger Directory")
            
            // 파일 이름을 기존의 경로에 추가
            let helloPath = dataPath.appendingPathComponent("Hello.txt")
            
            // 쓸 내용
            let text = "Hello File From Swift"
            
            do {
                // 쓰기 작업
                try text.write(to: helloPath, atomically: false, encoding: .utf8)
            }
            
            // 파일 이름을 기존의 경로에 추가
            let helloPathRead = dataPath.appendingPathComponent("Hello.txt")
            
            // 내용 읽기
            let text2 = try String(contentsOf: helloPathRead, encoding: .utf8)
            
            print(text2)
            
        } catch let error as NSError {
            print("Error Writing File : \(error.localizedDescription)")
        }
    }
    
    @IBAction func openFileDialog(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            if let result = panel.url {
                let path = result.path
                debugPrint("path : \(path)")
            }
        } else {
            //user clicked 'Cancel'
            return
        }
        
        
    }
    
    
}

