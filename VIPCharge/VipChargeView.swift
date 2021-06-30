//
//  VipChargeView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/18.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import KJBannerView
import SwiftyJSON

enum HWProductType {
    case vip
    case diamond
}

let right: [String] = [
    "Chat unlimitedly with all your crushes",
    "Recommend more high-quality and enthusiastic girls for you",
    "Let more beauties discover you",
    "Unlock voice and video call",
    "Find the right girl for you"
]

@objc protocol HWProductItemDelegate {
    func productItem(_ item: HWProductItem, selecteProduct: HWProduct) -> Void
}

class VipChargeView: UIView{
    
    var productItems: [HWProductItem?] = []
    var selected: HWProduct?
    var didCancelBlock:(()->Void)?
    
    func present() -> Void {
        
        let rootVC = UIApplication.shared.delegate as! AppDelegate
        rootVC.window?.addSubview(self)
        
        UIView.animate(withDuration: 0.4) {
            self.backgroundColor = THEME_COVER_COLOR
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.vipBoardContainer.center = self.center
        } completion: { (complete) in
            
        }
    }
    
    @objc func dismiss() -> Void {
        
        UIView.animate(withDuration: 0.6) {
            self.backgroundColor = .clear
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.vipBoardContainer.center = CGPoint.init(x: self.center.x, y: SCREEN_HEIGHT+self.vipBoardContainer.frame.size.height/2)
        } completion: { (complete) in
            self.didCancelBlock?()
            self.waveV?.stopWaveAnimate()
            self.removeFromSuperview()
            SVProgressHUD.dismiss()
        }
    }
    

    let colors: [UIColor] = [
        THEME_COLOR_RED,
        COLORFROMRGB(r: 246, 208, 71, alpha: 1),
        COLORFROMRGB(r: 87, 58, 245, alpha: 1),
        COLORFROMRGB(r: 124, 186, 255, alpha: 1),
        COLORFROMRGB(r: 129, 234, 191, alpha: 1),
        COLORFROMRGB(r: 237, 114, 186, alpha: 1),
        COLORFROMRGB(r: 235, 85, 132, alpha: 1),
        COLORFROMRGB(r: 213, 110, 247, alpha: 1)
    ]
    
    var waveV: GLWaveView?
    
