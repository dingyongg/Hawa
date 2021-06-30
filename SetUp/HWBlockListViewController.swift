//
//  HWBlockListViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/11.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import MJRefresh

class HWBlockListViewController: HWBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DYLOCS(DYLOCS("Block List"))
        
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
    
        UserCenter.shared.refreshBlockList{(respond) in
            self.tableView.mj_header?.endRefreshing()
            self.tableView.reloadData()
        } fail: { (error) in
            self.tableView.mj_header?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }

    }
    
    @objc func  loadMore() -> Void {
        
        UserCenter.shared.moreBlockList{(respond) in
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.reloadData()
        } fail: { (error) in
            self.tableView.mj_footer?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }

    }
    
    deinit {
        UserCenter.shared.dataContainer = []
    }
    
}



extension HWBlockListViewController{
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let actions = UITableViewRowAction.init(style: .normal, title: DYLOCS("Unblock")) { (action, index) in
            
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
            let id = UserCenter.shared.dataContainer[indexPath.row]!["userId"].int!
            UserCenter.shared.block(id, type: 1) { (res) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showSuccess(withStatus: "Unblock successfully")
                
                let result = UserCenter.shared.dataContainer.filter({ (user) -> Bool in
                    return user!["userId"].int! != id
                })
                
                UserCenter.shared.dataContainer = result
                self.tableView.reloadData()
                
            } fail: { (error) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showError(withStatus: error.message)
            }

            
            
        }
        actions.backgroundColor = .green
        return [actions]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
        cell.selectionStyle = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  UserCenter.shared.dataContainer.count
    }
    
}
