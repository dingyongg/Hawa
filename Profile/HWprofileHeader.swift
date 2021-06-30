//
//  HWprofileHeader.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/7.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWprofileHeader: UIView {
    
    var followed:Bool = false{
        didSet{
            if followed {
                let i = UIImage.init(named: "ic_followed_white")
                let tempalteI = i?.withRenderingMode(.alwaysTemplate)
                followB.setImage(tempalteI, for: .normal)
            }else{
                let i = UIImage.init(named: "ic_follow_white")
                let tempalteI = i?.withRenderingMode(.alwaysTemplate)
                followB.setImage(tempalteI, for: .normal)
            }
        }
    }
    
    lazy var userModel: UserModel? = nil{
        
        didSet{
            
            name.text = userModel?.nickname
            gender.image = UIImage.init(named:userModel?.gender == 1 ? "ic_gender_male_select" : "ic_gender_female")
            id.text = "ID " + (userModel?.account)!
            status.lineState = userModel?.onlineState == 0 ?.onLine:.offLine
            fansNum.text = String(userModel!.fansCount!)
            
            comment.text = userModel?.profile
            if (comment.text != nil) {
                let nss = comment.text! as NSString
                
                let size = CGSize.init(width: SCREEN_WIDTH-HAWA_SCREEN_HORIZATAL_SPACE-HAWA_SCREEN_HORIZATAL_SPACE, height: 999)
                let arrs: [NSAttributedString.Key:Any] = [
                    NSAttributedString.Key.font:comment.font as Any
                ]
                
                let rect = nss.boundingRect(with:size, options: .usesLineFragmentOrigin, attributes: arrs, context: nil)
                self.height = self.height + rect.size.height + 5
            }
            
            
            if userModel?.userId != UserCenter.shared.userId {
                addSubview(followB)
                followB.snp.makeConstraints { (m) in
                    m.size.equalTo(CGSize.init(width: 30, height: 30))
                    m.topMargin.equalTo(30)
                    m.rightMargin.equalTo(-30)
                }
                if userModel?.notFans == 1 {
                    followed = true
                }else{
                    followed = false
                }
            }
        }
    }
    
    lazy var name: UILabel = {
        let name = UILabel.init(frame: .zero)
        name.textColor = THEME_TITLE_DARK_COLOR
        name.font = UIFont.systemFont(ofSize: 21)
        return name
    }()
    
    lazy var id: UILabel = {
        let id = UILabel.init(frame: .zero)
        id.textColor = THEME_TITLE_DARK_COLOR
        id.font = UIFont.systemFont(ofSize: 13)
        return id
    }()
    lazy var fansNum: UILabel = {
        let fansNum = UILabel.init(frame: .zero)
        fansNum.textColor = THEME_TITLE_DARK_COLOR
        fansNum.font = UIFont.systemFont(ofSize: 16)
        return fansNum
    }()
    lazy var fans: UILabel = {
        let fans = UILabel.init(frame: .zero)
        fans.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        fans.font = UIFont.systemFont(ofSize: 16)
        fans.text = DYLOCS("Fans")
        return fans
    }()
    lazy var comment: UILabel = {
        let comment = UILabel.init(frame: .zero)
        comment.textColor = THEME_CONTENT_DARK_COLOR
        comment.font = UIFont.systemFont(ofSize: 14)
        comment.numberOfLines = 0
        return comment
    }()
    lazy var gender: UIImageView = {
        let gender = UIImageView.init(frame: .zero)
        gender.contentMode = .scaleAspectFit
        return gender
    }()
    lazy var status: HWHomeCollectionCellStateLabel = {
        let status = HWHomeCollectionCellStateLabel.init(.onLine)
        status.backgroundColor = COLORFROMRGB(r: 126, 255, 98, alpha: 1)
        return status
    }()
    lazy var followB: UIButton = {
        let followB = UIButton.init(frame: .zero)
        followB.addTarget(self, action: #selector(followA), for: .touchUpInside)
        followB.tintColor = THEME_COLOR_RED
        return followB
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(name)
        addSubview(id)
        addSubview(fansNum)
        addSubview(fans)
        addSubview(comment)
        addSubview(gender)
        addSubview(status)
        
        
        name.snp.makeConstraints { (m) in
            m.topMargin.equalTo(15)
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
        }
        gender.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 13, height: 13))
            m.centerY.equalTo(name)
            m.left.equalTo(name.snp.right).offset(5)
        }
        status.snp.makeConstraints { (m) in
            m.height.equalTo(15)
            m.centerY.equalTo(name)
            m.left.equalTo(gender.snp.right).offset(5)
        }
        
        id.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.top.equalTo(name.snp.bottom).offset(8)
        }
        fansNum.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.top.equalTo(id.snp.bottom).offset(8)
        }
        fans.snp.makeConstraints { (m) in
            m.centerY.equalTo(fansNum)
            m.left.equalTo(fansNum.snp.right).offset(5)
        }
        comment.snp.makeConstraints { (m) in
            m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
            m.top.equalTo(fans.snp.bottom).offset(10)
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
        }

        
    }
    
    @objc func followA(_ sender: UIButton) -> Void{
        
        if self.userModel != nil {
            if followed {
                followed = false
                sender.isEnabled = false
                UserCenter.shared.followRemove(followId: (userModel?.userId)!) { (respond) in
                    sender.isEnabled = true
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showSuccess(withStatus: DYLOCS("Unfollowed") )
                } fail: { (error) in
                    self.followed = true
                    sender.isEnabled = true
                    SVProgressHUD.showError(withStatus: error.message)
                }
                
            }else{
                followed = true
                sender.isEnabled = false
                UserCenter.shared.followAdd(followId: (userModel?.userId)!) { (respond) in
                    sender.isEnabled = true
                    SVProgressHUD.showSuccess(withStatus: DYLOCS("Followed") )
                } fail: { (error) in
                    self.followed = false
                    sender.isEnabled = true
                    SVProgressHUD.showError(withStatus: error.message)
                }
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
