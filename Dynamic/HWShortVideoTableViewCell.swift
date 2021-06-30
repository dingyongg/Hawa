//
//  HWShortVideoTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/16.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import SJVideoPlayer


class HWShortVideoTableViewCell: UITableViewCell {

    var avartarClick: ((Int)->Void)?
    var chatClick: ((JSON)->Void)?
    var videoClick: ((UserModel)->Void)?
    var audioClick: ((UserModel)->Void)?
    
    var likeBtn:UIButton?
    var dataSource: JSON? {
        didSet{
            mainImageV.sd_setImage(with: URL.init(string: dataSource!["videoShotImg"].string!), completed: nil)
            avatarImageV.setImage(dataSource!["headUrlSrc"].string!)
            nameL.text = dataSource!["nickname"].string!
            sexIV.image = UIImage(named: dataSource!["sex"].int == 0 ?  "ic_gender_female" : "")
            ageL.text = String((dataSource!["age"].int)!)
            stateL.text = dataSource!["signature"].string
            
        }
    }
    
    lazy var mainImageV: UIImageView = {
        let v = UIImageView.init(frame: CGRect.init(x: 5, y:0 , width: SCREEN_WIDTH - 10, height: SCREEN_HEIGHT-HAWA_NAVI_HEIGHT-HAWA_BOTTOM_TAB_HEIGHT - 5 ))
        //let v = UIImageView.init(frame: .zero)
        v.layer.cornerRadius = 18
        v.layer.masksToBounds = true
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var avatarImageV: HWAvatar = {
        let v = HWAvatar.init(frame: CGRect.init(x: 25, y: 20, width: 64, height: 64))
        v.addTarget(self, action: #selector(avatarClick), for: .touchUpInside)
        return v
    }()
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 18)
        return l
    }()
    lazy var ageL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17)
        return l
    }()
    lazy var sexIV: UIImageView = {
        let l = UIImageView.init(frame: .zero)
        l.contentMode = .scaleAspectFit
        return l
    }()
    lazy var stateL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 14, weight: .thin)
        l.numberOfLines = 0
        l.textAlignment = .natural
        return l
    }()
    
//    lazy var playBtn: UIButton = {
//        let b = UIButton.init(type: .custom)
//        b.setImage(UIImage.init(named: "ic_video_play"), for: .normal)
//        b.addTarget(self, action: #selector(playBtnAction), for: .touchUpInside)
//        return b
//    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let imagesName = ["ic_chat","ic_audio", "ic_video"]
        contentView.addSubview(mainImageV)
        contentView.addSubview(avatarImageV)
        contentView.addSubview(nameL)
        contentView.addSubview(sexIV)
        contentView.addSubview(ageL)
        contentView.addSubview(stateL)
        //contentView.addSubview(playBtn)
        
        self.layoutMargins = UIEdgeInsets.zero
        let btnW = 52
        let space = 20
        for i in 0..<imagesName.count {
            let btn = UIButton.init(frame:.zero)
            btn.setImage(UIImage(named: imagesName[i]), for: .normal)
            btn.addTarget(self, action: #selector(actions), for: .touchUpInside)
            btn.tag = i
            contentView.addSubview(btn)
            btn.snp.makeConstraints { (m) in
                m.bottomMargin.equalTo(-10)
                m.size.equalTo(CGSize.init(width: btnW, height: btnW))
                m.rightMargin.equalTo(-(btnW+space)*i - 30)
            }
            if i == 0 {
                likeBtn = btn
            }
        }
        self.contentView.layoutMargins = .zero
//        self.contentView.preservesSuperviewLayoutMargins = true
//        self.preservesSuperviewLayoutMargins = true
        selectionStyle = .none
//        mainImageV.snp.makeConstraints { (m) in
//            m.topMargin.equalTo(0)
//            m.rightMargin.equalTo(-5)
//            m.bottomMargin.equalTo(-5)
//            m.leftMargin.equalTo(5)
//        }
        nameL.snp.makeConstraints { (m) in
            m.left.equalTo(avatarImageV.snp.right).offset(5)
            m.top.equalTo(avatarImageV)
        }
        sexIV.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 13, height: 13))
            m.left.equalTo(nameL.snp.right).offset(15)
            m.centerY.equalTo(nameL)
        }
        ageL.snp.makeConstraints { (m) in
            m.centerY.equalTo(nameL)
            m.left.equalTo(sexIV.snp.right).offset(5)
        }
        stateL.snp.makeConstraints { (m) in
            m.left.equalTo(nameL)
            m.top.equalTo(nameL.snp.bottom)
            m.size.equalTo(CGSize.init(width: SCREEN_WIDTH - 150, height: 40))
        }
//        playBtn.snp.makeConstraints { (m) in
//            m.centerY.equalToSuperview()
//            m.centerX.equalToSuperview()
//            m.width.equalTo(45)
//            m.height.equalTo(45)
//        }
        
        
        // 视频播放父视图
        let videoSuper = HWShortVideoSupreView.init(frame: CGRect.init(x: 5, y:0 , width: SCREEN_WIDTH - 10, height: SCREEN_HEIGHT-HAWA_NAVI_HEIGHT-HAWA_BOTTOM_TAB_HEIGHT - 5 ))
        videoSuper.backgroundColor = .black
        contentView.insertSubview(videoSuper, aboveSubview: mainImageV)
        
    }
    
    
    @objc func actions(_ sender: UIButton) -> Void{
        if sender.tag == 0 { // 点赞
            
            chatClick?(self.dataSource!)

        }else if sender.tag == 1 { //语音
            if dataSource != nil {
                
                let userM = UserModel.init(dataSource: nil)
                userM.userId = dataSource?["userId"].int
                userM.nickname = dataSource?["nickname"].string
                userM.headImg = dataSource?["headUrlSrc"].string
                audioClick?(userM)
            }
            
        }else if sender.tag == 2{ // 视频
            
            if dataSource != nil {
                let userM = UserModel.init(dataSource: nil)
                userM.userId = dataSource?["userId"].int
                userM.nickname = dataSource?["nickname"].string
                userM.headImg = dataSource?["headUrlSrc"].string
                videoClick?(userM)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func playBtnAction(_ sender: UIButton) -> Void {
        
    }
    
    @objc func avatarClick(_ sender: UIButton) -> Void {
        avartarClick?(dataSource!["userId"].int!)
    }
    
}


class HWShortVideoSupreView: UIView, SJPlayModelPlayerSuperview{
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 18
        layer.masksToBounds = true
        clipsToBounds = true
        
    }
}

