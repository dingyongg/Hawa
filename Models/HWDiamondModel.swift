//
//  HWDiamondModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/2/26.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWDiamondModel: NSObject {
    /// 钻石信息
    
    @objc static let shared: HWDiamondModel = HWDiamondModel()
    var products:[HWDiamendProduct]?
    var productsData:JSON?{
        didSet{
            if productsData != nil {
                products = []
                for i in 0..<productsData!.array!.count {
                    let product = productsData![i] as JSON
                    products!.append(HWDiamendProduct.init(product))
                }
            }
        }
    }
    
    func diamondPayInfo( success: @escaping (JSON)->Void, fail: @escaping HWHomeViewModelFail) -> Void {
        let params = [
            "channel":HW_CHANNEL_ID,
            "userId":UserCenter.shared.userId!,
            "appVersion": DYDeviceInfo.APP_BUILD_VERSION
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_DIAMEND_PAY_INFO, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func loadProduct () -> Void {
//        SVProgressHUD.setDefaultMaskType(.clear)
//        SVProgressHUD.show()
        self.diamondPayInfo { (respond) in
//            SVProgressHUD.setDefaultMaskType(.none)
//            SVProgressHUD.dismiss()
            self.productsData =  respond["diamondConfigList"]
        } fail: { (error) in
//            SVProgressHUD.setDefaultMaskType(.none)
//            SVProgressHUD.showError(withStatus: error.message)
        }
    }
}
