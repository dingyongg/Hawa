//
//  HWWalletViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWWalletViewController: HWBaseTableViewController {

    var diamondPrices: JSON? = []
    
    lazy var diamondL: UILabel = {
        let l = UILabel.init()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        return l
    }()
    
    
    lazy var headerV: UIView = {
        
        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 200))
        
        let backImg = UIImageView.init(image: UIImage.init(named: "bg_wallet"))
        backImg.frame = v.bounds
        
        v.addSubview(backImg)
        
        let dia = UIImageView.init(image: UIImage.init(named: "ic_diamond"))
    
        v.addSubview(dia)
        dia.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 35, height: 36))
            m.centerX.equalToSuperview()
            m.topMargin.equalTo(25)
        }
        
        v.addSubview(diamondL)
        
        diamondL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(dia.snp.bottom).offset(10)
        }
        
        return v
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = DYLOCS("My Wallet")
        tableView.register(UINib.init(nibName: "HWDiamondTableViewCell", bundle: nil), forCellReuseIdentifier: ID_DIAMOND_PAYMENT_TABLE_CELL)
        tableView.tableHeaderView = headerV
        tableView.separatorStyle = .none

            self.diamondPrices = HWDiamondModel.shared.productsData
            self.tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDiamond()
    }
    
    func getDiamond() -> Void {
        UserCenter.shared.diamondAmount { (respond) in
            self.diamondL.text = String( respond["number"].int ?? 0)
        } fail: { (erro) in
            SVProgressHUD.showError(withStatus: erro.message)
        }
    }
    
}



extension HWWalletViewController{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let p = self.diamondPrices![indexPath.row]
        
        let dp = HWDiamendProduct.init(p)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        UserCenter.shared.creatPaymentOrder(id: dp.id!, type: 3) { (resp) in
            
            HWInPurchase.shared.purchase(dp, orderId: resp["orderNumber"].string!) { (product) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showSuccess(withStatus: DYLOCS("Transaction completed") )
                self.getDiamond()
            } fail: { (error) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showError(withStatus: error.message)
            }

        } fail: { (error) in
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ID_DIAMOND_PAYMENT_TABLE_CELL, for: indexPath) as! HWDiamondTableViewCell
        let p = self.diamondPrices![indexPath.row]
        
        cell.numL.text = String(p["number"].int!)
    
        cell.priL.text = p["amount"].string
        
        return cell

    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.diamondPrices!.array!.count
    }
    
}
