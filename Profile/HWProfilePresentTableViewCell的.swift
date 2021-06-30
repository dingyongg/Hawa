//
//  HWProfilePicTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWProfilePresentTableViewCell: HWBaseTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    lazy var titleL: UILabel = {
        let l = UILabel.init(frame: .zero)
        l.textColor = THEME_CONTENT_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    
    
    var title: String?{
        didSet{
            titleL.text = title
        }
    }
    

    let presentW = 60
    let presentH = 80
    
    var presents: JSON? = []{
        didSet{
            
            for i in contentView.subviews {
                if i is HWPresenet  {
                    i.removeFromSuperview()
                }
            }

            let space = (Int(SCREEN_WIDTH)-presentW*4)/5
            for i in 0..<presents!.count {
                let div: Double  = Double(i / 4)
                let row = floor(div)
                let present = HWPresenet.init(frame: CGRect.init(x: space + (presentW + space) * (i%4)  , y: Int(row) * (presentH + 15 )+50 , width: presentW, height: presentH))
                present.price = 60
                present.present = presents![i]
                contentView.addSubview(present)
              
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleL)
  
        titleL.snp.makeConstraints { (m) in
            m.topMargin.equalTo(10)
            m.leftMargin.equalTo(HAWA_SCREEN_HORIZATAL_SPACE)
        }

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc func showMore(_ sender: UIButton) -> Void{
        print(sender.tag)
    }
    
}


class HWPresenet: UIView {
    
    lazy var presentIv: UIImageView = {
        let iv = UIImageView.init(frame: .zero)
        return iv
    }()
    
    lazy var present: JSON? = [] {
        didSet{
            presentIv.sd_setImage(with: URL.init(string: present!["imageUrl"].string!), completed: nil)
            priceL.text = String(present!["number"].int!) + " " + present!["name"].string!
        }
    }
    
    lazy var priceL: UILabel = {
        let l = UILabel.init()
        l.textColor = THEME_CONTENT_DARK_COLOR
        l.font = UIFont.systemFont(ofSize: 10)
        return l
    }()
    
    var price: Int?{
        didSet{
            priceL.text = String(price!) + "silver"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentIv)
        addSubview(priceL)
        
        presentIv.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 60, height: 60))
            m.top.equalToSuperview()
            m.centerX.equalToSuperview()
        }
        priceL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(presentIv.snp.bottom).offset(5)
            m.bottom.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
