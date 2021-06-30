//
//  HWDynamicsModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/17.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import SwiftyJSON
import UIKit

class HWDynamicsModel: NSObject {

    var name: String?
    var headUrl: String?
    var sex: Int! = 0
    var time: String?
    var comment: String?{
        didSet{
            let ns = (comment ?? "") as NSString
            let attrs = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
            let frame = ns.boundingRect(with: CGSize.init(width: SCREEN_WIDTH - HAWA_SCREEN_HORIZATAL_SPACE - HAWA_SCREEN_HORIZATAL_SPACE , height: 999), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs, context:nil)
            commentH = frame.size.height
        }
    }
    var imgs: JSON = []{
        didSet{
            if imgs.count == 0 {
                imgsH = 0
            }else if(imgs.count == 1 ){
               
            }else if(imgs.count > 1 && imgs.count < 4){
                imgsH = (SCREEN_WIDTH - 30) / 3
            }else{
                imgsH = ((SCREEN_WIDTH - 30) / 3) * 2 + 5 ///图片间隙
            }
        }
    }
    var location: String?
    var viewTimes: Int! = 0
    var shareTimes: Int! = 0
    var commentTimes: Int! = 0
    var userId: Int?

    lazy var likeTimes: Int = {
        return Int(arc4random()%100)
    }()
    
    var liked: Bool = false
    
    var commentH: CGFloat?{
        didSet{
            cellH += commentH!
        }
    }
    var imgsH: CGFloat? = 0{
        didSet{
            cellH += imgsH!
        }
    }
    var cellH: CGFloat! = 150  ///cell初始高

    init(_ dataSource: JSON ) {
        super.init()
        self.setComment(dataSource["des"].string)
        self.setImgs(dataSource["imgs"])
        name = dataSource["nickname"].string
        headUrl = dataSource["headUrlSrc"].string
        sex = dataSource["sex"].int
        time = dataSource["time"].string
        location = dataSource["location"].string
        viewTimes = dataSource["viewTimes"].int
        shareTimes = dataSource["shareTimes"].int
        commentTimes = dataSource["commentTimes"].int
        userId = dataSource["userId"].int
    }
    
    func setComment(_ value: String?) -> Void {
        self.comment = value
    }
    func setImgs(_ value: JSON) -> Void {
        self.imgs = value
    }
    

}
