//
//  HWMemberCenterViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWMemberCenterViewController: HWBaseTableViewController {
    
    var membershipData: JSON?
    var privilege:JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = DYLOCS("Member Center")
        setNaviTitleColor(.white)
        setNaviTintColor(.white)
        setNaviBarBackgroundColor(COLORFROMRGB(r: 255, 181, 0, alpha: 1))
        navigationController?.setNavigationBarHidden(false, animated: true)
        isNavigationBarShadowHidden = true
        
        tableView.backgroundColor = .clear
        tableView.register(UINib.init(nibName: "HWMCPriceCell", bundle: nil), forCellReuseIdentifier: ID_MC_PRICE_TABLE_CELL)
        tableView.register(UINib.init(nibName: "HWMembershipPrivilegesCell", bundle: nil), forCellReuseIdentifier: ID_MC_PRIVILEGE_TABLE_CELL)
       
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 230))
        let bg = UIImageView(image: UIImage.init(named: "bg_member_center"))
        bg.frame = headerView.bounds
        bg.contentMode = .scaleToFill
        headerView.addSubview(bg)
        tableView.tableHeaderView = headerView
        tableView.showsVerticalScrollIndicator = false
        
        
        let chatItem = HeadViewItem.init(frame: .zero, image: "ic_member_chat")
        
        let vipItem = HeadViewItem.init(frame: .zero, image: "logo_vip_5")
        
        let videoItem = HeadViewItem.init(frame: .zero, image: "ic_member_video")
        
        headerView.addSubview(chatItem)
        headerView.addSubview(vipItem)
        headerView.addSubview(videoItem)
        
        vipItem.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview().offset(-15)
            m.centerX.equalToSuperview()
            m.width.equalTo(100)
            m.height.equalTo(100)
        }
        
        chatItem.snp.makeConstraints { (m) in
            m.width.equalTo(50)
            m.height.equalTo(50)
            m.centerY.equalTo(vipItem)
            m.right.equalTo(vipItem.snp.left).offset(-50)
        }
        videoItem.snp.makeConstraints { (m) in
            m.width.equalTo(50)
            m.height.equalTo(50)
            m.centerY.equalTo(vipItem)
            m.left.equalTo(vipItem.snp.right).offset(50)
        }
        
       
        self.membershipData = HWMemberShipModel.shared.productsData
        self.privilege = HWMemberShipModel.shared.privilege
        self.tableView.reloadData()
    }
    
    
    class HeadViewItem:UIView{
        
        init(frame: CGRect, image:String) {
            super.init(frame: frame)
            self.backgroundColor = .white
            let iv = UIImageView.init(image: UIImage.init(named: image))
            self.addSubview(iv)
            iv.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.centerX.equalToSuperview()
                m.margins.equalTo(15)
            }
        }
        
        override func layoutSubviews() {
            self.layer.cornerRadius = self.width/2
            self.layer.masksToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}





extension HWMemberCenterViewController{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            let nss = membershipData![indexPath.row]["explain"].string! as NSString
            
            let size = CGSize.init(width: SCREEN_WIDTH-59, height: 999)
            let arrs: [NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)  as Any
            ]
            
            let rect = nss.boundingRect(with:size, options: .usesLineFragmentOrigin, attributes: arrs, context: nil)

            return  rect.height + 50
        }else{
            
            let nss = self.privilege![indexPath.row].string! as NSString
            
            let size = CGSize.init(width: SCREEN_WIDTH-59, height: 999)
            let arrs: [NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)  as Any
            ]
            
            let rect = nss.boundingRect(with:size, options: .usesLineFragmentOrigin, attributes: arrs, context: nil)
  
            return rect.height + 20
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 50))
        let l: UILabel = UILabel.init(frame: v.bounds)
        l.x = 20
        v.addSubview(l)
        l.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        if section == 0 {
            l.text = "Membership Package"
            l.textColor = THEME_DARK_BG_COLOR
        }else{
            l.text = "Membership Package"
            l.textColor = COLORFROMRGB(r: 255, 181, 0, alpha: 1)
        }
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_MC_PRICE_TABLE_CELL, for: indexPath) as!
                HWMCPriceCell
            cell.data = membershipData?[indexPath.row]
            cell.buy = { p in
             
                let dp = HWVIPProduct.init(p)
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
                UserCenter.shared.creatPaymentOrder(id: (dp.id)!, type:1 ) { (respond) in
                    HWInPurchase.shared.purchase(dp, orderId: respond["orderNumber"].string!) { (p) in
                        SVProgressHUD.showSuccess(withStatus: DYLOCS("Transaction completed") )
                        SVProgressHUD.setDefaultMaskType(.none)
                        UserCenter.shared.refreshUserInfo()
                    } fail: { (e) in
                        SVProgressHUD.setDefaultMaskType(.none)
                        SVProgressHUD.showError(withStatus: e.message)
                    }
                } fail: { (error) in
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showError(withStatus: error.message)
                }

            }
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_MC_PRIVILEGE_TABLE_CELL, for: indexPath) as!
                HWMembershipPrivilegesCell
            cell.pri = self.privilege![indexPath.row].string
            return cell
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return membershipData?.array?.count ?? 0
        }else{
            return privilege?.array?.count ?? 0
        }
        
    }
    
    
    
}
