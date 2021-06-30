//
//  UserCenter.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import Qiniu
import Firebase

typealias HWSuccessCallBack =  (JSON) -> Void
typealias HWFailCallBack = (HawaError) -> Void

class UserCenter: NSObject {
    
    @objc static let shared: UserCenter = UserCenter()
    
    @objc private(set) var theUser: UserModel?
    
    var firebaseToken:String?
    
    var token: String? {
        get{
            return theUser?.token
        }
        set(newValue){
            HWMemberShipModel.shared.loadProduct()
            HWDiamondModel.shared.loadProduct()
            HWChargeFlyManager.shared.startRun()
        }
    }
    
    var userId: Int?{
        get{
            return theUser?.userId
        }
    }
    
    ///野火IM 客户端 id
    var cid: String?
    
    /**************  数据存储  ***************/
    
    var dataContainer: [JSON?] = []
    var pageNo: Int = 0
    var pageSize: Int = 10
    
    var gifts: [JSON?] = []
    
    
    /**************  数据存储  ***************/
    
    
    private override init() {
        super.init()
    }
    
}

extension UserCenter{
    
    // IM 联结
    func connectIM() -> Void {
        let queue = DispatchQueue(label: "connectIM")
        queue.async {
            WFCCNetworkService.sharedInstance()?.connect(String(self.userId!), token: self.token!)
        }
    }
    
    func disconnectIM(_ disnablePush: Bool ) -> Void {
        WFCCNetworkService.sharedInstance()?.disconnect(disnablePush, clearSession: true)
    }
    
    
    func setUserData(_ data: JSON) -> Void {
        theUser?.setData(dataSource: data)
    }
    
    func isLogin() -> Bool {
        return  theUser != nil && theUser?.token != nil
    }
    
    func isVIP() -> Bool {
        return  theUser != nil && (theUser?.vipType)! > 0
    }
    
    func refreshUserInfo() -> Void{
        self.getInfo { (r) in
        } fail: { (e) in
        }
    }
    
    private func clear() -> Void {
        self.theUser = nil
        let fullPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        let fullUrl = URL(fileURLWithPath: fullPath).appendingPathComponent("theUser.data")
        HWChargeFlyManager.shared.stopFly()
        do {
            try FileManager.default.removeItem(at: fullUrl)
        } catch let error {
            debugPrint(error)
            debugPrint("删除失败")
        }
    }
    
    func userDecode() -> Void {
        
        let fullPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        let fullUrl = URL(fileURLWithPath: fullPath).appendingPathComponent("theUser.data")
        
        do {
            let data = try Data.init(contentsOf: fullUrl)
            let theUser = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UserModel
            self.theUser = theUser
            self.token = self.theUser?.token
            self.connectIM()
        } catch let error {
            debugPrint(error)
            debugPrint("解档失败")
        }
        
    }
    
    func userEncode() -> Void {
        
        if isLogin() == true {
            
            let fullPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
            let fullUrl = URL(fileURLWithPath: fullPath).appendingPathComponent("theUser.data")
            do {
                let data: Data
                if #available(iOS 11.0, *) {
                    data = try NSKeyedArchiver.archivedData(withRootObject: theUser as Any, requiringSecureCoding: false)
                } else {
                    data = NSKeyedArchiver.archivedData(withRootObject: theUser as Any)
                }
                try data.write(to:fullUrl)
            } catch let error {
                debugPrint(error)
                debugPrint("归档失败")
            }
            
        }
    }
    
}

extension UserCenter{
    
