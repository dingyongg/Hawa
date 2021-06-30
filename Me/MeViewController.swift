//
//  MeViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/17.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
import SwiftyJSON
import DynamicBlurView

class MeViewController: HWBaseTableViewController {
    
//    let cellTitles:Array = [NSLocalizedString( "My wallet", comment: ""),NSLocalizedString( "Member Center", comment: ""),NSLocalizedString( "My earnings", comment: ""),NSLocalizedString( "Invite to make money", comment:""),NSLocalizedString("Mission Center", comment: ""),NSLocalizedString( "Real name authentication", comment: "") ,NSLocalizedString("Don't disturb", comment: ""),NSLocalizedString("Dressing Room", comment: ""),NSLocalizedString("Set up", comment: ""),]
//    let iconNames:Array = ["ic_my_wallet","ic_my_wallet", "ic_my_earnings", "ic_invite_make_money","ic_misson_center","ic_real_name_authentication", "ic_dont_disturb", "ic_dressing_room","ic_set_up",]
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(SCREEN_WIDTH, SCREEN_HEIGHT)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        let tableHeader =  MeTableHeader.init()
        tableHeader.delegete = self
        tableView.tableHeaderView = tableHeader
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        preferredStatusColor = .default
        let header = tableView.tableHeaderView as! MeTableHeader
        
        if UserCenter.shared.isLogin() {
            UserCenter.shared.getInfo { (info) in
                header.loadData()
            } fail: { (error) in
                SVProgressHUD.showError(withStatus: error.message)
            }
        }else{
            header.loadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
    }
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
    }


    
}

extension MeViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var indicator:UIView
        indicator = UIImageView(image: UIImage(named: "ic_right"))
        let cell = MeTableViewCell.init(title: cellTitles[indexPath.row], iconName: iconNames[indexPath.row], indicater: indicator)
       // if   {cell.selectionStyle = .none}
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 10))
        v.backgroundColor = COLORFROMRGB(r: 239, 239, 243, alpha: 1)
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0 :
            let VC = HWWalletViewController()
            VC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(VC, animated: true)
        case 1 :
            let VC = HWMemberCenterViewController.init(nibName:"HWMemberCenterViewController", bundle: nil)
            VC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(VC, animated: true)
        case 2 :
            
            let setVC = HWSetupViewController()
            setVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(setVC, animated: true)
            
            break
            let conv = WFCCConversation.init(type: .Single_Type, target: "25609", line: 0)
            let content = WFCCTextMessageContent.init("Get the most out of your new inbox by quickly and easily marking all of your previously read notifications as done.")
            
            let extro: JSON = [
                "avatar": UserCenter.shared.theUser?.headImg as Any,
                "sex": UserCenter.shared.theUser?.gender as Any,
                "nickname":UserCenter.shared.theUser?.nickname as Any,
                "vipType": UserCenter.shared.theUser?.vipType as Any,
                "sentTime": Date.init().timeIntervalSince1970 as Any
            ]
            
            content?.extra = extro.rawString()
            WFCCIMService.sharedWFCIM()?.send(conv, content: content, success: { (sdf, sf) in
                print(sdf, sf)
            }, error: { (error) in
                print(error)
            })
            
        case 3 :
            let VC = HWSetupViewController()
            VC.hidesBottomBarWhenPushed = true
            //navigationController?.pushViewController(VC, animated: true)
            SVProgressHUD.showInfo(withStatus: DYLOCS("Coming soon"))
        case 4 :
            let VC = HWMemberCenterViewController()
            VC.hidesBottomBarWhenPushed = true
            //navigationController?.pushViewController(VC, animated: true)
            SVProgressHUD.showInfo(withStatus: DYLOCS("Coming soon"))
        case 5 :
            let VC = HWSetupViewController()
            VC.hidesBottomBarWhenPushed = true
            //navigationController?.pushViewController(VC, animated: true)
            SVProgressHUD.showInfo(withStatus: DYLOCS("Coming soon"))
        case 7 :
            let VC = HWSetupViewController()
            VC.hidesBottomBarWhenPushed = true
            //navigationController?.pushViewController(VC, animated: true)
            SVProgressHUD.showInfo(withStatus: DYLOCS("Coming soon"))
        default:
            return
        }
        
    
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 5 {
            return false
        }else{
            return true
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension MeViewController: MeTableHeaderDelegate {
    func didTapedAvatar(view: UIView) {
        if UserCenter.shared.isLogin() {
            let profileVC = HWProfileViewController.init(NSNumber(value: UserCenter.shared.userId!))
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
        }else{
            presentLogin()
        }
    }
    
    func didTapedHeader(view: UIView) {
        if UserCenter.shared.isLogin() {
            // 如果已登录去资料编辑页
            let vc =  HWMaterialEditingViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }else{
            presentLogin()
        }
    }
    
    func didTapedDetail(tag: Int) {
        switch tag {
        case 0:
           let c = HWMyFViewController(.follow)
            c.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(c, animated: true)
        case 1:
            let c = HWMyFViewController(.fan)
            c.hidesBottomBarWhenPushed = true
             navigationController?.pushViewController(c, animated: true)
        case 2:
            let c = HWMyFViewController(.follow)
             //navigationController?.pushViewController(c, animated: true)
        case 3:
            let c = HWMyFViewController(.visit)
            c.hidesBottomBarWhenPushed = true
             navigationController?.pushViewController(c, animated: true)
            
        default:
            break
        }
    }
}
