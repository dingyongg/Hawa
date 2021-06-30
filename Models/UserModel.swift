//
//  UserModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserModel :NSObject, NSCoding{

    var vipType: Int = 0
    var vipEndTime: String?
    var viewFeedList: JSON?
    var iconStatus :Int?
    
    @objc var objGender:NSNumber?{
        get{
            return NSNumber(value: gender!)
        }
    }
    var gender :Int?
    var work : String?
    var distance : String?
    var introduceLen : Int?
    var viewShowList: JSON?
    var followCount : Int?
    var maritalStatus : Int?
    var notFans : Int?
    
    @objc  var objAge:NSNumber?{
        get{
            return NSNumber(value: age!)
        }
    }
    var age : Int?
    var videoSkillStatus : Int?
    var weight : Int?
    var fansCount : Int?
    var textIntroduce : String?
    var city : String?
    var height : Int?
    var onlineState : Int?
    var level : Int?
    var anchor : Int?
    var hobby : String?
    var birthday : String?
    var profile : String?
    var countryCode : String?
    var album : JSON?
    var buyGiftList : JSON?
    //        {
    //          "imageUrl" : "http:\/\/main-image.51nvwu.com\/gift\/rose.png",
    //          "giftId" : 5,
    //          "name" : "rose",
    //          "number" : 1
    //        },
    //        {
    //          "imageUrl" : "http:\/\/main-image.51nvwu.com\/gift\/rose.png",
    //          "giftId" : 1,
    //          "name" : "rose",
    //          "number" : 1
    //        }
    
    var stampNumber : Int?
    var account : String?
    
    @objc var objUserId:NSString{
        get{
            return String(userId!) as NSString
        }
    }
    
    var userId : Int?
    var anchorStatus : Int?
    
    
    @objc  var objNickname:NSString{
        get{
            return nickname! as NSString
        }
    }
    var nickname : String?
    var voiceSkillStatus :Int?
    var voiceSignStatus : Int?
    var notSayHello : Int?
    var privateAlbum : JSON?
    var introduceUrl : String?
    var status : Int?
    var visitorRecordCount: Int?
    var headImage : UIImage?
    @objc  var objHeadImg: NSString?{
        get{
            return headImg! as NSString
        }
    }
    var headImg: String?
    var headImgW: CGFloat?
    var headImgH: CGFloat?
    var headImgSizeValide = false
    var stepDiamondtoken: Int = 0
    

    var token: String?

    required init?(coder: NSCoder) {
        token = coder.decodeObject(forKey: "token") as? String
        nickname = coder.decodeObject(forKey: "nickname") as? String
        account = coder.decodeObject(forKey: "account") as? String
        userId = coder.decodeObject(forKey: "userId") as? Int ?? 0
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(token, forKey: "token")
        coder.encode(account, forKey: "account")
        coder.encode(userId, forKey: "userId")

    }
    
    @objc override init() {
        super.init()
    }
    
    init(dataSource: JSON?) {
        super.init()
        if dataSource != nil {
            setData(dataSource: dataSource!)
        }
        self.observeValue(forKeyPath: <#T##String?#>, of: <#T##Any?#>, change: <#T##[NSKeyValueChangeKey : Any]?#>, context: <#T##UnsafeMutableRawPointer?#>)
    }
    
    @objc func setData(dataSource:NSDictionary) -> Void {
        
       let ds = JSON.init(dataSource)
        
        setData(dataSource: ds)
        
    }

    func setData(dataSource:JSON) -> Void {
        
        vipType = dataSource["vipType"].int ?? 0
        vipEndTime = dataSource["vipEndTime"].string
        iconStatus = dataSource["iconStatus"].int
        gender = dataSource["gender"].int
        work = dataSource["work"].string
        distance = dataSource["distance"].string
        introduceLen = dataSource["introduceLen"].int
        followCount = dataSource["followCount"].int
        maritalStatus = dataSource["maritalStatus"].int
        notFans = dataSource["notFans"].int
        age = dataSource["age"].int
        videoSkillStatus = dataSource["videoSkillStatus"].int
        weight = dataSource["weight"].int
        fansCount = dataSource["fansCount"].int
        textIntroduce = dataSource["textIntroduce"].string
        city = dataSource["city"].string
        height = dataSource["height"].int
        onlineState = dataSource["onlineState"].int
        level = dataSource["level"].int
        anchor = dataSource["anchor"].int
        hobby = dataSource["hobby"].string
        birthday = dataSource["birthday"].string
        profile = dataSource["profile"].string
        countryCode = dataSource["countryCode"].string
        album = dataSource["album"]
        buyGiftList = dataSource["buyGiftList"]
        stampNumber = dataSource["buyGiftList"].int
        account = dataSource["account"].string
        headImg = dataSource["headImg"].string
        headImgW = (SCREEN_WIDTH - 10 - 10 - 5) / 2
        headImgH = headImgW! + CGFloat.random(in: 10..<100)
        userId = dataSource["userId"].int
        anchorStatus = dataSource["anchorStatus"].int
        nickname = dataSource["nickname"].string
        voiceSkillStatus = dataSource["voiceSkillStatus"].int
        voiceSignStatus = dataSource["voiceSignStatus"].int
        notSayHello = dataSource["notSayHello"].int
        privateAlbum = dataSource["privateAlbum"]
        introduceUrl = dataSource["introduceUrl"].string
        status = dataSource["status"].int
        visitorRecordCount = dataSource["visitorRecordCount"].int
        viewShowList = dataSource["viewShowList"]
        viewFeedList = dataSource["viewFeedList"]

    }

    deinit {
        print("deinit -- UserModel ")
    }
}

