//
//  HWMembershipPrivilegesCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/10.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWMembershipPrivilegesCell: HWBaseTableViewCell {
    @IBOutlet weak var textL: UILabel!
    
    var pri: String?{
        didSet{
            textL.text = pri
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for s in self.subviews {
            if s != contentView && s.height == 0.5 {
                s.removeFromSuperview()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
