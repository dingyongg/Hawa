//
//  HWMessageNoteView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/5.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWChargeFlyView: UIView, UIGestureRecognizerDelegate {

    var messageTap: ((HWMessage)-> Void)?
    
    lazy var avatar: HWAvatar = {
        let iv = HWAvatar.init()
        return iv
    }()
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.text = "niao"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return l
    }()
    lazy var messageL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.text = "sdfdf"
        l.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return l
    }()

    lazy var timeL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 136, 136, 136, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return l
    }()
    
    
    var flyData: JSON?{
        didSet{
            avatar.setImage(flyData!["headImg"].string ?? "")
            nameL.text = flyData!["nickname"].string ?? ""
            messageL.text = "Has recharged $" + (flyData?["payPrice"].string ?? "")
        }
    }

    init(_ data:JSON?) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 52))
        self.setData(data)
        layer.masksToBounds = true
        
        addSubview(avatar)
        addSubview(nameL)
        addSubview(messageL)
        
    
        let gradient = CAGradientLayer()
        gradient.frame = self.frame
        gradient.colors = [THEME_COLOR_RED.cgColor, COLORFROMRGB(r: 253, 53, 117, alpha: 0) .cgColor]
        gradient.startPoint = CGPoint.init(x: 0, y: 0)
        gradient.endPoint = CGPoint.init(x: 1, y: 0)
        gradient.locations = [NSNumber(0), NSNumber(0.9), NSNumber(1)]
        self.layer.insertSublayer(gradient, at: 0)
 
        let path = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft], cornerRadii: CGSize.init(width: 26, height: 26))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        

        avatar.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(3)
            m.centerY.equalToSuperview()
            m.width.equalTo(46)
            m.height.equalTo(46)
        }

        nameL.snp.makeConstraints { (m) in
            m.top.equalTo(avatar).offset(2)
            m.left.equalTo(avatar.snp.right).offset(10)
        }
        
        messageL.snp.makeConstraints { (m) in
            m.bottom.equalTo(avatar).offset(0)
            m.left.equalTo(avatar.snp.right).offset(10)
            m.right.equalToSuperview().offset(-HAWA_SCREEN_HORIZATAL_SPACE)
        }

    }
    
    func setData(_ data: JSON?) -> Void {
        self.flyData = data
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
