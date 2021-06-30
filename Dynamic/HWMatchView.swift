//
//  HWMatchView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/21.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import Gifu

@objc protocol HWMatchedViewDelegete{
    func matchView(_ view: HWMatchedView, heart:UIButton ) -> Void
    func matchView(_ view: HWMatchedView, chat:UIButton, target:NSDictionary) -> Void
    func matchView(_ view: HWMatchedView, video:UIButton, target:NSDictionary) -> Void
    func matchView(_ view: HWMatchedView, audio:UIButton, target:NSDictionary) -> Void
    func matchView(_ view: HWMatchedView, taped:Int ) -> Void
}

enum HWMatchViewStatus {
    case matching
    case matched
    case stopMatch
}

class HWMatchView: UIView {
    
    weak var controller: UIViewController?

    var status: HWMatchViewStatus? {
        didSet{
            if status == HWMatchViewStatus.matching {
                matchB.setTitle("Stop Match", for: .normal)
                matchedV.removeFromSuperview()
                addSubview(matchingV)
                matchingV.loadingIV.startAnimatingGIF()
            }else if status == HWMatchViewStatus.matched {
                matchB.setTitle("Start Match", for: .normal)
                matchingV.loadingIV.stopAnimatingGIF()
                matchingV.removeFromSuperview()
                addSubview(matchedV)
            }else if status == HWMatchViewStatus.stopMatch{
                matchB.setTitle("Start Match", for: .normal)
                addSubview(matchingV)
                matchingV.loadingIV.stopAnimatingGIF()
            }
        }
    }
    lazy var matchB: HawaBaseButton = {
        let l = HawaBaseButton.init(frame: .zero, title: "Start Match", image: nil, targte: self, action: #selector(matchA))
        return l
    }()
    
    
    lazy var matchedV: HWMatchedView = {
        let v = HWMatchedView.init(frame: self.bounds)
        v.height = v.height - 100
        v.delegate = self
        return v
    }()
    
    lazy var matchingV: HWMatchingView = {
        let v = HWMatchingView.init(frame: self.bounds)
        v.height = v.height - 100
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(matchB)
    
        matchB.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.size.equalTo(CGSize.init(width: 200, height: 66))
            m.bottom.equalToSuperview().offset(-20)
        }
        
        
        //matching()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.status = .stopMatch
    }
    
    
    @objc func matchA(_ sender: UIButton) -> Void {
        
        if self.status == HWMatchViewStatus.stopMatch || self.status == HWMatchViewStatus.matched  {
            self.status = .matching
            
            HWSDModel.shared.matching { (respond) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    if(self.status == .matching){
                        self.matchedV.dataSource = respond
                        self.status = .matched

                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {

                            let chatV = HWAVChatView.shared
                            chatV.setInit(mod: .video, sts: .from)
                            let you = UserModel.init(dataSource: nil)
                            you.headImg = respond["imageUrl"].string
                            you.nickname = respond["nickname"].string
                            you.gender = respond["gender"].int
                            you.userId = respond["userId"].int
                            chatV.you = you
                            
                            chatV.present()
                        }
                    }
                }
                
            } fail: { (error) in
                SVProgressHUD.showError(withStatus: error.message)
            }
        }else if self.status == HWMatchViewStatus.matching {
            self.status = HWMatchViewStatus.stopMatch
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class HWMatchingView: UIView {
        
        lazy var loadingIV: GIFImageView = {

            let path = Bundle.main.path(forResource: "gif_match_loading", ofType: "gif")
            let data = NSData.init(contentsOfFile: path!)
            
            let i = GIFImageView.init(frame: .zero)
            i.prepareForAnimation(withGIFData: data! as Data)
            return i
        }()
        
        lazy var avartIV: AvatarView = {
            let v = AvatarView.init()
            v.imageV.setImage(UserCenter.shared.theUser?.headImg ?? "")
            return v
        }()
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(loadingIV)
            addSubview(avartIV)
            loadingIV.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize.init(width: frame.size.width-50, height: frame.size.width-50))
                m.centerY.equalToSuperview()
                m.centerX.equalToSuperview()
            }
            avartIV.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.centerX.equalToSuperview()
                m.width.height.equalTo(120)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

extension HWMatchView: HWMatchedViewDelegete{
    
