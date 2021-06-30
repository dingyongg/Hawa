//
//  HawaLoginRegisteMainControllerViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/4.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HawaLoginRegisteMainController: HawaBaseViewController {
    
    var agreementCheck: Bool = true

    lazy var waveView: GLWaveView = {
        
        let waveV = GLWaveView.init(frame: CGRect.init(x:0, y: SCREEN_HEIGHT*0.13, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        let waveA = GLWave.default()
        
        waveA!.offsetX = 0;
        waveA!.offsetY = 240;
        waveA!.height  = 13;
        waveA!.width   = SCREEN_WIDTH;
        waveA!.speedX  = 0.2;
        waveA!.fillColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.55).cgColor
        
        let waveB = GLWave.default()
        waveB!.offsetX = 0;
        waveB!.offsetY = 240;
        waveB!.height  = 13;
        waveB!.width   = SCREEN_WIDTH;
        waveB!.speedX  = 0.5;
        waveB!.fillColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.35).cgColor
        
        let waveC = GLWave.default()
        waveC!.offsetX = 0;
        waveC!.offsetY = 240;
        waveC!.height  = 13;
        waveC!.width   = SCREEN_WIDTH;
        waveC!.speedX  = 1;
        waveC!.fillColor = COLORFROMRGB(r: 255, 255, 255, alpha: 0.15).cgColor

        waveV.addWave(waveA)
        waveV.addWave(waveB)
        waveV.addWave(waveC)
        return waveV
    }()
    
    lazy var snowV: HWSnowingView = {
        let v = HWSnowingView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT/4+logoIV.height/2, width: SCREEN_WIDTH, height: 150))
        return v
    }()
    
    lazy var whiteBg: UIView = {
        let v = UIView.init(frame: CGRect.init(x: 0, y: waveView.y+250, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-waveView.y-100))
        v.backgroundColor = .white
        
        let g = CAGradientLayer.init()
        g.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 50)
        g.colors = [
            THEME_COLOR_RED.cgColor,
            UIColor.white.cgColor
        ]
        g.startPoint = CGPoint.init(x: 0, y: 0)
        g.endPoint = CGPoint.init(x: 0, y: 1)
        v.layer.addSublayer(g)
        return v
    }()
    
    
    lazy var backgroundIV: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "bg_login"))
        return iv
    }()
    
    lazy var logoIV: HWLogo = {
        let iv = HWLogo.init(frame: CGRect.init(x: 0, y: 0, width: 140, height: 120))
        iv.centerX = self.view.centerX
        iv.centerY = SCREEN_HEIGHT/4
        return iv
    }()
    
    
    lazy var  quickLoginBtn : HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: DYLOCS("QuickLogin") , image: UIImage.init(named: "ic_quick_login"), targte: self, action: #selector(onLoginClick))
        b.backgroundColor = THEME_COLOR_YELLOW
        return b
    }()
    
    
    lazy var pswLoginBtn : HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: DYLOCS("PasswordLogin") , image: UIImage.init(named: "ic_pwd_login"), targte: self, action: #selector(onPwdLoginClick))
        b.backgroundColor = THEME_COLOR_BLUE
        return b
    }()
    
    lazy var mobileLoginBtn: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: DYLOCS("Register") , image: UIImage.init(named: "ic_mobile_login"), targte: self, action: #selector(onRegisterClick))
        b.backgroundColor = THEME_COLOR_RED
        return b
    }()
    
    lazy var agreementBtn: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setTitle(DYLOCS("Software Usage Protocol"), for: .normal)
        b.titleLabel!.font = UIFont.systemFont(ofSize: 13)
        b.setTitleColor(THEME_COLOR_RED, for: .normal)
        b.addTarget(self, action: #selector(agreementClick), for: .touchUpInside)
        return b
    }()
    
    lazy var checkBox: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setImage(UIImage.init(named: "ic_checkbox_true"), for: .normal)
        b.addTarget(self, action: #selector(checkBoxClick), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = THEME_COLOR_RED
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(logoIV)
        view.addSubview(whiteBg)
        view.addSubview(snowV)
        view.addSubview(waveView)
        view.addSubview(agreementBtn)
        view.addSubview(quickLoginBtn)
        view.addSubview(pswLoginBtn)
        view.addSubview(mobileLoginBtn)
        view.addSubview(checkBox)
        view.bringSubviewToFront(logoIV)
        _ = setUserDefault("Software Usage Protocol", value:"true")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.waveView.startWaveAnimate()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.waveView.stopWaveAnimate()
    }
    override func layoutConstrints() {
        
        quickLoginBtn.snp.makeConstraints { (m) in
            m.height.equalTo(57)
            m.rightMargin.equalTo(-30)
            m.leftMargin.equalTo(30)
            m.bottom.equalTo(pswLoginBtn.snp.top).offset(-30)
        }
        pswLoginBtn.snp.makeConstraints { (m) in
            m.height.equalTo(57)
            m.rightMargin.equalTo(-30)
            m.leftMargin.equalTo(30)
            m.bottom.equalTo(mobileLoginBtn.snp.top).offset(-30)
        }
        mobileLoginBtn.snp.makeConstraints { (m) in
            m.height.equalTo(quickLoginBtn)
            m.width.equalTo(quickLoginBtn)
            m.centerX.equalTo(quickLoginBtn)
            m.bottomMargin.equalTo(-SCREEN_HEIGHT/8*1)
        }
        agreementBtn.snp.makeConstraints { (m) in
            m.bottomMargin.equalTo(-15)
            m.centerX.equalToSuperview()
        }
        checkBox.snp.makeConstraints { (m) in
            m.centerY.equalTo(agreementBtn)
            m.right.equalTo(agreementBtn.snp.left).offset(-5)
            m.size.equalTo(CGSize.init(width: 15, height: 15))
        }
        
    }
    
    
    @objc func onLoginClick (button:UIButton)->Void {
        
        if !agreementCheck {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showInfo(withStatus: DYLOCS("You have to agree <Software Usage Protocol>"))
            return
        }
        
        let loginVC = HawaMobileLoginViewController(option: .login)
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc func onPwdLoginClick (button:UIButton)->Void {
        if !agreementCheck {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showInfo(withStatus: DYLOCS("You have to agree <Software Usage Protocol>"))
            return
        }
        let VC = HawaPwdLoginViewController(option: .login)
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func onRegisterClick (button:UIButton)->Void {
        if !agreementCheck {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showInfo(withStatus: DYLOCS("You have to agree <Software Usage Protocol>"))
            return
        }
        let loginVC = HawaMobileLoginViewController(option: .register)
        navigationController?.pushViewController(loginVC, animated: true)
    }
    @objc func agreementClick(_ sender: UIButton) -> Void {
        let vc = HWWebViewController.init()
        vc.url = "http://api.tocamshow.com/app/agreement"
        vc.title = DYLOCS("Software use agreement")
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func checkBoxClick(_ sender: UIButton) -> Void {
        if agreementCheck {
            checkBox.setImage(UIImage.init(named: "ic_checkbox_false"), for: .normal)
            agreementCheck = false
        }else{
            checkBox.setImage(UIImage.init(named: "ic_checkbox_true"), for: .normal)
            agreementCheck = true
        }
    }
    
    
    deinit {
        self.logoIV.stop()
        self.waveView.stopWaveAnimate()
    }
    
}
