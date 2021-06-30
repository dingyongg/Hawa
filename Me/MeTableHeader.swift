//
//  MeTableHeader.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

@objc protocol MeTableHeaderDelegate {
    func didTapedHeader(view:UIView)
    func didTapedAvatar(view:UIView)
    func didTapedDetail(tag:Int)
}

class MeTableHeader: UIView, UIGestureRecognizerDelegate {
    
    weak var delegete: MeTableHeaderDelegate?
    
    lazy var avatarIV: AvatarView = {
        let v = AvatarView.init()
        v.add(self, action: #selector(clickAvatar))
        return v
    }()
    lazy var nameL: UILabel = {
        let l:UILabel = UILabel()
        l.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        l.font = UIFont.boldSystemFont(ofSize: 21)
        return l
    }()
    lazy var idL: UILabel = {
        let l:UILabel = UILabel()
        l.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 13)
        return l
    }()
    
    lazy var memberTimeL: UILabel = {
        let l:UILabel = UILabel()
        l.textColor = THEME_SUB_CONTEN_COLOR
        l.font = UIFont.systemFont(ofSize: 13)
        return l
    }()
    
    lazy var containerV: UIView = {
        let v = UIView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 220))
        v.backgroundColor = .white
        return v
    }()
    
    
    
    let indicatorIC:UIImageView = UIImageView.init(image: UIImage.init(named: "ic_right"))
    lazy var followV: MedetailV  = {
        let v = MedetailV.init(title: DYLOCS("Follow"))
        v.tag = 0
        v.tap = { t in
            self.delegete?.didTapedDetail(tag: t)
        }
        return v
    }()
    lazy var fanV: MedetailV = {
        let v = MedetailV.init(title: DYLOCS("Fans"))
        v.tag = 1
        v.tap = { t in
            self.delegete?.didTapedDetail(tag: t)
        }
        return v
    }()
    lazy var recentVisitV: MedetailV = {
        let v = MedetailV.init(title: DYLOCS("Recent Visit"))
        v.tag = 3
        v.tap = { t in
            self.delegete?.didTapedDetail(tag: t)
        }
        return v
    }()
    
    init() {
       
        super.init(frame:CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 240))
        
        addSubview(containerV)
        containerV.addSubview(avatarIV)
        containerV.addSubview(idL)
        containerV.addSubview(memberTimeL)
        containerV.addSubview(nameL)
        containerV.addSubview(followV)
        containerV.addSubview(fanV)
        containerV.addSubview(recentVisitV)
        
        loadData()
        
        let g = UITapGestureRecognizer.init(target: self, action: #selector(Tap))
        g.delegate = self
        self.addGestureRecognizer(g)
        
        avatarIV.snp.makeConstraints { (m) in
            m.width.height.equalTo(78)
            m.rightMargin.equalTo(-25)
            m.topMargin.equalTo(40)
        }
        nameL.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(25)
            m.centerY.equalTo(avatarIV).offset(-20)
        }
        idL.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(25)
            m.centerY.equalTo(avatarIV).offset(10)
        }
        memberTimeL.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(25)
            m.top.equalTo(idL.snp.bottom).offset(10)
        }
        
        followV.snp.makeConstraints { (m) in
            m.width.equalTo(SCREEN_WIDTH/4)
            m.height.equalTo(50)
            m.bottomMargin.equalTo(-25)
            m.leftMargin.equalTo(self)
        }
        fanV.snp.makeConstraints { (m) in
            m.width.equalTo(SCREEN_WIDTH/4-20)
            m.height.equalTo(50)
            m.bottomMargin.equalTo(-25)
            m.left.equalTo(followV.snp.right)
        }

        recentVisitV.snp.makeConstraints { (m) in
            m.width.equalTo(SCREEN_WIDTH/4)
            m.height.equalTo(50)
            m.bottomMargin.equalTo(-25)
            m.left.equalTo(fanV.snp.right)
        }
        
        containerV.layer.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        containerV.layer.cornerRadius = 17
        containerV.layer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.1).cgColor
        containerV.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        containerV.layer.shadowOpacity = 0.9;
        containerV.layer.shadowRadius = 10;
        
        
        let maskV = UIView.init(frame: CGRect.init(x: 0, y: -20, width: SCREEN_WIDTH, height: 40))
        maskV.backgroundColor = .white
        addSubview(maskV)
        
        //        let shapeLayer:CAShapeLayer = CAShapeLayer()
        //                shapeLayer.path = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: containerV.frame.width, height: containerV.frame.height), byRoundingCorners: UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadii: CGSize(width: 10, height: 10)).cgPath
        //
        //        //为view指定图层
        //        containerV.layer.mask = shapeLayer
        //        shapeLayer.cornerRadius = 17
        //        shapeLayer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.1).cgColor
        //        shapeLayer.shadowOffset = CGSize.init(width: 3, height: 3)
        //        shapeLayer.shadowOpacity = 0.9;
        //        shapeLayer.shadowRadius = 10;

    }
    
    
    func loadData() -> Void {
        
        let userModel = UserCenter.shared.theUser
        
        if UserCenter.shared.isLogin() == true {
            nameL.text = userModel?.nickname ?? "- -"
        }else{
            nameL.text = DYLOCS("Click to login")
        }
        
        avatarIV.imageV.sd_setImage(with: URL.init(string: userModel?.headImg ?? ""), for: .normal) { (i, e, t, u) in
            userModel?.headImage = i
        }
        avatarIV.isVip = userModel?.vipType ?? 0 > 0 ? true : false
        idL.text = (userModel?.account) ?? "--"
        if userModel?.vipType ?? 0 > 0 {
            let sub = userModel?.vipEndTime?.components(separatedBy: " ").first
            memberTimeL.text =  DYLOCS("Membership Expiration") + ": " + (sub ?? "")
        }
        followV.value = String(userModel?.followCount ?? 0)
        fanV.value = String(userModel?.fansCount ?? 0)
        recentVisitV.value = String(userModel?.visitorRecordCount ?? 0)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func Tap() -> Void {
        delegete?.didTapedHeader(view: self)
    }
    
    @objc func clickAvatar() -> Void {
        delegete?.didTapedAvatar(view: self)
    }

}


