//
//  HWGiftView.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/21.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWGiftView: UIView,  HWGiftContinerViewDelegate{
    func giftsContiner(_ view: HWGiftContinerView, didSelect gift: GiftItem, balence: Float) {
        self.dismiss()
        if balence >= gift.present!["silverNumber"].float! {
            
            UserCenter.shared.giftBuy(gift.present!["id"].int!, receiverId: self.receiverId!.intValue ) { (res) in
                
            } fail: { (error) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showError(withStatus: error.message)
            }
            
        }else{
            if HWDiamondModel.shared.products != nil {
                VipChargeView.init(HWDiamondModel.shared.products!).present()
            }else{
                HWDiamondModel.shared.loadProduct()
            }
        }
        
    }
    
    
    @objc static let shared:HWGiftView = HWGiftView.init()
    @objc var receiverId:NSNumber?

    lazy var giftsContiner: HWGiftContinerView = {
        let v = HWGiftContinerView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2))
        v.y = SCREEN_HEIGHT
        v.delegate = self
        return v
    }()
    
    lazy var blankArea: UIButton = {
        let b = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2))
        b.addTarget(self, action: #selector(blankTap), for: .touchUpInside)
        return b
    }()
    
    
    var actionsBlock: ((_ index:Int, _ title: String)->Void)?
    var cancelBlock: (()->Void)?
    
    init() {
        super.init(frame: SCREEN_BOUNDS)
        backgroundColor = .clear
        addSubview(blankArea)
    }
    
    @objc func present() -> Void {
        UIView.window().addSubview(self)
        UIView.animate(withDuration: 0.4) {
            self.giftsContiner.y = SCREEN_HEIGHT - self.giftsContiner.height
            self.backgroundColor = THEME_COVER_COLOR
        }
    }
    
    func dismiss() -> Void {
        UIView.animate(withDuration: 0.4) {
            self.giftsContiner.y = SCREEN_HEIGHT
            self.backgroundColor = .clear
        } completion: { (complete) in
            self.giftsContiner.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        if self.superview != nil {
            addSubview(self.giftsContiner)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func blankTap(_ sender: UIButton) -> Void {
        self.dismiss()
    }
    
}


@objc protocol HWGiftContinerViewDelegate {
    func giftsContiner(_ view:HWGiftContinerView, didSelect gift: GiftItem, balence:Float) -> Void
}

class HWGiftContinerView: UIView{
    
    weak var delegate: HWGiftContinerViewDelegate?
    var balence:Float = 0{
        didSet{
            self.balenceL.text = String(balence)
        }
    }
    
    var selectedGift: GiftItem?{
        didSet{
            if selectedGift != nil {
                sendBtn.backgroundColor = THEME_COLOR_RED
                sendBtn.isEnabled = true
            }else{
                sendBtn.backgroundColor = .lightGray
                sendBtn.isEnabled = false
            }
        }
    }
    
    var gifts:[JSON?] = []{
        didSet{
            
            for i  in self.contentScrollView.subviews {
                if i is GiftItem {
                    i.removeFromSuperview()
                }
            }
            
            let space:CGFloat = 8.0
            let h:CGFloat = 135.0
            for i in 0..<gifts.count {
                let s = gifts[i]
                let w = (SCREEN_WIDTH - 40)/4
              
                
                let div: Float  = Float(i / 4)
                let row = floorf(div)
                let colum:CGFloat = CGFloat(i%4)
                let g = GiftItem.init(frame: CGRect.init(x: colum*(w+space) + space , y: CGFloat(row) * (h+space) + space, width: w, height: h))
                g.present = s
                g.selectedBlock = { selec in
                    self.selectedGift = selec
                    
                    for i  in self.contentScrollView.subviews {
                        if i is GiftItem {
                            let subi = i as! GiftItem
                            if subi == selec {
                                subi.isSelected = true
                            }else{
                                subi.isSelected = false
                            }
                        }
                    }
                }
                contentScrollView.addSubview(g)
            }
            
            
            let row = ceil(Double(gifts.count) / 4.0)
            let th = (space+h) * CGFloat(row)
            contentScrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: th + 10)
        }
    }
    
    
    
    lazy var contentScrollView: UIScrollView = {
        let v = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: self.height-50-SCREEN_SAFE_SPACE))
        v.showsVerticalScrollIndicator = true
        return v
    }()
    
    lazy var balenceL: UILabel = {
        let l = UILabel()
        l.textColor = THEME_DARK_BG_COLOR
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return l
    }()
    
    lazy var diamondIcon: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "ic_task_diamond"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    @objc func sendAction(_ sender: UIButton) -> Void {
        
        self.delegate?.giftsContiner(self, didSelect: self.selectedGift!, balence: self.balence)

    }
    
    lazy var sendBtn: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .lightGray
        b.setTitle(DYLOCS("Send"), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        b.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        b.layer.cornerRadius = 17
        b.layer.masksToBounds = true
        b.isEnabled = false
        return b
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        UserCenter.shared.giftList { (res) in
            SVProgressHUD.dismiss()
            self.gifts = res["giftConfigList"].array!
            self.balence = res["number"].float!
            
        } fail: { (error) in
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showError(withStatus: error.message)
        }
        
        backgroundColor = .white
        addSubview(contentScrollView)
        
        let bar = UIView.init()
        bar.backgroundColor = .white
        addSubview(bar)
        
        bar.layer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.3).cgColor
        bar.layer.shadowOffset = CGSize.init(width: 0, height: -5)
        bar.layer.shadowOpacity = 0.3;
        
        bar.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(0)
            m.centerX.equalToSuperview()
            m.width.equalTo(SCREEN_WIDTH)
            m.height.equalTo(50)
        }
        
        bar.addSubview(diamondIcon)
        bar.addSubview(balenceL)
        bar.addSubview(sendBtn)
        
        diamondIcon.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.centerY.equalToSuperview()
            m.width.equalTo(16)
            m.height.equalTo(16)
        }
        
        balenceL.snp.makeConstraints { (m) in
            m.left.equalTo(diamondIcon.snp.right).offset(5)
            m.centerY.equalTo(diamondIcon)
        }
        
        sendBtn.snp.makeConstraints { (m) in
            m.rightMargin.equalTo(-20)
            m.centerY.equalToSuperview()
            m.width.equalTo(70)
            m.height.equalTo(34)
        }
        
        
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        for i  in self.contentScrollView.subviews {
            if i is GiftItem {
                let subi = i as! GiftItem
                subi.isSelected = false
            }
        }
        
        sendBtn.backgroundColor = .lightGray
        sendBtn.isEnabled = false
        
    }
    
    override func didMoveToSuperview() {
        
        if self.superview != nil {
            if self.gifts.count>0 {
                UserCenter.shared.giftList { (res) in
                    self.gifts = res["giftConfigList"].array!
                    self.balence = res["number"].float!
                } fail: { (error) in
                    SVProgressHUD.setDefaultMaskType(.clear)
                    SVProgressHUD.showError(withStatus: error.message)
                    
                }
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


class GiftItem: UIView{
    
    var isSelected: Bool = false{
        didSet{
            if isSelected {
                layer.cornerRadius = 5
                layer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.3).cgColor
                layer.shadowOffset = CGSize.init(width: 1, height: 1)
                layer.shadowOpacity = 0.9;
                layer.shadowRadius = 5;
                self.superview?.bringSubviewToFront(self)
            }else{
                layer.shadowColor = UIColor.clear.cgColor
                layer.cornerRadius = 0
                layer.shadowColor = nil
                layer.shadowOffset = CGSize.zero
                layer.shadowOpacity = 01;
                layer.shadowRadius = 0;
            }
        }
    }
    
    var selectedBlock: ((GiftItem)-> Void)?
    
    lazy var presentIv: UIImageView = {
        let iv = UIImageView.init(frame: .zero)
        return iv
    }()
    
    lazy var title: UILabel = {
        let l = UILabel()
        l.textColor = THEME_DARK_BG_COLOR
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return l
    }()
    
    lazy var diamondIcon: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "ic_task_diamond"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var priceL: UILabel = {
        let l = UILabel.init()
        l.textColor = THEME_CONTENT_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 11)
        return l
    }()
    
    lazy var present: JSON? = [] {
        didSet{
            presentIv.sd_setImage(with: URL.init(string: present!["imageUrl"].string!), completed: nil)
            title.text = present!["name"].string
            priceL.text = String(present!["silverNumber"].int!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        addSubview(presentIv)
        addSubview(title)
        addSubview(diamondIcon)
        addSubview(priceL)
        
        presentIv.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: frame.width-20, height: frame.width-20))
            m.top.equalToSuperview()
            m.centerX.equalToSuperview()
        }
        
        title.snp.makeConstraints { (m) in
            m.top.equalTo(presentIv.snp.bottom).offset(5)
            m.centerX.equalToSuperview()
        }
        
        priceL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview().offset(5)
            m.top.equalTo(title.snp.bottom).offset(5)
        }
        
        diamondIcon.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 15, height: 15))
            m.centerY.equalTo(priceL)
            m.right.equalTo(priceL.snp.left).offset(-3)
        }
        
        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(taped))
        addGestureRecognizer(tap)
        
        
    }
    @objc func taped(sender: UIView) -> Void {
        if isSelected {
            return
        }
        selectedBlock?(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