    func matchView(_ view: HWMatchedView, video chat: UIButton, target: NSDictionary) {
        
        let userM = UserModel.init(dataSource: nil)
        userM.userId = view.dataSource!["userId"].int
        userM.nickname =  view.dataSource!["nickname"].string
        userM.headImg = view.dataSource!["imageUrl"].string
        HWAVAuthModel.shared.callVideo(userM)
    }
    
    func matchView(_ view: HWMatchedView, audio chat: UIButton, target: NSDictionary) {
        
        let userM = UserModel.init(dataSource: nil)
        userM.userId = view.dataSource!["userId"].int
        userM.nickname =  view.dataSource!["nickname"].string
        userM.headImg = view.dataSource!["imageUrl"].string
        HWAVAuthModel.shared.callAudio(userM)
    }
    
    func matchView(_ view: HWMatchedView, taped: Int) {
        
        let profileVC = HWProfileViewController.init(NSNumber(value: taped))
        profileVC.hidesBottomBarWhenPushed = true
        self.controller?.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func matchView(_ view: HWMatchedView, heart: UIButton) {
        
    }
    func matchView(_ view: HWMatchedView, chat: UIButton, target: NSDictionary) {
        
        let msgList = WFCUMessageListViewController.init()
        msgList.conversation = WFCCConversation.init(type: .Single_Type, target: String(view.dataSource!["userId"].int!) , line: 0)
        msgList.hidesBottomBarWhenPushed = true
        let userM = WFUseInfo.init()
        userM.userId = String(view.dataSource!["userId"].int!)
        userM.userInfo = [
            "userId": view.dataSource!["userId"] as Any,
            "nickname": view.dataSource!["nickname"].string as Any,
            "headImg":view.dataSource!["imageUrl"] as Any
        ]
        msgList.targetUserInfo = userM
        
        
        self.controller?.navigationController?.pushViewController(msgList, animated: true)
        
//        let root = AppDelegate.window.rootViewController
//        if root is UITabBarController {
//           let rootTab = root as! UITabBarController
//
//            for i in 0..<rootTab.viewControllers!.count  {
//                let con = rootTab.viewControllers![i]
//                if con is WFCUConversationTableViewController {
//                    rootTab.selectedIndex = i
//                }
//            }
//            rootTab.selectedIndex = 2
//        }

    }
}

class HWMatchedView: UIView {
    
    weak var delegate: HWMatchedViewDelegete?
    
    var followed: Bool = false

    var dataSource: JSON?{
        didSet{
            nameL.text = dataSource!["nickname"].string
            profileIv.sd_setImage(with: URL.init(string: dataSource!["imageUrl"].string!), completed: nil)
            genderIv.image = UIImage.init(named: dataSource!["gender"].int == 0 ? "ic_gender_female" : "" )
            ageL.text = String(dataSource!["age"].int!)
            
//            if dataSource!["notFans"].int == 1{
//                followed = true
//                matchBtn.setImage(UIImage.init(named: "ic_heart_liked"), for: .normal)
//            }else{
//                followed = false
//                matchBtn.setImage(UIImage.init(named: "ic_heart_like"), for: .normal)
//            }
            
        }
    }
    
    lazy var messageBtn: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_chat"), for: .normal)
        b.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        return b
    }()
    
    lazy var audioBtn: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_audio"), for: .normal)
        b.addTarget(self, action: #selector(goAudio), for: .touchUpInside)
        return b
    }()
    
    lazy var videoBtn: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_video"), for: .normal)
        b.addTarget(self, action: #selector(goVideo), for: .touchUpInside)
        return b
    }()
    
//    lazy var matchBtn: UIButton = {
//        let b = UIButton.init(type: .custom)
//        b.setImage(UIImage.init(named: "ic_heart_match"), for: .normal)
//        b.addTarget(self, action: #selector(matchHeart), for: .touchUpInside)
//        return b
//    }()
    
    lazy var profileIv: UIImageView = {
        let v = UIImageView.init(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFill
        
        v.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(taped))
        
        v.addGestureRecognizer(tap)
        return v
    }()
    
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return l
    }()
    
