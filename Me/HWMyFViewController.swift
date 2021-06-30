//
//  HWMyfansViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/8.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import MJRefresh
import DynamicBlurView

enum HWMyFType: Int{
    case fan = 0
    case follow = 1
    case visit = 2
}


class HWMyFViewController: HWBaseTableViewController {
    
    var type: HWMyFType?
    
    init(_ type: HWMyFType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        if type == .fan {
            self.title = DYLOCS("Fans")
        }else if type == .follow{
            self.title = DYLOCS("Follow")
        }else if type == .visit{
            self.title = DYLOCS("Recent Visit")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(loadMore))
        tableView.register(UINib.init(nibName: "HWMyFTableViewCell", bundle: nil), forCellReuseIdentifier: ID_MY_F_TABLE_CELL)
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func  refresh() -> Void {
        
        if type == HWMyFType.visit {
            UserCenter.shared.refreshRecentVisit{ (respond) in
                self.tableView.mj_header?.endRefreshing()
                self.tableView.reloadData()
            } fail: { (error) in
                self.tableView.mj_header?.endRefreshing()
                SVProgressHUD.showError(withStatus: error.message)
            }
        }else{
            
            UserCenter.shared.refreshFollowFanList (type:( type == .fan ? 1 : 2 )) { (respond) in
                self.tableView.mj_header?.endRefreshing()
                self.tableView.reloadData()
            } fail: { (error) in
                self.tableView.mj_header?.endRefreshing()
                SVProgressHUD.showError(withStatus: error.message)
            }
        }
        
    }
    
    @objc func  loadMore() -> Void {
        
        if type == HWMyFType.visit {
            UserCenter.shared.moreRecentVisit{ (respond) in
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.reloadData()
            } fail: { (error) in
                self.tableView.mj_footer?.endRefreshing()
                SVProgressHUD.showError(withStatus: error.message)
            }

        }else{
            UserCenter.shared.moreFollowFanList(type: (type == HWMyFType.fan ? 1 : 2 )) { (respond) in
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.reloadData()
            } fail: { (error) in
                self.tableView.mj_footer?.endRefreshing()
                SVProgressHUD.showError(withStatus: error.message)
            }
        }
        
    }
    
    deinit {
        UserCenter.shared.dataContainer = []
    }
    
}

extension HWMyFViewController{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row > 2 && !UserCenter.shared.isVIP() {
            if HWMemberShipModel.shared.products != nil {
                let char =  VipChargeView.init(HWMemberShipModel.shared.products!)
                char.present()
            }else{
                HWMemberShipModel.shared.loadProduct()
            }
        }else{
            let d = UserCenter.shared.dataContainer[indexPath.row]!["userId"].int
            
            let profileVC = HWProfileViewController.init(NSNumber(value: d!))
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ID_MY_F_TABLE_CELL, for: indexPath) as! HWMyFTableViewCell
        
        let data = UserCenter.shared.dataContainer[indexPath.row]
        
        cell.avatarU = data!["headImg"].string
        cell.nickName =  data!["nickname"].string
        cell.gender =  data!["gender"].int
        cell.age =  data!["age"].int
        cell.city =  data!["city"].string

        if indexPath.row > 2 && !UserCenter.shared.isVIP() {
            cell.seenable = false
        }else{
            cell.seenable = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  UserCenter.shared.dataContainer.count
    }
    
}
