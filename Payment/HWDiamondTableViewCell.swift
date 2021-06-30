//
//  HWDiamondTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/24.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWDiamondTableViewCell: HWBaseTableViewCell {
    
    @IBOutlet weak var numL: UILabel!
    @IBOutlet weak var priL: UILabel!
    @IBOutlet weak var container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        container.layer.cornerRadius = 12
        
        container.layer.shadowColor = COLORFROMRGB(r:0,0,0, alpha: 0.1).cgColor
        container.layer.shadowOffset = CGSize.init(width: 3, height: 3)
        container.layer.shadowOpacity = 0.9;
        container.layer.shadowRadius = 10;
    }

    override func layoutSubviews() {
        
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setSelected(highlighted, animated: animated)
        
        if highlighted {
            container.layer.shadowOpacity = 0;
        }else{
            container.layer.shadowOpacity = 0.9;
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        container.layer.shadowOpacity = 0.9;
    }
    
    
    
}
