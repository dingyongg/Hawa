//
//  HWCollectionReusableHeaderView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/16.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import KJBannerView

@objc protocol HWCollectionReusableHeaderViewDelegate {
    func HeaderView(_ headerView:HWCollectionReusableHeaderView, didSelectedBanner index:Int  ) -> Void
    func HeaderView(_ headerView:HWCollectionReusableHeaderView, didSelectedCountry code:String  ) -> Void
}

class HWCollectionReusableHeaderView: UICollectionReusableView, KJBannerViewDelegate, KJBannerViewDataSource{
    
    weak var delegate:HWCollectionReusableHeaderViewDelegate?
    var selectedCountryCode:String = "IND"{
        didSet{
            self.countryContiner.selectedCountryCode = selectedCountryCode
        }
    }
    func kj_BannerView(_ banner: KJBannerView!, bannerViewCell bannercell: KJBannerViewCell!, imageDatas: [Any]!, index: Int) -> UIView! {
        let v = UIImageView.init(image: UIImage.init(named: "home_banner"))
        v.frame = CGRect.init(x: 0, y: 0, width: banner.width - 20, height: banner.height)
        
        return v
    }

    var dataSource: [String]? {
        didSet {
            bannerV.imageDatas = dataSource!
        }
    }
    
    lazy var bannerV: KJBannerView = {
        let v = KJBannerView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 110))
        
        v.autoScrollTimeInterval = 3
        v.pageControl.pageType = KJPageControlStyle(rawValue: 1)
        v.itemWidth = SCREEN_WIDTH - 20
        v.itemSpace = 40
        v.imgCornerRadius = 10
        v.delegate = self
        v.dataSource = self
        v.imageDatas = [""]
        return v
    }()
    
    
    lazy var countryContiner:HWCountryContainer = {
        let cons = HWCountryContainer.init(frame: CGRect.init(x: 0, y: bannerV.x+bannerV.height, width: self.width, height: self.height - bannerV.height))
        cons.onCountryClickBlock = { code in
            self.delegate?.HeaderView(self, didSelectedCountry: code)
        }
        return cons
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bannerV)
        if HWAppCenter.shared.rabbit == 2 {
            addSubview(countryContiner)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func kj_BannerView(_ banner: KJBannerView!, select index: Int) {
        self.delegate?.HeaderView(self, didSelectedBanner: index)
    }

}

class HWCountryContainer: UIView {
    
    var selectedCountryCode:String = "IND"{
        didSet{
            for c in countryBtns {
                c.isSelected = c.countryInfo!["code"] == selectedCountryCode
            }
        }
    }
    
    
    var timer:Timer?
    var countryBtns:[HWContryButton] = []
    var onCountryClickBlock:((String)->Void)?
    
    let countrys =  [[
        "flag":"ic_country_india",
        "code":"IND"
    ],
    [
        "flag":"ic_country_arab",
        "code":"AE"
    ],
    [
        "flag":"ic_country_philippines",
        "code":"PH"
    ],
    [
        "flag":"ic_country_iran",
        "code":"IR"
    ],
    [
        "flag":"ic_country_malaysia",
        "code":"MY"
    ],
    [
        "flag":"ic_country_saudi",
        "code":"SA"
    ],
    [
        "flag":"ic_country_usa",
        "code":"US"
    ],
    [
        "flag":"ic_country_sudan",
        "code":"SD"
    ],
    [
        "flag":"ic_country_thailand",
        "code":"TH"
    ]]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gap:CGFloat = 8
        let totalWidth:CGFloat = self.width - 20 - gap*CGFloat((countrys.count - 1))
        let width:CGFloat = totalWidth/CGFloat(countrys.count)
        
        let size = CGSize.init(width: width, height: width)
        
        for  i in 0..<countrys.count {
            
            let origin = CGPoint.init(x: 10 + CGFloat(i)*(width+gap) , y: (self.height-width)/2  )
            let c = HWContryButton(frame: CGRect.init(origin: origin, size: size))
            c.countryInfo = countrys[i]
            
            c.addTarget(self, action: #selector(onCountryClick), for: .touchUpInside)
            c.tag = i
            c.isSelected = i == 0
            addSubview(c)
            self.countryBtns.append(c)
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(flip), userInfo: nil, repeats: true)
    }

    @objc func onCountryClick(_ sender: UIButton) -> Void {
        self.onCountryClickBlock?(countrys[sender.tag]["code"]!)
        for c in countryBtns {
            c.isSelected = c.tag == sender.tag
        }
    }
    
    @objc func flip(_ sender: UIButton) -> Void {
        
        var time: TimeInterval = 0.0
        for sub in self.subviews {
            let cons = sub as! HWContryButton
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                cons.flip()
            }
            time += 1.3
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class HWContryButton: UIButton{
    
    var countryInfo:[String:String]?{
        didSet{
            self.setBackgroundImage(UIImage.init(named: countryInfo!["flag"]!), for: .normal)
        }
    }
    
    override var isEnabled: Bool{
        didSet{
            if isEnabled {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
            }else{
                self.layer.borderWidth = 1.5
                self.layer.borderColor = THEME_COLOR_RED.cgColor
            }
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if !isSelected {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
            }else{
                self.layer.borderWidth = 1.5
                self.layer.borderColor = THEME_COLOR_RED.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height/2
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flip() -> Void {
        
        UIView.animate(withDuration: 0.8) {
            
            self.layer.transform =   CATransform3DMakeRotation(CGFloat.pi/2, 1, 0, 0)

        } completion: { (fini) in

            UIView.animate(withDuration: 0.8) {
                let rotateBack = CATransform3DMakeRotation(-CGFloat.pi/2, 1, 0, 0)
                self.layer.transform = CATransform3DConcat(self.layer.transform, rotateBack)
            } completion: { (finish) in

            }
        }
    }
    
}


