//
//  HWMyFTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/9.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import DynamicBlurView


class HWMyFTableViewCell: HWBaseTableViewCell {
    /// avatar
    @IBOutlet weak var av: UIImageView!
    
    /// nickname
    @IBOutlet weak var n: UILabel!
    ///gender
    @IBOutlet weak var gen: UIImageView!
    ///age
    @IBOutlet weak var a: UILabel!
    ///city
    @IBOutlet weak var l: UILabel!
    
    /// avatar
    var avatarU: String?{
        didSet{
            av.sd_setImage(with: URL.init(string: avatarU ?? ""), completed:nil)
        }
    }
    /// nickname
    var nickName: String?{
        didSet{
            n.text = nickName
        }
    }
    
    ///gender
    var gender: Int?{
        didSet{
            if gender == 0 {
                gen.image = UIImage.init(named: "ic_gender_female")
            }else{
                
            }
        }
    }
    ///age
    var age: Int?{
        didSet{
            a.text = String((age ?? 0))
        }
    }
    ///city
    var city: String?{
        didSet{
            l.text = city ?? ""
        }
    }

    lazy var cover: DynamicBlurView = {
        let d = DynamicBlurView.init(frame: self.contentView.bounds)
        d.blurRadius = 7
        d.trackingMode = .tracking
        return d
    }()
    
    var seenable:Bool=true{
        didSet{
            if seenable == true {
                cover.removeFromSuperview()
            }else{
                addSubview(cover)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
