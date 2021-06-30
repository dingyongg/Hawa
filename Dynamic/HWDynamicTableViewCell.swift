//
//  WHDynamicTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/16.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import JXPhotoBrowser

class HWDynamicTableViewCell: HWBaseTableViewCell {

    weak var controller: UIViewController?
    
    weak var tableView: UITableView?
    
    var avartarClick: ((Int)->Void)?
    var likeClick: ((HWDynamicsModel)->Void )?
    var letterClick: ((Int)->Void)?
    var moreClick: ((HWDynamicsModel)->Void)?
    var model: HWDynamicsModel? = nil {
        
        didSet{
            var ivs: [UIImageView] = []

            for i in 0 ..< (model?.imgs.arrayValue.count)! {
                let image = model?.imgs[i]["smallImg"].string
                let iv = UIImageView()
                iv.sd_setImage(with: URL.init(string: image! )) { (image, error, type, url) in
                    
                }
                ivs.append(iv)
                
            }
    
            nameL.text = model?.name
            sexIV.image = UIImage(named: model?.sex == 0 ? "ic_gender_female":"")
            stateL.text = model?.comment
            
            avatarImageV.setImage((model?.headUrl)!)
            imageC.imagesData = model!.imgs
            
            self.starBtn.title = String(model!.likeTimes)
            
            if model!.liked {
                starBtn.image = "ic_stared"
            }else{
                starBtn.image = "ic_star"
            }
        }
    }
    
    
    lazy var avatarImageV: HWAvatar = {
        let v = HWAvatar.init(frame: CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 20, width: 64, height: 64))
        v.addTarget(self, action: #selector(avatarClick), for: .touchUpInside)
        return v
    }()
    
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.autoresizingMask = .flexibleWidth
        l.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    lazy var timeL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 10)
        return l
    }()
    

    lazy var sexIV: UIImageView = {
        let l = UIImageView.init(frame: .zero)
        l.contentMode = .scaleAspectFit
        return l
    }()
    lazy var stateL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r:51, 51, 51, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.numberOfLines = 0
        l.autoresizingMask = .flexibleHeight
        return l
    }()
    lazy var imageC: HWImgesContainer = {
        let c = HWImgesContainer.init([])
        c.delegete = self
        return c
    }()
    
    lazy var moreBtn: HWDynamicActionButton = {
        let b = HWDynamicActionButton.init(image: "ic_more_dark", title:String("")){
            
            self.moreClick?(self.model!)
            
           
        }
        return b
    }()
    
    lazy var starBtn: HWDynamicActionButton = {
        let b = HWDynamicActionButton.init(image: "ic_star", title:String(model?.likeTimes ?? 0)){
            self.likeClick?(self.model!)
        }
        return b
    }()
    
    lazy var letterBtn: HWDynamicActionButton = {
        let b = HWDynamicActionButton.init(image: "ic_letter", title: "") {
             self.letterClick?((self.model?.userId)!)
        }
        return b
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let _ = HWDynamicActionButton.init(image: "ic_share", title: "") {
            
        }
        let _ = HWDynamicActionButton.init(image: "ic_comment", title:String( arc4random()%20)) {
            
        }

        contentView.addSubview(avatarImageV)
        contentView.addSubview(nameL)
        contentView.addSubview(sexIV)
        contentView.addSubview(stateL)
        contentView.addSubview(timeL)
        contentView.addSubview(imageC)
        contentView.addSubview(moreBtn)
//        contentView.addSubview(commentBtn)
        contentView.addSubview(starBtn)
        contentView.addSubview(letterBtn)

        contentView.bringSubviewToFront(starBtn)
        contentView.bringSubviewToFront(letterBtn)
        
        nameL.snp.makeConstraints { (m) in
            m.left.equalTo(avatarImageV.snp.right).offset(7)
            m.centerY.equalTo(avatarImageV).offset(-10)
        }
        sexIV.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 13, height: 13))
            m.left.equalTo(nameL.snp.right).offset(5)
            m.centerY.equalTo(nameL)
        }
        timeL.snp.makeConstraints { (m) in
            m.top.equalTo(nameL.snp.bottom).offset(5)
            m.left.equalTo(nameL)
        }
        stateL.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
            m.top.equalTo(avatarImageV.snp.bottom).offset(10)
            
        }
        
        imageC.snp.makeConstraints { (m) in
            m.top.equalTo(stateL.snp.bottom).offset(8)
            m.left.equalToSuperview()
            m.bottom.equalToSuperview()
            m.right.equalToSuperview()
        }
        moreBtn.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 30, height: 30))
            m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
            m.top.equalToSuperview().offset(10)
        }
