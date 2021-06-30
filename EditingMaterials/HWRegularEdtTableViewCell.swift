//
//  HWAvatarEdtTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/8.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWRegularEdtTableViewCell: HWBaseTableViewCell {
    
    var title: String?{
        didSet{
            titleL.text = title
        }
    }
    
    var value: String?{
        didSet{
            valueL.text = value
        }
    }
    
    var subTitle: String?{
        didSet{
            subTitleL.text = subTitle
        }
    }
    
    

    lazy var titleL: UILabel = {
        let l = UILabel.init()
        l.textColor = THEME_TITLE_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 18)
        return l
    }()
    
    lazy var valueL: UILabel = {
        let l = UILabel.init()
        l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    lazy var subTitleL: UILabel = {
        let l = UILabel.init()
        l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 16)
        l.numberOfLines = 0
        return l
    }()
    
    
    lazy var indicator: UIImageView = {
        let i = UIImageView.init(image: UIImage.init(named: "ic_right"))
        return i
    }()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleL)
        contentView.addSubview(valueL)
        contentView.addSubview(indicator)
        contentView.addSubview(subTitleL)

        titleL.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(20)
            m.topMargin.equalTo(15)
        }

        
        indicator.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 15, height:15))
            m.centerY.equalToSuperview()
            m.rightMargin.equalTo(-15)
        }
        
        valueL.snp.makeConstraints { (m) in
            m.right.equalTo(indicator.snp.left).offset(-5)
            m.centerY.equalToSuperview()
        }
        
        subTitleL.snp.makeConstraints { (m) in
            m.top.equalTo(titleL.snp.bottom).offset(8)
            m.left.equalTo(titleL)
            m.right.equalTo(indicator.snp.left).offset(-5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func clickAvatar() -> Void {
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
