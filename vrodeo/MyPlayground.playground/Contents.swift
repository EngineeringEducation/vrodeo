//: Playground - noun: a place where people can play

import UIKit

var str = "asset=Optional(ALAsset - Type:Video, URLs:assets-library://asset/asset.MOV?id=9D2DC8CB-7A98-465E-967D-1C550E9FCAF6&ext=MOV)"

var strArr1 = str.

var strArr = str.stringByReplacingOccurrencesOfString("Type:Video", withString: "", options: nil, range: nil)

println(strArr)
