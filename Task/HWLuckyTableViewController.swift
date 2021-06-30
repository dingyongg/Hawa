//
//  HWLuckyTableViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/6.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit

class HWLuckyTableViewController: HawaBaseViewController {

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
        tabV.tabbarV.deHighlightedColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        tabV.titles = [DYLOCS("Lucky turntable")]
        tabV.titleAlignment = .left
        tabV.backgroundColor = COLORFROMRGB(r: 240, 242, 245, alpha: 1.0)
        view.addSubview(tabV)
        
    }
}

extension HWLuckyTableViewController:  HWScrollTabviewDelegate, HWScrollTabviewDataSource {
    
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        switch index {
        case 0:
            return lucky
        default:
            return UIView()
        }
    }
    
}
