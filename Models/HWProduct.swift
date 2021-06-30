//
//  HWProduct.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/11.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWProduct: NSObject {
    
    var id: Int?
    
    var productId: String?
    
    /// 这款产品价格 展示给用户看，   如： 6.99 美元     99 RNM
    var amount: String?
    
    var explain: String?
    var unit: String?

    init(_ pdct: JSON) {
        id = pdct["id"].int
        productId = pdct["productId"].string
        amount = pdct["amount"].string
        explain = pdct["explain"].string
        super.init()
    }
}

class HWVIPProduct: HWProduct {
    
    var diamondsCount: Int?
    
    var marketPrice: Int?
    
    var textOne: String?
    
    var monthNum: String?
    
    var textTwo: String?
    
    override init(_ pdct: JSON ) {
        diamondsCount = pdct["diamondsCount"].int
        marketPrice = pdct["marketPrice"].int
        textOne = pdct["textOne"].string
        textTwo = pdct["textTwo"].string
        monthNum = textOne?.components(separatedBy: " ").first
        super.init(pdct)
        unit = DYLOCS("Month")
        
    }
}

class HWDiamendProduct: HWProduct {
    /// diamend  accout
    var number: Int?
    
    override init(_ pdct: JSON ) {
        number = pdct["number"].int
        super.init(pdct)
        unit = DYLOCS("Diamond")
    }

}
