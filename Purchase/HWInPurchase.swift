//
//  HWInPurchase.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/11.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyJSON



typealias HWInPurchaseSuccessCallBack =  (HWProduct) -> Void
typealias HWInPurchaseFailCallBack = (HawaError) -> Void


class HWInPurchase: NSObject {
    
    var succ: HWInPurchaseSuccessCallBack?
    var fail: HWInPurchaseFailCallBack?
    var prod: HWProduct?
    var orderId: String?
    static let shared: HWInPurchase = HWInPurchase()
    
    var products: [String:SKProduct] = [:]
    
    func purchase(_ pro: HWProduct, orderId: String, succ: @escaping HWInPurchaseSuccessCallBack, fail: @escaping HWInPurchaseFailCallBack) -> Void {
        self.orderId = orderId
        self.succ = succ
        self.fail = fail
        self.prod = pro
        
        if authPurchase() {
            let request = SKProductsRequest.init(productIdentifiers: [pro.productId!])
            request.delegate = self
            request.start()
        }else{
            
            let e = HawaError.init(code: -1, message:DYLOCS("Permision denied"))
            fail(e)
        }
    }
    
    
    func authPurchase () -> Bool  {
        return SKPaymentQueue.canMakePayments()
    }
    
    
    
}

extension HWInPurchase: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for trans in transactions {
            switch trans.transactionState {
            case SKPaymentTransactionState.purchased : //交易完成
                
                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                    
                    do {
                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                        let receiptString = receiptData.base64EncodedString(options: [])
                        let pro = products[trans.payment.productIdentifier]
                        /// 事件统计
                        if (trans.payment.productIdentifier.firstIndex(of: "v") != nil)  {
                            KVATracker.shared.identityLink.register(withNameString: trans.payment.productIdentifier, identifierString: String(UserCenter.shared.userId!))
                            let event = KVAEvent(type: .subscribe)
                            event.priceDecimalNumber = pro?.price
                            event.nameString = pro?.localizedTitle
                            event.currencyString = ""
                            event.appStoreReceiptBase64EncodedString = receiptString
                            event.send()
                        }else{
                            let event = KVAEvent(type: .purchase)
                            event.appStoreReceiptBase64EncodedString = receiptString
                            event.priceDecimalNumber = pro?.price
                            event.nameString = pro?.localizedTitle
                            event.send()
                        }

                        UserCenter.shared.paymentVerify(orderNumber:self.orderId! , receipt: receiptString) { (res) in
                            self.succ!(self.prod!)
                        } fail: { (err) in
                            self.fail!(err)
                        }
                    }
                    catch {
                        let e = HawaError.init(code: -1, message:DYLOCS("Couldn't read receipt"))
                        self.fail!(e)
                    }
                }else{
                    let e = HawaError.init(code: -1, message:DYLOCS("Couldn't read receipt"))
                    self.fail!(e)
                }
                
                SKPaymentQueue.default().finishTransaction(trans)
                break
            case SKPaymentTransactionState.failed ://交易失败
                let e = HawaError.init(code: -1, message:DYLOCS("Transaction failed, please try again"))
                self.fail!(e)
                SKPaymentQueue.default().finishTransaction(trans)
                
                break
            case SKPaymentTransactionState.restored : //已经购买过该商品
                SKPaymentQueue.default().finishTransaction(trans)
                let e = HawaError.init(code: -1, message:DYLOCS("Purchased"))
                self.fail!(e)
                SKPaymentQueue.default().finishTransaction(trans)
                
                break
            case SKPaymentTransactionState.purchasing :  //商品添加进列表
                debugPrint(trans, "purchasing")
                break
            case SKPaymentTransactionState.deferred :
                print("SKPaymentTransactionState.deferred ")
                break
                
            default: break
                
            }
        }
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            let payment: SKPayment = SKPayment.init(product: response.products.first!)
            SKPaymentQueue.default().add(payment)
            SKPaymentQueue.default().add(self)
            
            let pro: SKProduct = response.products.first!
            self.products[pro.productIdentifier] = pro
            
        }else{
            let e = HawaError.init(code: -1, message:DYLOCS("Product dosen't exist"))
            self.fail!(e)
        }
    }
    
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        let e = HawaError.init(code: -1, message:error.localizedDescription)
        self.fail!(e)
        
    }
    
}