//        commentBtn.snp.makeConstraints { (m) in
//            m.bottom.equalTo(shareBtn)
//            m.centerX.equalToSuperview().offset(-60)
//        }
        starBtn.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 50, height: 20))
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
            m.bottom.equalToSuperview().offset(-12)
        }
        letterBtn.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 50, height: 20))
            m.left.equalTo(starBtn.snp.right).offset(80)
            m.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
  
    }
    
    @objc func avatarClick(_ sender: UIButton) -> Void {
        avartarClick?((model?.userId)!)
    }
    
    class HWDynamicActionButton: UIView {
        
        lazy var imageB: UIButton = {
            let b = UIButton.init(type: .custom)
            b.imageView?.contentMode = .scaleAspectFit
            b.addTarget(self, action: #selector(click), for: .touchUpInside)
            b.isEnabled = false
            return b
        }()
        lazy var titleL: UILabel = {
            let l = UILabel.init(frame: .zero)
            l.font = UIFont.systemFont(ofSize: 14)
            l.textColor = COLORFROMRGB(r: 102, 102, 102, alpha: 1)
            return l
        }()
        
        var title: String?{
            didSet{
                titleL.text = title
            }
        }
        
        var image: String?{
            didSet{
                imageB.setImage(UIImage.init(named: image!), for: .disabled)
            }
        }
        
        var tap: (()->Void)?
        
        init(image:String, title:String, action:  @escaping ()->Void) {
            tap = action
            super.init(frame: .zero)
            addSubview(imageB)
            addSubview(titleL)
            self.setTitleAndImage(image: image, title: title)
            imageB.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize.init(width: 17, height: 17))
                m.left.equalToSuperview()
                m.centerY.equalToSuperview()
            }
            
            
            titleL.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalTo(imageB.snp.right).offset(5)
            }
            
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
            self.addGestureRecognizer(tap)
            self.isUserInteractionEnabled = true
        }
        
        func setTitleAndImage(image:String, title:String) -> Void {
            self.title = title
            self.image = image
        }
        
        @objc func click(_ sender: UIButton) -> Void {
            tap?()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}


extension HWDynamicTableViewCell: HWImgesContainerDelegete{
    func imageContainerCalculated(_ container: HWImgesContainer, direction: HWImgesContainerImageDirection) {
    
        if direction == .landscape {
            if model?.imgsH == 0 {
                model?.imgsH = imageC.landscape.height
                self.tableView?.reloadData()
            }
        }else{
            if model?.imgsH == 0  {
                model?.imgsH = imageC.protrait.height
                self.tableView?.reloadData()
            }
        }
        
    }
    
    func imageContainer(_ container: HWImgesContainer, tapedIndex: Int) {

        let browser = JXPhotoBrowser()
        browser.numberOfItems = { [self] in
            return (self.model?.imgs.count)!
        }
        browser.pageIndex = tapedIndex
        browser.reloadCellAtIndex = { context in
            
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            
            let ivb = container.subviews[context.index] as! ImageContainerButton
            
            browserCell?.imageView.image = ivb.imageView?.image
            
        }
        browser.show()
        
        //VipChargeView.init().present()
    }
    
    
}
