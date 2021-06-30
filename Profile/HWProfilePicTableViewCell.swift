//
//  HWProfilePicTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import JXPhotoBrowser


class HWProfilePicTableViewCell: HWBaseTableViewCell {
    let space: CGFloat = 6
    
    lazy var titleL: UILabel = {
        let l = UILabel.init(frame: .zero)
        l.textColor = THEME_CONTENT_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    lazy var moreBtn: UIButton = {
        let b = UIButton.init(frame: .zero)
        b.setTitle(DYLOCS("more") , for: .normal)
        b.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.setTitleColor(COLORFROMRGB(r: 102, 102, 102, alpha: 1), for: .normal)
        return b
    }()
    
    
    var title: String?{
        didSet{
            titleL.text = title
        }
    }

    var imageViews: [HWBlurImage]? = []
    
    var images: JSON? = []{
        didSet{
            
            for i in contentView.subviews {
                if i is HWBlurImage {
                    let blur = i as! HWBlurImage
                    blur.removeFromSuperview()
                }
            }
            imageViews?.removeAll()
            
            let imageWH = (SCREEN_WIDTH - HAWA_SCREEN_HORIZATAL_SPACE - HAWA_SCREEN_HORIZATAL_SPACE - space - space) / 3
            for i in 0 ..< (images?.count ?? 0) {
                if i<3 {
                    let pic = HWBlurImage.init(frame:CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE + (imageWH + space) * CGFloat(i%3)  , y: 50, width: imageWH, height: imageWH))
                    pic.blur = title == DYLOCS("Private photos") ? 0.5 : 0
                    pic.imageUrl = images![i].string
                    pic.addtarget(self, action: #selector(imageClick), tag: i)
                    contentView.addSubview(pic)
                    imageViews?.append(pic)
                }else{
                    break
                }
            }
        }
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleL)
        //contentView.addSubview(moreBtn)
        contentView.layoutMargins = .zero
        titleL.snp.makeConstraints { (m) in
            m.topMargin.equalTo(10)
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
        }
//        moreBtn.snp.makeConstraints { (m) in
//            m.topMargin.equalTo(5)
//            m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc func showMore(_ sender: UIButton) -> Void{
        print(sender.tag)
    }
    
    @objc func imageClick(_ sender: UIButton) -> Void{
        
        
        if self.title == DYLOCS("Private photos") && !UserCenter.shared.isVIP() {
            if HWMemberShipModel.shared.products != nil {
                SVProgressHUD.dismiss()
                VipChargeView.init(HWMemberShipModel.shared.products!).present()
            }else{
                HWMemberShipModel.shared.loadProduct()
            }

        }else{
            let browser = JXPhotoBrowser()
            browser.numberOfItems = { [self] in
                return self.images!.count
            }
            browser.pageIndex = sender.tag
            browser.reloadCellAtIndex = { context in
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                
                let iv = self.imageViews![context.index]
        
                browserCell?.imageView.image = iv.image
            }
            browser.show()
        }
        


        
    }
    
}


class HWBlurImage: UIView {
    
    
    
    var animator: UIViewPropertyAnimator =  UIViewPropertyAnimator(duration: 0, curve: .linear)
    
    lazy var blurV: HWUIVisualEffectView = {
        let vibrancyView = HWUIVisualEffectView(effect:nil)
        vibrancyView.frame = self.bounds
        animator.addAnimations {
            vibrancyView.effect = UIBlurEffect(style: .light)
        }
        animator.fractionComplete = 0
        return vibrancyView
    }()
    
    lazy var imageBtn: UIButton = {
        let b = UIButton.init(frame: self.bounds)
        b.imageView?.contentMode = .scaleAspectFill
        b.isEnabled = false
        return b
    }()
    
    var blur: CGFloat = 0{
        didSet{
            animator.fractionComplete = blur
        }
    }
    
    var image: UIImage {
        return (imageBtn.imageView?.image)!
    }
    
    
    var imageUrl: String?{
        didSet{
            
            imageBtn.sd_setImage(with: URL.init(string: imageUrl!), for: .normal, placeholderImage: UIImage.init(named: "bg_placeholder"), options: .allowInvalidSSLCertificates) { (u, e, t, p) in
                self.imageBtn.isEnabled = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageBtn)
        addSubview(blurV)
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    
    func addtarget(_ target:Any?, action: Selector, tag:Int ) -> Void {
        imageBtn.addTarget(target, action: action, for: .touchUpInside)
        imageBtn.tag = tag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 事件穿透
    class HWUIVisualEffectView: UIVisualEffectView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let v = super.hitTest(point, with: event)
            if v == self {
                return nil
            }
            return v
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        animator.stopAnimation(true)
    }
}


