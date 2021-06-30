//
//  HWSetupViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/13.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWSetupViewController: HWBaseTableViewController {

//    let rowData = [
//        [DYLOCS("Account security")],
//        [DYLOCS("New message notification"),DYLOCS("Privacy Settings")],
//        [DYLOCS("Online Service"),DYLOCS("Blacklist"),DYLOCS("About"),DYLOCS("Clean up cache")],
//        [DYLOCS("Log out")]
//    ]
        let rowData = [
            [DYLOCS("About"),DYLOCS("Privacy Pollicy"),DYLOCS("Software Usage Protocol"),DYLOCS("Feedback"),DYLOCS("Block list"),DYLOCS("Clean up cache")],
            [DYLOCS("Log out")]
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DYLOCS("Set Up")
        self.tableView.register(HWLogoutTableViewCell.self, forCellReuseIdentifier: ID_LOGOUT_CELL)
        self.tableView.showsVerticalScrollIndicator = false
        navigationController?.setNavigationBarHidden(false, animated: true)
       
    }
    
   func getCacheSize()-> Double {

        // 取出cache文件夹目录

        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

        // 取出文件夹下所有文件数组

        let fileArr = FileManager.default.subpaths(atPath: cachePath!)

        //快速枚举出所有文件名 计算文件大小

        var size = 0

        for file in fileArr! {

            // 把文件名拼接到路径中

            let path = cachePath! + ("/\(file)")

            // 取出文件属性

            let floder = try! FileManager.default.attributesOfItem(atPath: path)

            // 用元组取出文件大小属性

            for (key, fileSize) in floder {

                // 累加文件大小

                if key == FileAttributeKey.size {

                    size += (fileSize as AnyObject).integerValue

                }

            }

        }

        let totalCache = Double(size) / 1024.00 / 1024.00

        return totalCache

    }
    
    
     func clearCache() {

       // 取出cache文件夹目录

       let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

       let fileArr = FileManager.default.subpaths(atPath: cachePath!)

       // 遍历删除

       for file in fileArr! {

           let path = (cachePath! as NSString).appending("/\(file)")

           if FileManager.default.fileExists(atPath: path) {

               do {

                   try FileManager.default.removeItem(atPath: path)

               } catch {

                   

               }

           }

       }
        
        SVProgressHUD.showSuccess(withStatus: "Cleaned")

   }
    
}

extension HWSetupViewController{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case 0:

            switch indexPath.row {
            case 0:
                
                let vc = HWAboutViewController.init()
                navigationController?.pushViewController(vc, animated: true)
                
            case 1:
                let vc = HWWebViewController.init()
                vc.url = "http://api.tocamshow.com/app/private"
                vc.title = DYLOCS("Privacy Pollicy")
                navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = HWWebViewController.init()
                vc.url = "http://api.tocamshow.com/app/agreement"
                vc.title = DYLOCS("Software Usage Protocol")
                navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = HWFeedbackViewController.init()
                vc.title = DYLOCS("Feedback")
                navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = HWBlockListViewController.init()
                navigationController?.pushViewController(vc, animated: true)
            case 5:
                self.clearCache()
                self.tableView.reloadData()
            default:
                break
            }
            
        case 1:
            let a = UIAlertController.init(title: DYLOCS("Confirm") , message: DYLOCS("Do you really want to sgin out？") , preferredStyle: UIAlertController.Style.alert)
            let no = UIAlertAction.init(title: DYLOCS("No"), style: UIAlertAction.Style.cancel) { (act) in
                a.dismiss(animated: true, completion: nil)
            }
            let yes = UIAlertAction.init(title: DYLOCS("Yes"), style: UIAlertAction.Style.default) { (act) in
               
                SVProgressHUD.show()
                UserCenter.shared.logtout { (success) in
                    SVProgressHUD.dismiss()
                    
                    AppDelegate.appDelegate.window?.rootViewController = HWBaseNavigationController.init(rootViewController: HWLounchViewController())
                    
                } fail: { (error) in
                    SVProgressHUD.showError(withStatus: error.message)
                }
            }
            a.addAction(no)
            a.addAction(yes)

            self.present(a, animated: true, completion: nil)

        case 2:
            break
        case 3:
            break
        default:
            break
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == rowData.count-1 {
            let cell =  tableView.dequeueReusableCell(withIdentifier:ID_LOGOUT_CELL, for: indexPath ) as!   HWLogoutTableViewCell
            return cell
        }else{
            let rows = rowData[indexPath.section]
            var cell: UITableViewCell?
            cell = tableView.dequeueReusableCell(withIdentifier:ID_SYSTEM_CELL )
            if cell == nil{
                cell = UITableViewCell.init(style: HWSetTableViewCell.CellStyle.value1, reuseIdentifier: ID_SYSTEM_CELL)
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = rows[indexPath.row]
            
            if indexPath.section == 1 && indexPath.row == 1 {
                
                cell?.detailTextLabel?.text = NSString.init(format: "%.1f M", self.getCacheSize()) as String
            }
         
            return cell!
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return  UserCenter.shared.isLogin() ? rowData.count : rowData.count-1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = rowData[section] as Array
        return rows.count
    }
    
}
