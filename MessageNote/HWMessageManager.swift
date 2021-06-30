//
//  HWMessageManager.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/5.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWMessageManager {

    
    let messageInitFrame = CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 0, width: SCREEN_WIDTH-HAWA_SCREEN_HORIZATAL_SPACE-HAWA_SCREEN_HORIZATAL_SPACE, height: 69)
    
    static let shared = HWMessageManager()
    
    private init() {
    
    }
    
    func showOneMessage(_ msg:HWMessage ) -> Void {
        
        if HWAVChatView.shared.status == .rest {
            let msgV = createMessageView(msg)
            UIView.window().addSubview(msgV)
            animateMessageView(msgV)
        }
        self.vibration()
    }
    
    
    
    func createMessageView(_ msg:HWMessage) -> HWMessageNoteView {
        let v = HWMessageNoteView.init(frame: messageInitFrame)
        v.message = msg
        v.alpha = 0
        v.messageTap = { [unowned v] message in
            let conversion = WFCCConversation.init(type: .Single_Type, target: message.target, line: Int32(0))

            let listVC =  WFCUMessageListViewController()
            listVC.conversation = conversion
            listVC.hidesBottomBarWhenPushed = true
            
            let userM = WFUseInfo.init()
            userM.userId = msg.target!
            userM.userInfo = [
                "userId":  msg.target as Any,
                "nickname": msg.nickName as Any,
                "headImg":msg.headImg as Any
            ]
            listVC.targetUserInfo = userM
            
            let window = UIView.window()
            
            if window.rootViewController is HawaTabBarController {
                
                let root = window.rootViewController as! HawaTabBarController
                
                let rootNavi = root.viewControllers?[root.selectedIndex] as! HWBaseNavigationController
                
                rootNavi.pushViewController(listVC, animated: true)
                
            }
            v.removeFromSuperview()
            
        }
        return v
    }
    
    func animateMessageView(_ messageView: HWMessageNoteView?) -> Void {
        UIView.animate(withDuration: 0.4) {
            messageView?.alpha = 1
            messageView?.y = HAWA_STATUS_BAR_HEIGHT
        } completion: { (finish) in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                UIView.animate(withDuration: 0.3) {
                    messageView?.alpha = 0
                } completion: { (finished) in
                    messageView?.removeFromSuperview()
                }
            }
        }
    }
    
    func vibration() -> Void {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

}
