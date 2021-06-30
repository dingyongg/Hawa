//
//  HWAvatarEdtTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/8.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWAvatarEdtTableViewCell: HWBaseTableViewCell {

    lazy var titleL: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("Head Photo")
        l.textColor = THEME_TITLE_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 18)
        return l
    }()
    
    lazy var noteL: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("It needs to be a real person photo")
        l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 13)
        return l
    }()
    
    
    lazy var avartIV: AvatarView = {
        let v = AvatarView.init()
        v.add(self, action: #selector(clickAvatar))
        return v
    }()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleL)
        contentView.addSubview(noteL)
        contentView.addSubview(avartIV)
        
        titleL.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(20)
            m.topMargin.equalTo(20)
        }
        noteL.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(20)
            m.bottomMargin.equalTo(-20)
        }
        
        avartIV.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 66, height: 66))
            m.centerY.equalToSuperview()
            m.rightMargin.equalTo(-20)
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
