//
//  HwHomeCollectionViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/15.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SDWebImage
import KJBannerView
import SwiftyJSON


class HWHomeCollectionViewCell: UICollectionViewCell {
    
    
    var imageData:[String] = []
    
    var dataModel:UserModel?{
        didSet{
            imageData = []
            if dataModel?.album?.type == SwiftyJSON.Type.null {
                
                bannerV!.delegate = nil
                bannerV!.dataSource = nil
                bgImageView.frame = self.bounds
                bgImageView.sd_setImage(with: URL(string: dataModel?.headImg ?? "") ) { (image, error, type, url) in  }
                
                bannerV!.removeFromSuperview()
                insertSubview(bgImageView, at: 0)
            }else{
                imageData.append(dataModel?.headImg ?? "")
                
                for i in 0..<dataModel!.album!.count {
                    let pic =  dataModel!.album![i].string
                    imageData.append(pic ?? "")
                }
                bannerV?.dataSource = self
                bannerV!.imageDatas = imageData
                bannerV!.frame = self.bounds
                insertSubview(bannerV!, at: 0)
                bannerV?.autoScroll = true
                bgImageView.removeFromSuperview()
            }

            nameL.text = dataModel?.nickname ?? ""
            stateL.lineState = dataModel?.onlineState == 0 ?.onLine:.offLine
            gender.image =  UIImage.init(named:dataModel?.gender == 1 ? "ic_gender_male_select" : "ic_gender_female")
            ageL.text = String((dataModel?.age)!)
            
        }
    }
    weak var collectionV: HWCollectionView?

    lazy var bgImageView: UIImageView = {
        let iv = UIImageView.init(frame: self.bounds)
        iv.backgroundColor = THEME_PLACEHOLDER_COLOR
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17)
        return l
    }()
    
    lazy var gender: UIImageView = {
        let iv = UIImageView.init()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    lazy var ageL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return l
    }()
    
    lazy var stateL: HWHomeCollectionCellStateLabel = {
        let l = HWHomeCollectionCellStateLabel.init(.onLine)
        return l
    }()
    
    lazy var bannerV: KJBannerView? = {
        let v = KJBannerView.init(frame: self.bounds)
        v.autoScrollTimeInterval = 2
        v.pageControl.normalColor  = .clear
        v.pageControl.selectColor = .clear
        v.itemWidth = self.width
        v.itemSpace = 0
        v.delegate = self
    
        return v
    }()
    
    lazy var cover: UIView = {
        let v = UIView.init(frame: self.bounds)
        v.backgroundColor = .clear
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .lightGray
        addSubview(bgImageView)
        addSubview(stateL)
        addSubview(nameL)
        addSubview(gender)
        addSubview(ageL)
        addSubview(cover)

        stateL.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.right.equalToSuperview().offset(-8)
            m.height.equalTo(15)
        }
        nameL.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(15)
            m.bottomMargin.equalTo(-8)
        }
        gender.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 13, height: 13))
            m.centerY.equalTo(nameL).offset(1)
            m.left.equalTo(nameL.snp.right).offset(8)
        }
        ageL.snp.makeConstraints { (m) in
            m.centerY.equalTo(nameL)
            m.left.equalTo(gender.snp.right).offset(3)
        }
    }
    
    override func layoutSubviews() {
        
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HWHomeCollectionViewCell:KJBannerViewDelegate, KJBannerViewDataSource{
    
    func kj_BannerView(_ banner: KJBannerView!, bannerViewCell bannercell: KJBannerViewCell!, imageDatas: [Any]!, index: Int) -> UIView! {
        let iv = UIImageView.init(frame: self.bounds)
        iv.backgroundColor = THEME_PLACEHOLDER_COLOR
        iv.contentMode = .scaleAspectFill
        iv.sd_setImage(with: URL(string: self.imageData[index] ) ) { (image, error, type, url) in  }
        return iv
    }
}


enum HawaUserLineState {
    case onLine
    case offLine
}

class HWHomeCollectionCellStateLabel: UIView {
    
    private let onLineStr = DYLOCS("On-line")
    private let offLineStr = DYLOCS("Off-line")
    
    private lazy var stateDot: UIView = {
        let v = UIView.init(frame:.zero)
        v.backgroundColor = COLORFROMRGB(r: 0, 255, 63, alpha: 1)
        v.layer.cornerRadius = 2
        v.layer.masksToBounds = true
        return v
    }()
    private lazy var stateL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 8, weight: .light)
        return l
    }()
    
    var lineState: HawaUserLineState {
        didSet {
            if lineState == .onLine {
                stateL.text = onLineStr
            }else{
                stateL.text = offLineStr
            }
        }
    }
    
    init(_ state:HawaUserLineState){
        lineState = state
        super.init(frame: .zero)
        
        backgroundColor = COLORFROMRGB(r: 0, 0, 0, alpha: 0.4)
        addSubview(stateDot)
        addSubview(stateL)
        
        if state == .onLine {
            stateL.text = onLineStr
        }else{
            stateL.text = offLineStr
        }
        stateDot.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.width.height.equalTo(4)
            m.leftMargin.equalTo(5)
        }
        stateL.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(stateDot.snp.right).offset(3)
            m.rightMargin.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = rect.height/2
        layer.masksToBounds = true
    }
}