class MedetailV: UIView, UIGestureRecognizerDelegate {
    
    lazy var valueL: UILabel = {
        let l:UILabel = UILabel.init()
        l.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 17)
        return l
    }()
    lazy var titleL: UILabel = {
        let l:UILabel = UILabel.init()
        l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 15)
        return l
    }()
    
    var value: String?{
        didSet{
            valueL.text = value
        }
    }
    
    init(title:String) {
        super.init(frame: .zero)
        titleL.text = title
        self.addSubview(valueL)
        self.addSubview(titleL)
        
        valueL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(self.snp.top)
        }
        titleL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(valueL.snp.bottom).offset(12)
        }
        
        let g = UITapGestureRecognizer.init(target: self, action: #selector(Tap))
        g.delegate = self
        self.addGestureRecognizer(g)
        
    }
    
    var tap:((Int)->Void)?
    
    @objc func Tap() -> Void {
        tap!(self.tag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AvatarView: UIView {
    
    var image: UIImage? {
        didSet {
            imageV.setImage(image, for: .normal)
        }
    }
    
    lazy var imageV : HWAvatar = HWAvatar.init(frame: .zero)
    var isVip: Bool? {
        didSet{
            
            if isVip! {
                layer.borderColor = COLORFROMRGB(r: 237, 195, 114, alpha: 1).cgColor
                addSubview(vipIC)
                vipIC.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.bottom.equalTo(imageV.snp.top).offset(3)
                    m.size.equalTo(CGSize.init(width: 25, height: 25))
                }
            }else{
                layer.borderColor = THEME_COLOR_RED.cgColor
                vipIC.removeFromSuperview()
                vipIC.snp.removeConstraints()
            }
           
        }
    }
    
    lazy var vipIC: UIImageView = {
        let i = UIImageView.init(image: UIImage.init(named: "ic_vip_cap"))
        i.contentMode  = .scaleAspectFit
        return i
    }()
    
    init() {
        super.init(frame: .zero)
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = THEME_COLOR_RED.cgColor
        addSubview(imageV)
        clipsToBounds = false
        imageV.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.width.equalTo(self.snp.width).offset(-6)
            m.height.equalTo(self.snp.width).offset(-6)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(_ target: Any?, action:Selector) -> Void {
        imageV.addTarget(target, action: action, for: .touchUpInside)
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = rect.height/2
    }
}
