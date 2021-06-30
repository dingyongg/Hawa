//
//  HWMemberShipModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/2/26.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWMemberShipModel: NSObject {
    
    @objc static let shared: HWMemberShipModel = HWMemberShipModel()
    
    var products:[HWVIPProduct]?
    var privilege:JSON?
    var productsData:JSON?{
        didSet{
            if productsData != nil {
                products = []
                for i in 0..<productsData!.array!.count {
                    let product = productsData![i] as JSON
                    products!.append(HWVIPProduct.init(product))
                }
            }
        }
    }
    
    /// 会员价格  会员支付信息
    func memberShipPrice( success: @escaping (JSON)->Void, fail: @escaping HWHomeViewModelFail) -> Void {
        let params = [
            "channel":HW_CHANNEL_ID,
            "userId":UserCenter.shared.userId!,
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_MEMBER_PRICE, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func loadProduct () -> Void {
        
//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        self.memberShipPrice { (respond) in
//            SVProgressHUD.setDefaultMaskType(.none)
//            SVProgressHUD.dismiss()
            self.productsData =  respond["payPageInfo"]
            self.privilege = respond["context"]
        } fail: { (error) in
//            SVProgressHUD.setDefaultMaskType(.none)
//            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
}
