//
//  HWTasksView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/28.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWTasksView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        UserCenter.shared.daliyTaskInfo { (res) in
            
        } fail: { (err) in
            SVProgressHUD.showError(withStatus: err.message)
        }

        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