    lazy var genderIv: UIImageView = {
        let iv = UIImageView.init()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var ageL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return l
    }()
    
    lazy var commentL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileIv)
        addSubview(messageBtn)
        addSubview(audioBtn)
        addSubview(videoBtn)
        //addSubview(matchBtn)
        addSubview(nameL)
        addSubview(genderIv)
        addSubview(ageL)
        addSubview(commentL)
        
        profileIv.snp.makeConstraints { (m) in
            m.size.equalToSuperview().offset(-20)
            m.center.equalToSuperview()
        }
//        matchBtn.snp.makeConstraints { (m) in
//            m.topMargin.equalTo(40)
//            m.rightMargin.equalTo(-40)
//            m.width.equalTo(68)
//            m.height.equalTo(68)
//        }
        messageBtn.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(-40)
            m.rightMargin.equalTo(-40)
            m.width.equalTo(68)
            m.height.equalTo(68)
        }
        
        audioBtn.snp.makeConstraints { (m) in
            m.width.equalTo(68)
            m.height.equalTo(68)
            m.centerY.equalTo(messageBtn)
            m.right.equalTo(messageBtn.snp.left).offset(-20)
        }
        
        videoBtn.snp.makeConstraints { (m) in
            m.width.equalTo(68)
            m.height.equalTo(68)
            m.centerY.equalTo(messageBtn)
            m.right.equalTo(audioBtn.snp.left).offset(-20)
        }
        
        commentL.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(-30)
            m.leftMargin.equalTo(30)
            m.right.equalTo(messageBtn.snp.left).offset(-20)
        }
        nameL.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(25)
            m.leftMargin.equalTo(30)
        }
        genderIv.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 13, height: 13))
            m.left.equalTo(nameL.snp.right).offset(5)
            m.centerY.equalTo(nameL)
        }
        ageL.snp.makeConstraints { (m) in
            m.left.equalTo(genderIv.snp.right).offset(5)
            m.centerY.equalTo(nameL)
        }
        
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func matchHeart(_ sender: UIButton) -> Void {
        
        if followed {
            sender.setImage(UIImage(named: "ic_heart_like"), for: .normal)
            sender.isEnabled = false
            
            UserCenter.shared.followRemove(followId: (dataSource!["userId"].int!)) { (respond) in
                self.followed = false
                sender.isEnabled = true
                SVProgressHUD.showSuccess(withStatus: DYLOCS("Unfollowed") )
            } fail: { (error) in
                sender.setImage(UIImage(named: "ic_heart_liked"), for: .normal)
                sender.isEnabled = true
                SVProgressHUD.showError(withStatus: error.message)
            }
            
        }else{
            sender.setImage(UIImage(named: "ic_heart_liked"), for: .normal)
            sender.isEnabled = false
            UserCenter.shared.followAdd(followId: (dataSource!["userId"].int!)) { (respond) in
                self.followed = true
                sender.isEnabled = true
                SVProgressHUD.showSuccess(withStatus: DYLOCS("Followed") )
            } fail: { (error) in
                sender.setImage(UIImage(named: "ic_heart_like"), for: .normal)
                sender.isEnabled = true
                SVProgressHUD.showError(withStatus: error.message)
            }
        }
        
        if delegate != nil {
            delegate?.matchView(self, heart: sender)
        }
    }
    
    @objc func goChat(_ sender: UIButton) -> Void {
        if delegate != nil {
            delegate?.matchView(self, chat: sender, target:dataSource!.dictionary! as NSDictionary)
        }
    }
    
    @objc func goVideo(_ sender: UIButton) -> Void {
        if delegate != nil {
            delegate?.matchView(self, video: sender, target:dataSource!.dictionary! as NSDictionary)
        }
    }
    
    @objc func goAudio(_ sender: UIButton) -> Void {
        if delegate != nil {
            delegate?.matchView(self, audio: sender, target:dataSource!.dictionary! as NSDictionary)
        }
    }

    @objc func taped() -> Void {
        if delegate != nil {
            delegate?.matchView(self, taped:dataSource!["userId"].int!)
        }
    }
    
    
}
