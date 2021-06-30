//
//  HwLiveCollectionViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/15.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SDWebImage

class HWLiveCollectionViewCell: UICollectionViewCell {
    
    var dataModel:HawaLiveUseModel?
    lazy var bgImageView: UIImageView = {
        let iv = UIImageView.init(frame: .zero)
        iv.contentMode = .center
        iv.backgroundColor = THEME_PLACEHOLDER_COLOR
        return iv
    }()
    lazy var nameL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 17)
        return l
    }()
    lazy var watchL: HWLiveCollectionCellWatchLabel = {
        let l = HWLiveCollectionCellWatchLabel.init()
        return l
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    
        
        addSubview(bgImageView)
        addSubview(watchL)
        addSubview(nameL)
        
        bgImageView.snp.makeConstraints { (m) in
            m.size.equalToSuperview()
            m.center.equalToSuperview()
        }
        watchL.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.right.equalToSuperview().offset(-8)
            m.height.equalTo(15)
            //m.width.equalTo(45)
        }
        nameL.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(15)
            m.bottomMargin.equalTo(-8)
        }
        
    }
    
    override func layoutSubviews() {
        bgImageView.sd_setImage(with: URL(string: dataModel?.imgPath ?? "") ) { (image, error, type, url) in
            
        }
        nameL.text = dataModel?.name
        watchL.watch = (dataModel?.watch)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HWLiveCollectionCellWatchLabel: UIView {
    
    var watch: Int {
        didSet{
            watchL.text = String(describing: watch)
        }
    }

    
    private lazy var ic: UIImageView = {
        let v = UIImageView.init(frame:.zero)
        v.image = UIImage.init(named: "ic_watch")
        v.contentMode = .scaleAspectFit
        return v
    }()
    private lazy var watchL: UILabel = {
        let l = UILabel()
        l.autoresizingMask = .flexibleWidth
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 10, weight: .light)
        return l
    }()
    
    
    init(){
        watch = 0
        super.init(frame: .zero)
        autoresizingMask = .flexibleWidth
        backgroundColor = COLORFROMRGB(r: 0, 0, 0, alpha: 0.4)
        addSubview(ic)
        addSubview(watchL)
        
        ic.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.width.height.equalTo(10)
            m.leftMargin.equalTo(5)
        }
        watchL.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(ic.snp.right).offset(3)
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
