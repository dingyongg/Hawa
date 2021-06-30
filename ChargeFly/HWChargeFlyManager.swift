//
//  HWMessageManager.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/5.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON

class HWChargeFlyManager {
    
    var timer:Timer?
    
    let messageInitFrame = CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 0, width: SCREEN_WIDTH-HAWA_SCREEN_HORIZATAL_SPACE-HAWA_SCREEN_HORIZATAL_SPACE, height: 69)
    
    static let shared = HWChargeFlyManager()
    var flys:[JSON?] = []
    
    var duration:Int {
        get{
            return Int.random(in: 8...15)
        }
    }
    var durationRemain:Int = 0
    
    
    func startRun() -> Void {
        self.fetchData()
    }
    
    
    func fetchData() -> Void {
        UserCenter.shared.getChargeFlies { (respond) in
            self.flys = respond.array!
            self.startFly()
        } fail: { (error) in }
    }
    
    func fetchOne() -> JSON? {
        if flys.isEmpty {
            return nil
        }else{
            return flys.removeLast()
        }
    }
    
    func flyOne(_ user:JSON) -> Void {
        let fly = creatFly(user)
        self.prepareFly(fly)
        self.flingIn(fly)
    }
    
    func stopFly() -> Void {
        self.timer?.invalidate()
    }
    
    func startFly() -> Void {
        self.durationRemain = self.duration
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    @objc func countDown(_ timer: Timer) -> Void {
        durationRemain -= 1
        if self.durationRemain <= 0 {
            self.fetchAndFly()
            self.durationRemain = self.duration
        }
    }
    
    func fetchAndFly() -> Void {
        let one:JSON? = self.fetchOne()
        if one != nil {
            flyOne(one!)
        }else{
            self.stopFly()
            self.fetchData()
        }
    }
    
    
    private init() {}
    
    
    func creatFly(_ data:JSON?) -> HWChargeFlyView {
        return HWChargeFlyView.init(data)
    }
    func prepareFly(_ fly:HWChargeFlyView) -> Void {
        fly.origin = CGPoint.init(x: SCREEN_WIDTH, y: HAWA_NAVI_HEIGHT)
    }
    func flingIn(_ fly:HWChargeFlyView) -> Void {
        UIView.window().addSubview(fly)
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: .calculationModeDiscrete) {
            fly.x = HAWA_SCREEN_HORIZATAL_SPACE
        } completion: { (finish) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.2) {
                self.flingOut(fly)
            }
        }
    }
    
    func flingOut(_ fly:HWChargeFlyView) -> Void {

        UIView.animate(withDuration: 0.5) {
            fly.x = -fly.width
        } completion: { (finish) in
            self.clearFly(fly)
        }
    }
    func clearFly(_ fly:HWChargeFlyView) -> Void {
        fly.removeFromSuperview()
    }
}