    lazy var vipBoardContainer: UIView = {
        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH-30, height: 520))
        v.center = CGPoint.init(x: center.x, y: SCREEN_HEIGHT+v.frame.size.height/2)
        v.backgroundColor = THEME_COLOR_RED
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        
        let c = CAGradientLayer.init()
        c.frame = CGRect.init(x: 0, y: v.height/2, width: v.width, height: v.height/2)
        c.colors = [COLORFROMRGB(r: 255, 255, 255, alpha: 0).cgColor, UIColor.white.cgColor]
        c.startPoint = CGPoint.init(x: 0, y: 0)
        c.endPoint = CGPoint.init(x: 0, y: 1)
        v.layer.addSublayer(c)
        waveV = GLWaveView.init(frame: v.bounds)
        v.addSubview(waveV!)
        let waveA = GLWave.default()
        waveA!.offsetX = 0;
        waveA!.offsetY = 240;
        waveA!.height  = 13;
        waveA!.width   = SCREEN_WIDTH;
        waveA!.speedX  = 1;
        waveA!.fillColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.55).cgColor
        
        let waveB = GLWave.default()
        waveB!.offsetX = 0;
        waveB!.offsetY = 240;
        waveB!.height  = 13;
        waveB!.width   = SCREEN_WIDTH;
        waveB!.speedX  = 3;
        waveB!.fillColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.35).cgColor
        waveV!.addWave(waveA)
        waveV!.addWave(waveB)
        waveV!.startWaveAnimate()
        
        return v
    }()
    
    
    lazy var bannerV: KJBannerView = {
        let v = KJBannerView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 220))
        v.autoScrollTimeInterval = 3
        v.pageControl.pageType = KJPageControlStyle(rawValue: 1)
        v.itemWidth = SCREEN_WIDTH - 30
        v.itemSpace = 0
        v.delegate = self
        v.dataSource = self
        //v.autoScroll = false
        return v
    }()
    
    init(_ products: [HWProduct]) {

        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        addSubview(vipBoardContainer)
        vipBoardContainer.addSubview(bannerV)
        bannerV.imageDatas = [ "logo_vip_1", "logo_vip_2", "logo_vip_3","logo_vip_4","logo_vip_5"]
        
        let productsCon = UIScrollView.init(frame: CGRect.init(x: 0, y: 280, width: vipBoardContainer.width, height: 120))
        productsCon.clipsToBounds = false
        productsCon.showsHorizontalScrollIndicator = false
        productsCon.showsVerticalScrollIndicator = false
        let space: CGFloat = 10
        let width: CGFloat = (vipBoardContainer.width - 4*space)/3
        for i in 0..<products.count {
            
            let product = products[i]
            var proItm: HWProductItem?

            if product is HWDiamendProduct {
                proItm =  HWDiamendProductItem.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 120), pdct: product)
            }else{
                proItm =  HWVipProductItem.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 120), pdct: product)
            }
            if i == products.count-1 {
                proItm?.isHot = true
            }
            proItm!.origin = CGPoint.init(x:i * Int((proItm!.width+space)) + Int(space) , y: 0)
            proItm?.delegate = self
            productsCon.addSubview(proItm!)
            productItems.append(proItm!)
            let width: CGFloat =  CGFloat(products.count) * proItm!.width + CGFloat(products.count-1) * space
            productsCon.contentSize = CGSize.init(width: width, height: proItm!.height)
        }
        
        let last = productItems.last!!
        last.isSelected = true
        self.selected = last.product!
        
        vipBoardContainer.addSubview(productsCon)
        
        let continueBtn = HawaBaseButton.init(frame: .zero, title: DYLOCS("CONTINUE"), image: nil, targte: self, action: #selector(confirm))
        continueBtn.backgroundColor = THEME_COLOR_RED
        
        let cancelBtn = UIButton.init(frame: .zero)
        cancelBtn.setTitle(DYLOCS("please wait"), for: .normal)
        cancelBtn.setTitleColor(COLORFROMRGB(r: 153, 153, 153, alpha: 1), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        vipBoardContainer.addSubview(cancelBtn)
        vipBoardContainer.addSubview(continueBtn)


        continueBtn.snp.makeConstraints { (m) in
            m.height.equalTo(45)
            m.rightMargin.equalTo(-15)
            m.leftMargin.equalTo(15)
            m.bottom.equalTo(cancelBtn.snp.top).offset(-5)
        }
        
        cancelBtn.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-10)
            m.centerX.equalToSuperview()
        }
        
        
        
    }
    
    @objc func confirm(sender: HawaBaseButton) -> Void {
      
        if (self.selected != nil) {
            
            let t: Int = self.selected! is HWVIPProduct ? 1 : 3
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
            UserCenter.shared.creatPaymentOrder(id: (self.selected?.id)!, type:t) { (respond) in
                HWInPurchase.shared.purchase(self.selected!, orderId: respond["orderNumber"].string!) { (p) in
                    SVProgressHUD.showSuccess(withStatus: "Transaction completed")
                    UserCenter.shared.refreshUserInfo()
                } fail: { (e) in
                    SVProgressHUD.setDefaultMaskType(.clear)
                    SVProgressHUD.showError(withStatus: e.message)
                }
            } fail: { (error) in
                SVProgressHUD.setDefaultMaskType(.clear)
                SVProgressHUD.showError(withStatus: error.message)
            }

        }else{
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showError(withStatus: DYLOCS("Select Product") )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class VipRightView : UIView {
        
        lazy var rightTitle: UILabel = {
            let l = UILabel()
            l.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            l.textColor = .white
            return l
        }()
        
        lazy var rightState: UILabel = {
            let l = UILabel()
            l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            l.textColor = .white
            l.numberOfLines = 0
            l.textAlignment = .center
            return l
        }()
        lazy var rightLogo: UIImageView = {
            let i = UIImageView.init(frame: .zero)
            return i
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(rightTitle)
            addSubview(rightLogo)
            addSubview(rightState)
            
            rightTitle.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalToSuperview().offset(20)
            }
            
            rightLogo.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(rightTitle.snp.bottom).offset(10)
                m.size.equalTo(CGSize.init(width: 82, height: 82))
            }
            rightState.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(rightLogo.snp.bottom).offset(10)
                m.rightMargin.equalTo(-15)
                m.leftMargin.equalTo(15)
            }
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


extension VipChargeView: KJBannerViewDelegate, KJBannerViewDataSource{
    func kj_BannerView(_ banner: KJBannerView!, bannerViewCell bannercell: KJBannerViewCell!, imageDatas: [Any]!, index: Int) -> UIView! {
        let vv = VipRightView.init(frame: banner.bounds)
        vv.rightLogo.image = UIImage.init(named: imageDatas[index] as! String  )
        vv.rightTitle.text =  self.selected! is HWVIPProduct ? DYLOCS("Membership") : DYLOCS("Diamond")
        vv.rightState.text = right[index]
        return vv
    }
    
    func kj_BannerView(_ banner: KJBannerView!, select index: Int) {
        
    }
    
    func kj_BannerView(_ banner: KJBannerView!, currentIndex index: Int) -> Bool {
        UIView.animate(withDuration: 1) {
            self.vipBoardContainer.backgroundColor = self.colors[index]
        }
        
        return false
    }
}

extension VipChargeView: HWProductItemDelegate{
    
    func productItem(_ item: HWProductItem, selecteProduct: HWProduct) {
        selected = selecteProduct
        for i in productItems {
            if i != item {
                i!.isSelected = false
           }
        }
    }
}



class HWProductItem: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: HWProductItemDelegate?
    
    var product: HWProduct?
    var isHot:Bool = false{
        didSet{
            if isHot {
                addSubview(hotIV)
                hotIV.snp.makeConstraints { (m) in
                    m.topMargin.equalTo(-15)
                    m.centerX.equalToSuperview()
                    m.width.equalTo(30)
                    m.height.equalTo(30)
                }
                
            }
        }
    }
    
    var isSelected: Bool! = false {
        didSet{
            if isSelected {
                container.layer.borderColor = THEME_COLOR_RED.cgColor
                totolPriceL.backgroundColor = THEME_COLOR_RED
                totolPriceL.textColor = .white
                totolPriceL.layer.borderWidth = 0
            }else{
                container.layer.borderColor = COLORFROMRGB(r: 219, 219, 219, alpha: 1).cgColor
                totolPriceL.backgroundColor = .clear
                totolPriceL.textColor = COLORFROMRGB(r: 102, 102, 101, alpha: 1)
                totolPriceL.layer.borderWidth = 1
            }
        }
    }
    
    lazy var totolPriceL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l.textColor = COLORFROMRGB(r: 102, 102, 101, alpha: 1)
        l.layer.borderWidth = 1
        l.layer.borderColor = COLORFROMRGB(r: 219, 219, 219, alpha: 1).cgColor
        l.textAlignment = .center
        return l
    }()
    
    lazy var numberL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        l.textColor = COLORFROMRGB(r: 102, 102, 101, alpha: 1)
        return l
    }()
    lazy var unitL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = COLORFROMRGB(r: 152, 153, 153, alpha: 1)
        return l
    }()
    lazy var uniPriceL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = COLORFROMRGB(r: 102, 102, 101, alpha: 1)
        return l
    }()
    lazy var offL: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = COLORFROMRGB(r: 255, 98, 98, alpha: 1)
        return l
    }()

    lazy var hotIV: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "ic_hot"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var container: UIView = {
        let c = UIView.init(frame: self.bounds)
        c.backgroundColor = .clear
        return c
    }()
 
     init(frame: CGRect,  pdct: HWProduct) {
        
        product = pdct
        super.init(frame:frame)
        addSubview(container)
        self.clipsToBounds = false
        backgroundColor = .clear
        container.layer.cornerRadius = 9
        container.layer.masksToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = COLORFROMRGB(r: 219, 219, 219, alpha: 1).cgColor
        container.addSubview(totolPriceL)
        container.addSubview(numberL)
        container.addSubview(unitL)
        container.addSubview(uniPriceL)
        container.addSubview(offL)

        totolPriceL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.width.equalToSuperview()
            m.height.equalTo(33)
            m.bottom.equalToSuperview()
        }
        
        numberL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview().offset(-15)
            m.bottom.equalTo(uniPriceL.snp.top).offset(-10)
        }
        unitL.snp.makeConstraints { (m) in
            m.bottom.equalTo(numberL).offset(-4)
            m.left.equalTo(numberL.snp.right).offset(3)
            m.width.equalTo(55)
        }
        
        offL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(numberL.snp.top)
        }
        
        uniPriceL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(totolPriceL.snp.top).offset(-5)
        }

        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(taped))
        tap.delegate = self
        addGestureRecognizer(tap)

        totolPriceL.text = product?.amount
        unitL.text = product?.unit
    }
    
    @objc func taped(sender: UITapGestureRecognizer) -> Void {
        if isSelected {
            return
        }
        if delegate != nil {
            delegate?.productItem(self, selecteProduct: product!)
        }
        isSelected = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





class HWVipProductItem: HWProductItem {
    
    var duration: Int?

    override init(frame: CGRect,  pdct: HWProduct) {
        super.init(frame: frame, pdct: pdct)
        
        let vipP = pdct as! HWVIPProduct
        uniPriceL.text = vipP.textTwo
        numberL.text = vipP.monthNum

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class HWDiamendProductItem : HWProductItem {
    
    
    override init(frame: CGRect,  pdct: HWProduct) {
        super.init(frame: frame, pdct: pdct)
        unitL.text = ""
        uniPriceL.text = "Diamond"
        
        numberL.snp.remakeConstraints{ (m) in
            m.bottomMargin.equalTo(uniPriceL.snp.top).offset(-5)
            m.centerX.equalToSuperview()
        }

        let diap = pdct as! HWDiamendProduct
        offL.text = diap.explain
        numberL.text = String(diap.number!)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
