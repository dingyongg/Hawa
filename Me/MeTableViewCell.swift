//
//  MeTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/23.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class MeTableViewCell: UITableViewCell {

    lazy var titleL:UILabel = {()->UILabel in
        let label = UILabel.init()
        label.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var iconIV:UIImageView = {()-> UIImageView in
        let iv = UIImageView.init()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    var indicatorV:UIView

    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    

    init(title:String, iconName:String, indicater:UIView){
        indicatorV = indicater
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        titleL.text = title
        iconIV.image = UIImage.init(named: iconName)

        self.contentView.addSubview(iconIV)
        self.contentView.addSubview(titleL)
        self.contentView.addSubview(indicatorV)
        self.backgroundColor = .white
        self.contentView.backgroundColor = .white
        
        iconIV.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(18)
            maker.leftMargin.equalTo(18)
            maker.centerY.equalTo(self.contentView)
        }
        indicatorV.snp.makeConstraints { (m) in
            m.rightMargin.equalTo(-18)
            m.centerY.equalTo(self.contentView)
     
        }
        
        if indicatorV.isKind(of: UIImageView.self) {
            indicatorV.snp.makeConstraints { (m) in
                m.width.height.equalTo(15)
            }
        }
        
        titleL.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self.contentView)
            maker.left.equalTo(iconIV.snp.right).offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
