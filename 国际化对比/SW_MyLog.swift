//
//  SW_MyLog.swift
//  WeimiSP
//
//  Created by 谢添才 on 16/6/17.
//  Copyright © 2016年 XKJH. All rights reserved.
//

import Foundation

private var CHIndex = 0


//打印i个 /t 用来分清层次
extension String{
    subscript(i: Int)->String{
        if i <= 0{
            return ""
        }
//        return (0..<i).reduce("") {$0.0 + self}
        return Array(repeating: self, count: i).joined()

    }
}


protocol CHPrint {
    var CH:String{ get }
}
extension NSArray:CHPrint{
    var CH:String{ get{
        return (self as Array).CH
        }
    }
}
extension NSDictionary:CHPrint{
    var CH:String{ get{
        return (self as Dictionary).CH
        }
    }
}

extension Array:CHPrint{
    var CH:String{ get{
        return
            self.reduce("(\n") { (R:String, E) -> String in
                var Fin = R
                if  (E as? CHPrint) != nil {
                    CHIndex += 1
                    Fin += "\t"[CHIndex] + (E as! CHPrint).CH
                    CHIndex -= 1
                }else{
                    Fin += "\t"[CHIndex+1]
                    if (E as? String) != nil || (E as? NSString) != nil {
                        Fin += "\"\(E)\",\n"
                    }
                    else {
                        Fin += "\(E),\n"
                    }
                }
                return Fin
                } + "\t"[CHIndex] + ")\n"        }
    }
    
}
extension Dictionary:CHPrint{
    var CH:String{ get{
        var Fin = "[\n"
        
        for E in self {
            Fin += "\t"[CHIndex+1]
            if (E.0 as? String) != nil || (E.0 as? NSString) != nil {
                Fin += "\"\(E.0)\":"
            }
            else{
                Fin += "\(E.0):"
            }
            
            if (E.1 as? CHPrint) != nil{
                CHIndex += 1
                Fin += (E.1 as! CHPrint).CH
                CHIndex -= 1
            }
            else{
                if (E.1 as? String) != nil || (E.1 as? NSString) != nil {
                    Fin += "\"\(E.1)\";\n"
                }
                else{
                    Fin += "\(E.1);\n"
                }
                
            }
            
        }
        Fin +=  "\t"[CHIndex] + "]\n"
        
        return Fin
        
        }
    }
    
}
