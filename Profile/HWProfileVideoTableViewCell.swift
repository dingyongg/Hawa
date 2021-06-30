//
//  HWShortVideoTableViewCell.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/16.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import SJVideoPlayer


class HWProfileVideoTableViewCell: HWBaseTableViewCell {

    var dataSource: JSON?
    
//    lazy var mainImageV: UIImageView = {
//        let v = UIImageView.init(frame: CGRect.init(x: 5, y:0 , width: SCREEN_WIDTH - 10, height: SCREEN_HEIGHT-HAWA_NAVI_HEIGHT-HAWA_BOTTOM_TAB_HEIGHT - 5 ))
//        //let v = UIImageView.init(frame: .zero)
//        v.layer.cornerRadius = 18
//        v.layer.masksToBounds = true
//        v.contentMode = .scaleAspectFill
//        return v
//    }()
    
//    lazy var nameL: UILabel = {
//        let l = UILabel()
//        l.textColor = .white
//        l.font = UIFont.systemFont(ofSize: 18)
//        return l
//    }()
//    lazy var ageL: UILabel = {
//        let l = UILabel()
//        l.textColor = .white
//        l.font = UIFont.systemFont(ofSize: 17)
//        return l
//    }()
//    lazy var sexIV: UIImageView = {
//        let l = UIImageView.init(frame: .zero)
//        l.contentMode = .scaleAspectFit
//        return l
//    }()
//    lazy var stateL: UILabel = {
//        let l = UILabel()
//        l.textColor = .white
//        l.font = UIFont.systemFont(ofSize: 14, weight: .thin)
//        l.numberOfLines = 0
//        l.textAlignment = .natural
//        return l
//    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = THEME_DARK_BG_COLOR
        //let imagesName = ["ic_heart","ic_audio", "ic_video", "ic_arrow_right"]
//        contentView.addSubview(avatarImageV)
//        contentView.addSubview(nameL)
//        contentView.addSubview(sexIV)
//        contentView.addSubview(ageL)
//        contentView.addSubview(stateL)
        
        self.layoutMargins = UIEdgeInsets.zero
//        let btnW: CGFloat = 62
//        let totalBtnW = btnW * CGFloat(imagesName.count)
//        let space: CGFloat = ( SCREEN_WIDTH - totalBtnW ) / CGFloat(imagesName.count+1)
//        for i in 0..<imagesName.count {
//            let btn = UIButton.init(frame:.zero)
//            btn.setImage(UIImage(named: imagesName[i]), for: .normal)
//            btn.addTarget(self, action: #selector(actions), for: .touchUpInside)
//            btn.tag = i
//            contentView.addSubview(btn)
//            btn.snp.makeConstraints { (m) in
//                m.bottomMargin.equalTo(-10)
//                m.size.equalTo(CGSize.init(width: btnW, height: btnW))
//                m.leftMargin.equalTo(space + (btnW + space) * CGFloat(i))
//            }
//        }
//        self.contentView.layoutMargins = .zero
//        self.contentView.preservesSuperviewLayoutMargins = true
//        self.preservesSuperviewLayoutMargins = true
        selectionStyle = .none
//        mainImageV.snp.makeConstraints { (m) in
//            m.topMargin.equalTo(0)
//            m.rightMargin.equalTo(-5)
//            m.bottomMargin.equalTo(-5)
//            m.leftMargin.equalTo(5)
//        }
//        nameL.snp.makeConstraints { (m) in
//            m.left.equalTo(avatarImageV.snp.right).offset(5)
//            m.top.equalTo(avatarImageV)
//        }
//        sexIV.snp.makeConstraints { (m) in
//            m.size.equalTo(CGSize.init(width: 13, height: 13))
//            m.left.equalTo(nameL.snp.right).offset(15)
//            m.centerY.equalTo(nameL)
//        }
//        ageL.snp.makeConstraints { (m) in
//            m.centerY.equalTo(nameL)
//            m.left.equalTo(sexIV.snp.right).offset(5)
//        }
//        stateL.snp.makeConstraints { (m) in
//            m.left.equalTo(nameL)
//            m.top.equalTo(nameL.snp.bottom)
//            m.size.equalTo(CGSize.init(width: SCREEN_WIDTH - 150, height: 40))
//        }
//
        
        // 视频播放父视图
        let videoSuper = HWProfileVideoSupreView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT) )
        contentView.addSubview(videoSuper)
        
    }
    
    override func layoutSubviews() {
        print("layoutSubviews")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class HWProfileVideoSupreView: UIView, SJPlayModelPlayerSuperview{
}

