//
//  HWAVAuthModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/21.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWAVAuthModel: NSObject {
    
    var send:((Int)->Void)?
    
    @objc static let shared: HWAVAuthModel = HWAVAuthModel.init()
    
    var callType: HWAVChatMode?
    var productRespond:JSON?
    
    @objc func objcCallVideo(_ receiver: UserModel) -> Void {
        callType = .video
        self.auth(receiver)
    }
    
    func callVideo(_ receiver: UserModel) -> Void {
        callType = .video
        self.auth(receiver)
        
    }
    
    
    @objc func objcCallAudio(_ receiver: UserModel) -> Void {
        callType =  .audio
        self.auth(receiver)
        
    }
    
    func callAudio(_ receiver: UserModel) -> Void {
        callType =  .audio
        self.auth(receiver)
        
    }
    
    @objc func ObjcsendMessage(_ receiver: UserModel,  send: @escaping(Int)->Void) -> Void {
        self.send = send
        callType = .message
        self.auth(receiver)
    }
    
    
    func sendMessage(_ receiver: UserModel, send: @escaping(Int)->Void) -> Void {
        self.send = send
        callType = .message
        self.auth(receiver)
    }
    
    ///仅用于接受音视频邀请时用
    func receiveAuth(_ receiver: UserModel, result:  @escaping(Int)->Void) -> Void {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        UserCenter.shared.AVAuth(receiver.userId!, type: 0) { (res) in
            SVProgressHUD.dismiss()
            if (HWVideoPlay.shared.player.isPlaying){
                HWVideoPlay.shared.player.pause()
            }
            
            switch res["status"].int {
            
            case 0: // 非会员
                result(-1)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
                    
                    if HWMemberShipModel.shared.products != nil {
                        VipChargeView.init(HWMemberShipModel.shared.products!).present()
                    }else{
                        HWMemberShipModel.shared.loadProduct()
                    }
                }
                
            case 1: //钻石不足
                result(-2)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
                    
                    if HWDiamondModel.shared.products != nil {
                        VipChargeView.init(HWDiamondModel.shared.products!).present()
                    }else{
                        HWDiamondModel.shared.loadProduct()
                    }
                }
                
            case 2, 3: //正常, 审核中
                result(0)
            default: break
                
            }
            
        } fail: { (err) in
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: err.message)
        }
        
        
    }
    
    
    func auth(_ receiver: UserModel) -> Void {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        UserCenter.shared.AVAuth(receiver.userId!, type: 0) { (res) in
            SVProgressHUD.dismiss()
            if (HWVideoPlay.shared.player.isPlaying){
                HWVideoPlay.shared.player.pause()
            }
            
            let chatV = HWAVChatView.shared
            
            if self.callType != .message {
                chatV.setInit(mod: self.callType!, sts: .to)
                if res["anchorId"].int != nil {
                    receiver.userId = res["anchorId"].int
                    //receiver.userId = 15188
                }
                chatV.you = receiver
                chatV.present()
                chatV.videoDidFinishedCallBack = {
                    
                    if res["status"].int == 0 { //非会员
                        if HWMemberShipModel.shared.products != nil {
                            let char =  VipChargeView.init(HWMemberShipModel.shared.products!)
                            char.present()
                            char.didCancelBlock = {
                                chatV.dismiss()
                            }
                        }else{
                            HWMemberShipModel.shared.loadProduct()
                        }
                    }else{
                        if HWDiamondModel.shared.products != nil {
                            let charV =  VipChargeView.init(HWDiamondModel.shared.products!)
                            charV.present()
                            charV.didCancelBlock = {
                                chatV.dismiss()
                            }
                        }else{
                            HWDiamondModel.shared.loadProduct()
                        }
                    }
                }
            }
            
            switch res["status"].int {
            
            case 0: // 非会员
                self.send?(-1)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
                    
                    if res["videoUrl"].string != nil &&  self.callType == .video {
                        chatV.preVideoURL =  res["videoUrl"].string
                    }else{
                        if HWMemberShipModel.shared.products != nil {
                            let char =  VipChargeView.init(HWMemberShipModel.shared.products!)
                            char.present()
                            char.didCancelBlock = {
                                chatV.dismiss()
                            }
                        }else{
                            HWMemberShipModel.shared.loadProduct()
                        }
                    }
                }
                
            case 1: //钻石不足
                self.send?(-1)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() ) {
                    if res["videoUrl"].string != nil && self.callType == .video{
                        chatV.preVideoURL = res["videoUrl"].string
                    }else{
                        if HWDiamondModel.shared.products != nil {
                            let charV =  VipChargeView.init(HWDiamondModel.shared.products!)
                            charV.present()
                            charV.didCancelBlock = {
                                chatV.dismiss()
                            }
                        }else{
                            HWDiamondModel.shared.loadProduct()
                        }
                    }
                }
                
            case 2, 3: //正常, 审核中
                if self.callType != .message {
                    chatV.channalID = res["channelId"].string
                }else{
                    self.send?(0)
                }
            default: break
                
            }
            
        } fail: { (err) in
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: err.message)
        }
        
    }
    
}