    ///密码登录
    func pwdLogin(_ account:String, pwd: String, success: @escaping HWSuccessCallBack , fail: @escaping HWFailCallBack) -> Void {
        
        let param : [String: Any] = [
            "account":account,
            "password": pwd,
            "clientId":cid!
        ]
        
        HawaNetWork.shared?.post(url:URL_USER_LOGIN  , params: param, success: { (respond) in
            
            self.theUser = UserModel.init(dataSource: respond)
            self.theUser!.token = respond["token"].string
            self.token = respond["token"].string
            self.getInfo { (repond) in } fail: { (error) in }
            self.connectIM()
            self.userEncode()
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///登录和注册
    func login(_ info:JSON, success: @escaping HWSuccessCallBack , fail: @escaping HWFailCallBack) -> Void {
        
        
        let local = Locale.current.regionCode ?? "IN"
        
        let param : [String: Any] = [
            "type":1,
            "thirdParty": info["thirdParty"].string! as Any,
            "headImg": info["headImg"].string! as Any,
            "birthday": info["birthday"].string! as Any,
            "gender":info["gender"].int! as Any,
            "nickname":info["nickname"].string! as Any,
            "clientId":cid!,
            "countryCode":  local == "IN" ? "IND" : local,
            "firebaseToken": self.firebaseToken ?? "",
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION
        ]
        
        HawaNetWork.shared?.post(url:URL_USER_REGISTER  , params: param, success: { (respond) in
            
            self.theUser = UserModel.init(dataSource: respond)
            self.theUser!.token = respond["token"].string
            self.token = respond["token"].string
            self.getInfo { (repond) in } fail: { (error) in }
            self.connectIM()
            self.userEncode()
            success(respond)
        }, failure: { (error) in
            fail(error)
            
        })
    }
    
    func logtout(_ success: @escaping HWSuccessCallBack , fail: @escaping HWFailCallBack) -> Void {
        
        let param : [String: Any] = [
            "token": token!,
            "userId": userId!,
        ]
        HawaNetWork.shared?.post(url:URL_USER_LOGOUT  , params: param, success: { (respond) in
            success(respond)
            self.disconnectIM(true)
            self.clear()
            
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///获取用户信息
    func getInfo( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack ) -> Void {
        let params = [
            "seeId":UserCenter.shared.userId!,
            "userId":UserCenter.shared.userId!
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_USER_DETAIL, params: params, success: { (respond) in
            self.setUserData(respond)
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
        
    }
    
    /// 更新用户信息
    func updateInfo(_ info: [String : Any], success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack ) -> Void {
        var pa = info
        pa["userId"] = UserCenter.shared.userId!
        HawaNetWork.shared?.post(url: URL_UPDATE_INFO, params: pa, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
        
    }
    
    ///上传图片  通用
    func upLoadImage(_ image: UIImage,success: @escaping (_ path: String)->Void, fail: @escaping HWFailCallBack) -> Void {
        let option = QNUploadOption.init { (key, progress) in
        }
        let manager = QNUploadManager.init()
        
        let imageData = image.jpegData(compressionQuality: 0.7)
        let imageKey = RANDOM_STRING(nil) + "&" + String(image.cgImage!.width) + "x" + String(image.cgImage!.height)
        debugPrint(imageKey)
        manager?.put(imageData, key: imageKey , token: HWAppCenter.shared.getUpLoadImageToken(), complete: { (respond, key, hash) in
            success(key!)
        }, option: option)
    }
    
    
    ///获取注册时随机昵称
    func getRandomNickname( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let local = Locale.current.regionCode ?? "IN"
        
        let params = [
            "countryCode": local == "IN" ? "IND" : local ,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_GET_NICKNAME, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
        
    }
    
    
    func AVAuth(_ receiverId: Int, type: Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "userId":UserCenter.shared.userId! ,
            "receiverId":receiverId,
            "type":type,
            "c": HW_CHANNEL_ID,
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION 
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_VIDEO_AUTH, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    // 音视频钻石消费
    func avConsumeDi(channelID:String, receiveId:Int, type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "channelId":channelID,
            "userId":UserCenter.shared.userId!,
            "receiveId":receiveId,
            "type":type,
            "appVersion":DYDeviceInfo.APP_BUILD_VERSION
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_AV_DI_CONSUME, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 关注
    func followAdd(followId:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "followId":followId,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_FOLLOW_ADD, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 取消关注
    func followRemove(followId:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "followId":followId,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_FOLLOW_REMOVE, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///喜欢
    func likeAdd(dynamicId:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "dynamicId":dynamicId,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_LIKE_ADD, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 取消喜欢
    func likeRemove(dynamicId:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "dynamicId":dynamicId,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_LIKE_REMOVE, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///添加访客
    func addRecentVisit(visitorId:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "visitorId":visitorId,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_ADD_RECENT_VISIT, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///最近访问
    func refreshRecentVisit( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        pageNo = 0
        recentVisit(success: success, fail: fail)
    }
    ///最近访问
    func moreRecentVisit( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        pageNo += 1
        recentVisit(success: success, fail: fail)
    }
    
    ///获取最近访客记录
    func recentVisit( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "pageNo":pageNo,
            "pageSize":pageSize,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_RECENT_VISIT, params: params, success: { (respond) in
            if self.pageNo == 0{
                self.dataContainer = respond["result"].array!
            }else{
                self.dataContainer = self.dataContainer + respond["result"].array!
            }
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    
    //粉丝关注列表
    func refreshFollowFanList(type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        pageNo = 0
        followFanList(type: type, success: success, fail: fail)
    }
    
    //粉丝关注列表
    func moreFollowFanList(type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        pageNo += 1
        followFanList(type: type, success: success, fail: fail)
    }
    
    ///获取关注和粉丝
    func followFanList(type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "pageNo":pageNo,
            "pageSize":pageSize,
            "type":type,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_FOLLOW_FAN_LIST, params: params, success: { (respond) in
            if self.pageNo == 0{
                self.dataContainer = respond["result"].array!
            }else{
                self.dataContainer = self.dataContainer + respond["result"].array!
            }
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    
    ///钻石数剩余数量
    func diamondAmount( success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_DIAMOND, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 创建内购订单
    func creatPaymentOrder(id:Int, type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "payId":id,
            "userId":UserCenter.shared.userId!,
            "payType": 8,
            "type":type
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_CREATE_PAYMENT_ORDER, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 内购验证
    func paymentVerify(orderNumber:String, receipt:String, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "orderNumber":orderNumber,
            "userId":UserCenter.shared.userId!,
            "receipt": receipt,
            "type": 1,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_PAYMENT_VERIFY, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 领取步数钻石
    func stepsDiamond(stepNumber:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "stepNumber":stepNumber,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_STEPS_DIAMOND, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 日常任务信息
    func daliyTaskInfo(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "channel":HW_CHANNEL_ID,
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_DALIY_TASK, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 获取抽奖信息
    func luckyInfo(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "channel":HW_CHANNEL_ID,
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_LUCKY_TURN_INFO, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    
    /// 抽奖
    func luckyGo(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "channel":HW_CHANNEL_ID,
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_LUCKY_GO, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    
    /// 签到信息
    func checkinInfo(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_CHECK_IN_INFO, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    /// 签到
    func checkin(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_CHECK_IN, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///意见反馈， 报告
    func feedback(_ content:String, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
            "type":2,
            "content":content,
            "version": DYDeviceInfo.APP_BUILD_VERSION
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_USER_FEEDBACK, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///拉黑
    func block(_ blockId:Int, type:Int, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
            "blackId":blockId,
            "type":type
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_BLOCK, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///刷新黑名单
    func refreshBlockList(_ success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        self.pageNo = 0
        blockList(success, fail: fail)
    }
    
    /// 加载更多黑名单
    func moreBlockList(_ success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        self.pageNo += 1
        blockList(success, fail: fail)
    }
    
    ///黑名单
    func blockList(_ success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
            "pageNo":self.pageNo,
            "pageSize":self.pageSize
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_BLOCK_LIST, params: params, success: { (respond) in
            
            if self.pageNo == 0{
                self.dataContainer = respond["result"].array!
            }else{
                self.dataContainer = self.dataContainer + respond["result"].array!
            }
            
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///礼物列表
    func giftList(_ success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_GIFT_LIST, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///购买礼物并发送
    func giftBuy(_ giftId:Int,receiverId:Int,success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "giftId":giftId,
            "receiverId":receiverId,
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_GIFT_BUY, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///购买私人相册
    func albumBuy(_ anchorId:Int,success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "anchorId":anchorId
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_ALBUM_BUY, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///聊天消耗钻石
    func messageBuy(_ receiverId:Int,success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        let params = [
            "receiverId":receiverId,
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_MESSAGE_BUY, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    @objc func messageBuy(_ receiverId:Int,success: @escaping (NSDictionary)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "receiveId":receiverId,
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_MESSAGE_BUY, params: params, success: { (respond) in
            success( respond.dictionary! as NSDictionary)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func updateFirebaseToken(_ firebaseToken:String,success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        if self.userId != nil {
            let params = [
                "firebaseToken":firebaseToken,
                "userId":self.userId!,
            ] as [String : Any]
            
            HawaNetWork.shared?.post(url: URL_UPDATE_FIREBASE_TOKEN, params: params, success: { (respond) in
                success(respond)
            }, failure: { (error) in
                fail(error)
            })
        }
    }
    
    ///获取发送消息模板
    @objc func messageTemplate(seeId:Int, success: @escaping (NSArray)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "seeId":seeId,
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_GET_MESSAGE_TEMPLATE, params: params, success: { (respond) in
            
            let ma = NSMutableArray.init();
            for i in respond.array!{
                ma.add(i.dictionaryObject as Any)
            }
            success(NSArray.init(array: ma))
            
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///模板消息回调
    @objc func messageTemplateCallback(reciveID:Int, templateID:Int, success: @escaping ()->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "templateId":templateID,
            "userId":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_MESSAGE_TEMPLATE_CALLBACK, params: params, success: { (respond) in
            success()
        }, failure: { (error) in
            fail(error)
        })
    }
         
    ///推荐关注
     func recommendList(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        HawaNetWork.shared?.get(url: URL_RECOMMEND_FOLLOW_LIST + "/" + String(self.userId!) , params: nil, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///批量关注
     func groupFollow(followIds:String, success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "ids":followIds,
            "id":self.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_GROUP_FOLLOW, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///批量关注
     func getChargeFlies(success: @escaping (JSON)->Void, fail: @escaping HWFailCallBack) -> Void {
        
        let params = [
            "channel":HW_CHANNEL_ID,
            "appVersion":DYDeviceInfo.APP_BUILD_VERSION
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_GET_CHARGE_FLY, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
}
