//
//  HWLogoutTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/23.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWLogoutTableViewCell: HWBaseTableViewCell {

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            
        let l = UILabel.init()
        l.text = DYLOCS("Log out")
        l.textColor = THEME_COLOR_RED
        l.font = UIFont.systemFont(ofSize: 18)
        addSubview(l)
        l.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        
    }

}
