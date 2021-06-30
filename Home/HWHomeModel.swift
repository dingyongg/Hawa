//
//  HWHomeViewModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/30.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias HWHomeViewModelSuccess =  ([UserModel]) -> Void
typealias HWHomeViewModelFail = (HawaError) -> Void

class HWHomeModel: NSObject {
    
   @objc static let shared:HWHomeModel = HWHomeModel()
    
    var pageSize: Int = 20
    var currentPage: Int = 0
    
    
    
    var dataList: [JSON] = []
    var modelList: [UserModel] = []
    
    var freeList: [UserModel] = []

    override init() {
        super.init()
    }
    
    func refresh(_ countryCode:String?, success:@escaping HWHomeViewModelSuccess, fail: @escaping HWHomeViewModelFail) -> Void {
        currentPage = 0
        let params = [
            "pageNo":currentPage ,
            "pageSize":pageSize,
            "type":1,
            "userId":UserCenter.shared.userId!,
            "countryCode":countryCode ?? "IND"
        ] as [String : Any]
        
        modelList = []
        HawaNetWork.shared?.post(url: URL_HOME_LIST, params: params, success: { (respond) in
            for i in respond["result"].array! {
                self.modelList.append(UserModel.init(dataSource: i))
            }
            if(countryCode == "IND"){
                self.freeList = self.modelList
            }
            success(self.modelList)
        }, failure: { (error) in
            fail(error)
          
        })
    }
    
    func loadMore(_ countryCode:String?, success:@escaping HWHomeViewModelSuccess, fail: @escaping HWHomeViewModelFail) -> Void {
        currentPage = currentPage + 1
        let params = [
            "pageNo":currentPage,
            "pageSize": pageSize,
            "type":1,
            "userId":UserCenter.shared.userId!,
            "countryCode":countryCode ?? "IND"
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_HOME_LIST, params: params, success: { (respond) in
            for i in respond["result"].array! {
                self.modelList.append(UserModel.init(dataSource: i))
            }
            success(self.modelList)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    ///获取用户信息
    func loadDetail(_ id: Int, success: @escaping (JSON)->Void, fail: @escaping HWHomeViewModelFail ) -> Void {
        let params = [
            "seeId":UserCenter.shared.userId!,
            "userId":id
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_USER_DETAIL, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
    
    }
    
    @objc func loadDetail(_ id: NSNumber, success: @escaping (_ respond: NSDictionary)->Void, fail: @escaping HWHomeViewModelFail ) -> Void {
        let params = [
            "seeId":UserCenter.shared.userId!,
            "userId":id
        ] as [String : Any]
        
        HawaNetWork.shared?.get(url: URL_USER_DETAIL, params: params, success: { (respond) in
            let info =  respond.dictionaryObject
            success(info! as NSDictionary)
        }, failure: { (error) in
            fail(error)
        })
    
    }
    
    

}
