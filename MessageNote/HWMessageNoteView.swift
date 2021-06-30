//
//  HWMessageNoteView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/5.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWMessageNoteView: UIView, UIGestureRecognizerDelegate {

    var messageTap: ((HWMessage)-> Void)?
    
    lazy var avatar: HWAvatar = {
        let iv = HWAvatar.init()
        return iv
    }()
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        return l
    }()
    lazy var messageL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 85, 85, 85, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return l
    }()

    lazy var timeL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 136, 136, 136, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return l
    }()
    
    
    var message: HWMessage?{
        didSet{
            avatar.setImage(message?.headImg ?? "")
            nameL.text = message?.nickName
            messageL.text = message?.message
            timeL.text = message?.time
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        layer.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
//        layer.backgroundColor = RANDOMCOLOR().cgColor
//        layer.cornerRadius = 17
//        layer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.5).cgColor
//        layer.shadowOffset = CGSize.init(width: 0, height: 0)
//        layer.shadowOpacity = 0.9;
//        layer.shadowRadius = 10;
        backgroundColor = .white
        layer.cornerRadius = 17
        layer.masksToBounds = true
        
        addSubview(avatar)
        addSubview(nameL)
        addSubview(messageL)
        addSubview(timeL)

        avatar.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(6)
            m.centerY.equalToSuperview()
            m.width.equalTo(55)
            m.height.equalTo(55)
        }
        timeL.snp.makeConstraints { (m) in
            m.topMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
        }
        nameL.snp.makeConstraints { (m) in
            m.top.equalTo(avatar).offset(5)
            m.left.equalTo(avatar.snp.right).offset(10)
        }
        messageL.snp.makeConstraints { (m) in
            m.bottom.equalTo(avatar).offset(-2)
            m.left.equalTo(avatar.snp.right).offset(10)
            m.right.equalToSuperview().offset(-HAWA_SCREEN_HORIZATAL_SPACE)
        }
        
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        tap.delegate = self
        isUserInteractionEnabled  = true
        addGestureRecognizer(tap)


    }
    
    @objc func click() -> Void {
        messageTap?(message!)
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
