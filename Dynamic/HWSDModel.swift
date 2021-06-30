//
//  HWDynamicModel.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/1.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON


typealias HWShortVideoSuccess =  (JSON) -> Void
typealias HWMatchSuccess =  (JSON) -> Void
typealias HWDynamicSuccess =  ([HWDynamicsModel]) -> Void
typealias HWSDModelFail = (HawaError) -> Void


class HWSDModel {
    
    var currentShortVideoPage = 0
    var currentDynamicPage = 0
    var shortVideoData: JSON? = []
    var dynamicModels: [HWDynamicsModel] = []

    
    static let shared = HWSDModel()
    
    private init() {}
    
    func shortVideoRefresh(_ success: @escaping HWShortVideoSuccess, fail: @escaping HWSDModelFail ) -> Void {
        
        let params = [
            "userId" : UserCenter.shared.userId! as Any,
            "pageNo":currentDynamicPage,
            "pageSize": 20
        ] as [String: Any]
        
        HawaNetWork.shared?.get(url: URL_SHORT_VIDEO_LIST, params: params, success: { (respond) in

            self.shortVideoData = respond["result"]
            success(self.shortVideoData!)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func shortVideoLoadMore(_ success: @escaping HWShortVideoSuccess, fail: @escaping HWSDModelFail ) -> Void {
        currentDynamicPage =  currentDynamicPage + 1
        let params = [
            "userId" : UserCenter.shared.userId! as Any,
            "pageNo":currentDynamicPage,
            "pageSize": 20
        ] as [String: Any]
        
        HawaNetWork.shared?.get(url: URL_SHORT_VIDEO_LIST, params: params, success: { (respond) in
            do {
                try  self.shortVideoData!.merge(with: respond["result"])
            } catch {
                print("merge fail")
            }
            success(self.shortVideoData!)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    
    func dynamicRefresh(_ success: @escaping HWDynamicSuccess, fail: @escaping HWSDModelFail ) -> Void {
        
        let params = [
            "userId" : UserCenter.shared.userId! as Any,
            "pageNo":currentDynamicPage,
            "pageSize": 20
        ] as [String: Any]
        
        HawaNetWork.shared?.get(url: URL_DYNAMIC_LIST, params: params, success: { (respond) in
            print(respond)
            self.dynamicModels = []
            
            for i in 0..<respond["result"].count {
                let dy =  respond["result"][i]
                let dyM = HWDynamicsModel.init(dy)
                self.dynamicModels.append(dyM)
            }
            
            success(self.dynamicModels )
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func dynamicLoadMore(_ success: @escaping HWDynamicSuccess, fail: @escaping HWSDModelFail ) -> Void {
        currentDynamicPage =  currentDynamicPage + 1
        let params = [
            "userId" : UserCenter.shared.userId! as Any,
            "pageNo":currentDynamicPage,
            "pageSize": 20
        ] as [String: Any]
        
        HawaNetWork.shared?.get(url: URL_DYNAMIC_LIST, params: params, success: { (respond) in
            
            for i in 0..<respond["result"].count {
                let dy =  respond["result"][i]
                let dyM = HWDynamicsModel.init(dy)
                self.dynamicModels.append(dyM)
            }
            
            success(self.dynamicModels)
        }, failure: { (error) in
            fail(error)
        })
    }
    
    func matching(_ success: @escaping  HWMatchSuccess, fail: @escaping  HWSDModelFail) -> Void {
        
        let params = [
            "userId":UserCenter.shared.userId! ,
        ] as [String : Any]
        
        HawaNetWork.shared?.post(url: URL_USER_MATCH, params: params, success: { (respond) in
            success(respond)
        }, failure: { (error) in
            fail(error)
        })
        
    }
    
    
}
