//
//  HWTaskViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/28.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWTaskViewController: HawaBaseViewController{
    
    
    lazy var walk: HWWalkView = {
        let v = HWWalkView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT))
        return v
    }()
    lazy var tasks: HWTasksView = {
        let v = HWTasksView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT))
        return v
    }()

    lazy var lucky: HWLuckyTable = {
        let v = HWLuckyTable.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT))
        return v
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tabV = HWScrollTabView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT ))
        tabV.delegete = self
        tabV.dataSource = self
        tabV.tabbarV.highlightedColor = COLORFROMRGB(r: 87, 134, 130, alpha: 1)
        tabV.titles = [DYLOCS("Walk"),DYLOCS("Lucky turntable") ]
        tabV.tabbarBackgroudColors = [UIColor.white, COLORFROMRGB(r: 208, 245, 199, alpha: 1)]
        tabV.titleAlignment = .left
        
        view.addSubview(tabV)
    }

}


extension HWTaskViewController:  HWScrollTabviewDelegate, HWScrollTabviewDataSource {
    
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        switch index {
        case 0:
            return walk
        case 1:
            return lucky
        default:
            return UIView()
        }
    }
    
}
