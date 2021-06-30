//
//  HWMCPriceCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/10.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWMCPriceCell: HWBaseTableViewCell {
    
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    var data: JSON?{
        didSet{
            pL.text = data!["textOne"].string
            nL.text = data!["explain"].string
            aB.setTitle(data!["amount"].string, for: .normal)
            uL.text = data!["textTwo"].string
        }
    }

    @IBOutlet weak var pL: UILabel!
    @IBOutlet weak var nL: UILabel!
    @IBOutlet weak var aB: UIButton!
    @IBOutlet weak var uL: UILabel!
    
    
    var buy: ((JSON)-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for s in self.subviews {
            if s != contentView && s.width == width {
                s.removeFromSuperview()
            }
        }
        
    }
    
    @IBAction func buyAction(_ sender: Any) {
        
        buy?(self.data!)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
