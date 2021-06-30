//
//  HWLuckyTable.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/28.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWLuckyTable: UIView {
    
    
    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer.init(layer: self.layer)
        gradient.startPoint = CGPoint.init(x: 0, y: 0)
        gradient.endPoint = CGPoint.init(x: 0, y: 1)
        gradient.colors = [COLORFROMRGB(r: 208, 245, 199, alpha: 1).cgColor,COLORFROMRGB(r: 208, 245, 199, alpha: 0).cgColor ]
        gradient.frame = self.bounds
        return gradient
    }()
    
    
    lazy var luckyT: LuckyTitle = {
        let t = LuckyTitle.init(frame: CGRect.init(x: 30, y: 20, width: SCREEN_WIDTH-60, height: 120))
        return t
    }()
    
    lazy var luckyPan: LuckyTurn = {
        let t = LuckyTurn.init(frame: CGRect.init(x: 30, y:luckyT.y+luckyT.height+30 , width: SCREEN_WIDTH-60, height: SCREEN_WIDTH-45))
        return t
    }()
    
    lazy var bottomBg: UIImageView = {
        let iv = UIImageView.init(frame: .zero)
        iv.image = UIImage.init(named: "bg_grass")
        return iv
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(gradient)
        addSubview(luckyT)
        addSubview(luckyPan)
        addSubview(bottomBg)
        
        bottomBg.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.height.equalTo(140)
        }
        
        SVProgressHUD.show()
        UserCenter.shared.luckyInfo { (res) in
            SVProgressHUD.dismiss()
            self.luckyT.timeLeft = res["remainNumber"].int!
        } fail: { (erro) in
            SVProgressHUD.showError(withStatus: erro.message)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class LuckyTitle: UIView {
        
        var timeLeft = 0{
            didSet{
                subTitle.text =  String(timeLeft) + " times left"
            }
        }
        
        lazy var bg: UIImageView = {
            let iv = UIImageView.init(frame: self.bounds)
            iv.image = UIImage.init(named: "bg_lucky_title")
            return iv
        }()
        
        
        lazy var title: UILabel = {
            let l = UILabel.init()
            l.text = "Daily draw"
            l.textColor = .white
            l.font = UIFont.systemFont(ofSize: 31, weight: .semibold)
            return l
        }()
        
        lazy var subTitle: UILabel = {
            let l = UILabel.init()
            l.textColor = .white
            l.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            return l
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(bg)
            addSubview(title)
            addSubview(subTitle)

            title.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.topMargin.equalTo(20)
            }
            subTitle.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(title.snp.bottom).offset(10)
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class LuckyTurn: UIView{
        
        var goBtn: UIButton? = nil
        
        let rewardInfos = [
            [
                "icon":"ic_diamond_few",
                "value":"2x",
                "type":1
            ],
            [
                "icon":"ic_phone_fragments",
                "value":"1x",
                "type":2
            ],
            [
                "icon":"ic_diamond_some",
                "value":"3x",
                "type":1
            ],
            [
                "icon":"ic_phone_fragments",
                "value":"2x",
                "type":2
            ],  [
                "icon":"ic_diamonds_lot",
                "value":"5x",
                "type":1
            ],  [
                "icon":"ic_phone_fragments",
                "value":"5x",
                "type":2
            ],
            [
                "icon":"ic_diamonds_huge",
                "value":"10x",
                "type":1
            ],
            [
                "icon":"ic_phone_fragments",
                "value":"10x",
                "type":2
            ]
        ]
        
        private var _currentIndex = 0
        
        var gotIndex: Int = -1
        
        var timer: Timer?
        var count:Int = 30 //刷新的次数
        
        var currentIndex: Int{
            set{_currentIndex = newValue%8 }
            get{ return _currentIndex }
        }
        
        var itemArray: [LuckyTurnItem?] = Array.init(repeating: nil, count: 8)
        
        lazy var bg: UIImageView = {
            let iv = UIImageView.init(frame: self.bounds)
            iv.image = UIImage.init(named: "bg_lucky_pan")
            return iv
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(bg)
            
            let space = 5
            let edg = 30
            let totalW = Int( self.width )-edg-edg-space-space
            let itemW = totalW/3
            for i in 0..<9 {
                if i != 4 {
                    let item = LuckyTurnItem.init(frame: CGRect.init(x: edg + (itemW + space) * Int(CGFloat(i%3))  , y: edg+Int(i/3)*(itemW+space+1), width: itemW, height: itemW))
                    addSubview(item)
                    switch i {
                    case 0,1,2:
                        itemArray[i] = item
                    case 3:
                        itemArray[7] = item
                    case 5:
                        itemArray[3] = item
                    case 6:
                        itemArray[6] = item
                    case 7:
                        itemArray[5] = item
                    case 8:
                        itemArray[4] = item
                    default:
                        break
                    }

                }else{
                    let item = LuckyGo.init(frame: CGRect.init(x: edg + (itemW + space) * Int(CGFloat(i%3))  , y: edg+Int(i/3)*(itemW+space+1), width: itemW, height: itemW), targe: self, action: #selector(go))
                    addSubview(item)
                }
                
            }
            
            for i in 0..<8 {
                let rewardInfo = rewardInfos[i]
                let item = itemArray[i]
                item?.icon = rewardInfo["icon"] as? String
                item?.note.text = rewardInfo["value"] as? String
                item?.type = rewardInfo["type"] as? Int

            }
        }
        
        @objc func go(_ sender: UIButton) -> Void {
            self.goBtn = sender
            sender.isEnabled = false
            
            let sup = self.superview as! HWLuckyTable
            if  sup.luckyT.timeLeft <= 0 {
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showInfo(withStatus: DYLOCS("Ops!, no chances, try tomorrow"))
                sender.isEnabled = true
                return
            }
        
            UserCenter.shared.luckyGo { (res) in
                self.gotIndex = res["index"].int!
                print(res)
                
                let sup = self.superview as! HWLuckyTable
                sup.luckyT.timeLeft -= 1
                
                
            } fail: { (err) in
                SVProgressHUD.showError(withStatus: err.message)
                self.timer?.invalidate()
                self.timer = nil
                self.count = 50
                self.gotIndex = -1
                self.currentIndex = 0
                sender.isEnabled = true
                
            }

            timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(gotRefresh), userInfo: nil, repeats: true)

        }
        
        @objc func gotRefresh() -> Void {
                        
            for i in 0..<8 {
                
                let item = itemArray[i]
                if i == currentIndex {
                    item?.got = true

                    if gotIndex == -1 || self.count>0 {
                        
                    }else{
                        
                        if currentIndex  == gotIndex {
                                
                            self.showTo(item!)
//                            if item?.type == 1 {
//                                SVProgressHUD.showSuccess(withStatus: "Congratulations! \n  You'v got diamonds " + (item?.note.text)!  )
//                            }else{
//                                SVProgressHUD.showSuccess(withStatus: "Congratulations! \n  You'v got phone fragments " + (item?.note.text)!  )
//                            }
                            
                            timer?.invalidate()
                            timer = nil
                            self.count = 50
                            self.gotIndex = -1
                            self.currentIndex = 0
                            
                            
                        }
                    }

                }else{
                    item?.got = false
                }
            }
            
            self.currentIndex += 1
            self.count -= 1
        }

        func showTo(_ item:LuckyTurnItem) -> Void {
            let originFrame = item.frame
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                item.got = false
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.6) {
                item.got = true
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.7) {
                item.got = false
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.8) {
                item.got = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.9) {
                item.got = false
            }
            
            self.bringSubviewToFront(item)
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                for i in self.itemArray {
                    
                    if i == item {
                        continue
                    }else{
                        UIView.animate(withDuration: 0.8) {
                            i?.backgroundColor = THEME_PLACEHOLDER_COLOR
                        }
                    }
                   
                }
            }
            
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
                item.size = CGSize.init(width: SCREEN_WIDTH/2, height: SCREEN_WIDTH/2)
                item.center = self.bg.center
            } completion: { (fi) in
                
                self.shakeAshake(item)
                
                self.goBtn?.isEnabled = true
                item.countFrom(3) { () -> (Void) in
                    
                    
                    for i in self.itemArray {
                        if i == item {
                            continue
                        }else{
                            UIView.animate(withDuration: 0.8) {
                                i?.backgroundColor = .white
                            }
                        }
                    }
                    
                    
                    UIView.animate(withDuration: 1) {
                        item.frame = originFrame
                    }
                }
            }
        }
        
        func shakeAshake(_ view: UIView) {
            
            let animati = CAKeyframeAnimation(keyPath: "transform.rotation")
            // rotation 旋转，需要添加弧度值
            // 角度转弧度
            animati.values = [angle2Radion(angle: -50), angle2Radion(angle: 50), angle2Radion(angle: -50)]
            animati.repeatCount = 2
            
            view.layer.add(animati, forKey: nil)
        }
        func angle2Radion(angle: Float) -> Float {
            return angle / Float(180.0 * Double.pi)
        }
    
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        class LuckyTurnItem: UIView {
            
            var type: Int? = 1
            var timer: Timer? = nil
            lazy var gotLayer: CALayer = {
                let innerShadow = CALayer()
                innerShadow.frame = bounds
                // Shadow path (1pt ring around bounds)
                let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: 10, dy: 10), cornerRadius: 15)
                let cutout = UIBezierPath(rect:  CGRect.init(x: -5, y: -5, width: innerShadow.frame.width+10, height: innerShadow.frame.height+10)).reversing()
                path.append(cutout)
                innerShadow.shadowPath = path.cgPath
                innerShadow.masksToBounds = true
                // Shadow properties
                innerShadow.shadowColor = COLORFROMRGB(r: 115, 255, 57, alpha: 1).cgColor
                innerShadow.shadowOffset = CGSize(width: 0, height: 0)
                innerShadow.shadowOpacity = 0.7
                return innerShadow
            }()
            
            var got: Bool = false{
                didSet{
                    if got {
                        layer.addSublayer(gotLayer)
                    }else{
                        gotLayer.removeFromSuperlayer()
                    }
                }
            }
            
            lazy var countDownL: UILabel = {
                let l = UILabel()
                l.textColor = THEME_SUB_CONTEN_COLOR
                l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                return l
            }()
            
            var icon: String?{
                didSet{
                    i.image = UIImage.init(named: icon!)
                }
            }
            
            lazy var i:  UIImageView = {
                let iv = UIImageView.init(frame: .zero)
                iv.contentMode = .scaleAspectFit
                return iv
            }()
            
            lazy var note: UILabel = {
                let l = UILabel.init()
                l.textColor = COLORFROMRGB(r: 255, 195, 47, alpha: 1)
                l.font = UIFont.systemFont(ofSize: 19, weight: .regular)
                return l
            }()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                backgroundColor = .white
                addSubview(i)
                addSubview(note)
                addSubview(countDownL)
                
                i.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.topMargin.equalTo(15)
                    m.rightMargin.equalTo(-20)
                    m.leftMargin.equalTo(20)
                }
                
                note.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.top.equalTo(i.snp.bottom)
                    m.height.equalTo(20)
                    m.bottomMargin.equalTo(-15)
                    
                }
                
                countDownL.snp.makeConstraints { (m) in
                    m.bottomMargin.equalTo(-6)
                    m.rightMargin.equalTo(-10)
                }
                
                layer.cornerRadius = 15
                layer.masksToBounds = true
                
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            
            
            func countFrom(_ from: Int, done: (()->(Void))? ) -> Void {
                var starFrom = from
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                    self.countDownL.text = String(starFrom) + "s"
                    if starFrom <= 0{
                        self.countDownL.text = ""
                        timer.invalidate()
                        self.timer = nil
                        done?()
                    }
                    starFrom -= 1
                }
            }
        }
        
        
        class LuckyGo: UIView {
            
            lazy var actionBtn: UIButton = {
                let b = UIButton.init(frame: self.bounds)
                b.setBackgroundImage(UIImage.init(named: "ic_start_lucky") , for: .normal)
                b.setTitle( DYLOCS("GO") , for: .normal)
                b.setTitleColor(COLORFROMRGB(r: 255, 182, 0, alpha: 1), for: .normal)
                b.titleLabel?.font = UIFont.systemFont(ofSize: 31, weight: .semibold)
                b.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 6, right: 0)
                return b
            }()
            
            init(frame: CGRect, targe:Any?,  action: Selector) {
                
                super.init(frame: frame)
                layer.cornerRadius = 15
                layer.masksToBounds = true
                
                addSubview(actionBtn)
                actionBtn.addTarget(targe, action: action, for: .touchUpInside)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
        }
    }
    
}
