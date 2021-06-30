//
//  HWReconmmendListView.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/3/4.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON


class HWRecommendListView:FSScreenCover{
    
    var board:HWRecommendListViewBoard?
    
    lazy var users:[JSON?] = []{
        didSet{
            if users.count != 0 {
                self.board = HWRecommendListViewBoard(users)
                self.board!.closeBlock = {[weak self] in
                    if let strongSelf = self {
                        strongSelf.dismiss()
                    }
                }
                self.showView(self.board!)
               
            }
        }
    }

    deinit {
        print("aaaa")
    }
    
}



class HWRecommendListViewBoard: UIView {

    var closeBlock:(()->Void)?
    
    var selectedUsers:[JSON?] = []
    
    lazy var titleL: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.text = "Recommend the following users for you"
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    lazy var closeB: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_close_gray"), for: .normal)
        b.addTarget(self, action: #selector(closeA), for: .touchUpInside)
        return b
    }()
    
    lazy var followB: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title:DYLOCS("One click attention") , image: nil, targte: self, action: #selector(followAll))
        b.titleWeight = .bold
        return b
    }()

    init(_ users:[JSON?] ) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH*0.8, height: SCREEN_WIDTH*0.8*1.4))
        self.selectedUsers = users
        self.backgroundColor = .white
        self.layer.cornerRadius = 17

        addSubview(titleL)
        addSubview(closeB)
        addSubview(followB)
        
        closeB.snp.makeConstraints { (m) in
            m.topMargin.equalTo(20)
            m.rightMargin.equalTo(-20)
            m.width.equalTo(15)
            m.height.equalTo(15)
        }
        
        titleL.snp.makeConstraints { (m) in
            m.topMargin.equalTo(30)
            m.centerX.equalToSuperview()
            m.rightMargin.equalTo(-50)
            m.leftMargin.equalTo(50)
        }
        
        followB.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(-30)
            m.centerX.equalToSuperview()
            m.width.equalTo(frame.width*0.8)
            m.height.equalTo(60)
        }
        
        if (users.count != 0) {
            
            let space:CGFloat = 40   // 与父视图边框的距离
            let between:CGFloat = 15   //间隙
            let topSpace:CGFloat = 80
            for i in 0..<users.count {
                let user = users[i]
                let width:CGFloat = (frame.width-space-space-between-between)/3
                let height:CGFloat = width * 1.5
                let row = CGFloat(floorf(Float(i/3)))
                let coloum:CGFloat = CGFloat(i%3)
                
                let item = HWRecommendUser.init(frame: CGRect.init(x:   space + (width+between)*coloum, y: (height+between)*row + topSpace, width: width, height: height))
                item.dataSource = user
                
                item.selectedBlock = {[weak self] (user: JSON) in
                    if let strong = self {
                        strong.selectedUsers.append(user)
                    }
                }
                item.deselectedBlock = {[weak self] (user: JSON) in
                    if let strong = self {
                         let index = strong.selectedUsers.firstIndex(of: user)
                        if index != nil{
                            strong.selectedUsers.remove(at: index!)
                        }
                    }
                }
                addSubview(item)
            }
            
        }
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeA(sender: UIButton) -> Void {
        self.closeBlock?()
    }
    
    @objc func followAll(sender: UIButton) -> Void {
        
        if self.selectedUsers.count == 0 {
            self.closeBlock?()
            return
        }
        
        
        var ids: String = ""
        for user in self.selectedUsers {
           ids = ids + String(user!["id"].int!) + ","
        }
        
        self.closeBlock?()
        UserCenter.shared.groupFollow(followIds: ids) { (respond) in
            
        } fail: { (error) in
            
        }
    }

    deinit {
        print("aaaa")
    }
}


class HWRecommendUser: UIView {
    
    var selectedBlock:((JSON)->Void)?
    var deselectedBlock:((JSON)->Void)?
    
    var dataSource:JSON?{
        didSet{
            if dataSource != nil {
                profileImage.setImage(dataSource!["headImg"].string!)
                nameL.text = dataSource!["nickname"].string
            }
        }
    }
    
    var checked:Bool = true{
        didSet{
            if checked {
                checkbox.setImage(UIImage.init(named: "ic_checkbox_true"), for: .normal)
                self.selectedBlock?(self.dataSource!)
            }else{
                checkbox.setImage(UIImage.init(named: "ic_checkbox_false"), for: .normal)
                self.deselectedBlock?(self.dataSource!)
            }
        }
    }
    
    lazy var checkbox: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_checkbox_true"), for: .normal)
        b.addTarget(self, action: #selector(checkboxA), for: .touchUpInside)
        return b
    }()
    
    lazy var  nameL: UILabel = {
        let l = UILabel()
        l.textColor = COLORFROMRGB(r: 102, 102, 102, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return l
    }()
    
    lazy var profileImage: HWAvatar = {
        let iv = HWAvatar.init(frame: .zero)
        return iv
    }()
    
    @objc func checkboxA(sender: UIButton) -> Void {
        self.checked = !self.checked
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(checkbox)
        addSubview(profileImage)
        addSubview(nameL)
        
        checkbox.snp.makeConstraints { (m) in
            m.topMargin.equalTo(5)
            m.rightMargin.equalTo(0)
            m.width.equalTo(16)
            m.height.equalTo(16)
        }
        
        profileImage.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.centerX.equalToSuperview()
            m.width.equalTo(frame.width-5)
            m.height.equalTo(frame.width-5)
        }
        
        nameL.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(5)
            m.centerX.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


