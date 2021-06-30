//
//  HWSnowView.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/11.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit

class HWSnowingView: UIView {
    
    var timer: Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .black
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(generatorSnow) , userInfo: nil, repeats: true)
    }
    
   @objc func generatorSnow() -> Void {
        let x = CGFloat.random(in: 15..<SCREEN_WIDTH-15 )
        let size =  CGFloat.random(in: 5..<20)
        let f = CGRect.init(x: x, y: self.frame.height, width: size, height:size)
        let snow = HWSown.init(frame: f)
        self.addSubview(snow)
        snow.rise()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class HWSown: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            let alpha = CGFloat.random(in: 0.5..<1)
            backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: alpha)
            self.layer.cornerRadius = height/2
        }

        func rise() -> Void {
            
            let inter = CGFloat.random(in: 13..<17)

            if self.width < 13{
                UIView.animate(withDuration: TimeInterval(inter)) {
                    self.y -= self.superview!.height
                    self.size = CGSize.init(width: self.width-10, height: self.height-10)
                    self.layer.cornerRadius = self.size.width/2
                } completion: { (fin) in
                    self.removeFromSuperview()
                }

                let delay =  TimeInterval(inter)-2
                UIView.animate(withDuration: 2, delay: delay , options: UIView.AnimationOptions.curveLinear) {
                    self.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.0)
                } completion: { (fin) in
                }

            }else{
                UIView.animate(withDuration: TimeInterval(inter)) {
                    self.y -= self.superview!.height
                    self.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.0)
                    self.size = CGSize.init(width: self.width-10, height: self.height-10)
                    self.layer.cornerRadius = self.size.width/2
                    
                } completion: { (fin) in
                    self.removeFromSuperview()
                }
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        
    }
    
    
    
}
