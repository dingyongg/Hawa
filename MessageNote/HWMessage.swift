//
//  HWMessage.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/5.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWMessage {

    var headImg: String?
    var nickName: String?
    var message: String?
    var time: String?
    var target: String?

    init(_ dataSource: JSON) {
        
        headImg = dataSource["headImg"].string
        nickName = dataSource["nickName"].string
        message = dataSource["message"].string
        time = dataSource["time"].string

    }

}
