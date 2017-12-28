//
//  ViewController.swift
//  国际化对比
//
//  Created by 谢添才 on 2017/12/25.
//  Copyright © 2017年 谢添才. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let lanArr = ["zh-Hans.lproj","en.lproj"]
        
        let path = "/Users/xietiancai/Desktop/2Dfire/YunCash/CCDHome"
//        let path = "/Users/xietiancai/Desktop/2Dfire/YunCash/YunCash"
        
        let stringsArr = getFilePathWithSuffix(path, "strings").map{path + "/" + $0}
        
        let lanPathArr = lanArr.map { (lan) -> [String] in
           return stringsArr.filter{$0.contains(lan)}
            }
        
        let lanModelArr:[[StringFileModel]] = lanPathArr.map{$0.map{StringFileModel.init(path: $0)}.filter{$0 != nil}.map{$0!}}
        let keyModel:[StringFileModel] = lanModelArr.first!
        for  i in 1..<lanModelArr.count {
            compareModels(keyModel, lanModelArr[i])
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
func compareModels(_ left:[StringFileModel],_ right:[StringFileModel]) {
    let leftTitleArr = left.map{$0.title}
    let rightTiltleArr = right.map{$0.title}
    
    //左侧有的 右侧没有的model 以title为准
    let leftMore = left.filter{!rightTiltleArr.contains($0.title)}
    
    print("\(left.first!.lan) ")
    print(leftMore.map{$0.title}.CH)
    
    //左侧有的 右侧没有的model 以title为准
    let rightMore = right.filter{!leftTitleArr.contains($0.title)}
    
    print("\(right.first!.lan) ")
    print(rightMore.map{$0.title}.CH)
    
    //公共model
    let bothArr = left.filter{rightTiltleArr.contains($0.title)}
    let bothTitle = bothArr.map{$0.title}
    print("\(left.first!.lan)  \(right.first!.lan) ")
    print(bothTitle.CH)
    
    bothTitle.map { (title) -> (StringFileModel,StringFileModel) in
        let leftModel = left.filter{$0.title == title}.first!
        let rightModel = right.filter{$0.title == title}.first!
        return (leftModel,rightModel)
        }.forEach {comPareModelDetail($0.0, $0.1)}
    
    
}

func comPareModelDetail(_ left:StringFileModel,_ right:StringFileModel) {
    
    //各自处理重复key
    let leftDataKeyArr = cheatModelDetail(left)
    let rightDataKeyArr = cheatModelDetail(right)
    
    //处理互相的缺失key
    //right 中缺失的 key
    let rightLost = leftDataKeyArr.filter{!rightDataKeyArr.contains($0)}
    if rightLost.count > 0{
        print("检测到 \(right.lan)  \(right.title) 缺失下列key")
        print(rightLost.CH)
    }
    
    //left 中缺失的 key
    let leftLost = rightDataKeyArr.filter{!leftDataKeyArr.contains($0)}
    if leftLost.count > 0{
        print("检测到 \(left.lan)  \(left.title) 缺失下列key")
        print(leftLost.CH)
    }
    
    
    
    
}

func cheatModelDetail(_ model:StringFileModel)->[String]{
    let dataArr = model.data
    
    var tempdic:[String:Int] = [:]
    let leftNameArr = dataArr.map{$0.name}
    for name in leftNameArr {
        if tempdic[name] == nil{
            tempdic[name] = 1
        }else{
            tempdic[name] = tempdic[name]! + 1
        }
    }
    let repeatKeys = tempdic.filter{$0.value > 1}.map{$0.key}
    if repeatKeys.count != 0{
        print("检测重复 \(model.title)  \(model.lan)")
        let repeatDataArr = dataArr.filter{repeatKeys.contains($0.name)}
        print(repeatDataArr.CH)
    }
    
    return tempdic.map{$0.key}
}



func readDataFormPath(_ path:String) -> String{
    if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)){
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    }
    return ""
}

class StringFileModel:NSObject {
    var title = ""
    var lan = ""
    var otherData = [String]()
    var data = [StringModel]()
    init?(path:String) {
        let pathArr = path.components(separatedBy: "/")
        if pathArr.count < 2{
            return nil
        }
        title = pathArr[pathArr.count - 1]
        lan = pathArr[pathArr.count - 2]
        
        let dataString = readDataFormPath(path)
        let dataArr = dataString.components(separatedBy: "\n").filter{$0 != ""}
        self.data = dataArr.map{StringModel.init(str: $0)}.filter{$0 != nil}.map{$0!}
        self.otherData = dataArr.filter{StringModel.init(str: $0) == nil}
        if self.otherData.count > 0{
            print("未检测数据 \(self.title)  \(self.lan)")
            print(self.otherData.CH)

        }
    }
    
    override var description: String{
        return "title = \(self.title) \n otherData = \(self.otherData.CH) data = \(data.CH)"
    }
}

class StringModel:NSObject {
    
    init?(str:String) {
        let regex = "\"(.)*\"(.)*=(.)*\"(.)*\"(.)*;"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isValid = predicate.evaluate(with: str)
        if !isValid{
            return nil
        }
        let arr = str.components(separatedBy: "=")
        if arr.count == 2{
            self.name = arr[0].myStrInMark
            self.value = arr[1].myStrInMark
            return
        }
        return nil
        
    }
    var name = ""
    var value = ""
    
    override var description: String{
        return "[\"name\" = \(self.name)]  [\"value\" = \(value)]"
    }
    
    
    
}


extension String{
    var myStrInMark:String{
        if let first = self.firstMarkLocation, let last = self.lastMarkLocation{
            return (self as NSString).substring(with: NSRange.init(location: first + 1, length: last - first - 1)) as String
        }
        return ""
        
    }
    
    
    
    var lastMarkLocation:Int?{
        let regularExpression = try! NSRegularExpression(pattern: "\"", options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let matches = regularExpression.matches(in: self, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange.init(location: 0, length: self.count))
        return matches.last?.range.location
    }
    var firstMarkLocation:Int?{
        let regularExpression = try! NSRegularExpression(pattern: "\"", options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let matches = regularExpression.matches(in: self, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange.init(location: 0, length: self.count))
        return matches.first?.range.location
        
    }
    
}


func getFilePathWithSuffix(_ path:String ,_ suffix:String = "png" )->[String]{
    var finArr:[String] = []
    FileManager.default.enumerator(atPath: path)?.forEach({ (item) in
        if let detail = item as? String{
            if detail.hasSuffix(suffix){
                finArr.append(detail)
            }
        }
    })
    return finArr
    
    
}
