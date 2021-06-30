//
//  HawaLoginViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class HawaPwdLoginViewController: HawaBaseViewController,LoginRegisterInputDelegate {
    
    var timer:Timer?
    var captcha:String?
    var agreementCheck: Bool = true
    lazy var completeBtn: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title:DYLOCS("Login") , image: nil, targte: self, action: #selector(onClick))
        b.backgroundColor = THEME_COLOR_RED
        b.titleWeight = .bold
        return b
    }()
    
    lazy var accountInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.backgroundColor = THEME_COLOR_RED_OPACITY
        a.maxLength = 12
        a.keyboardType = .numberPad
        return a
    }()
    lazy var pwdInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.backgroundColor = THEME_COLOR_RED_OPACITY
        a.delegete = self
        a.keyboardType = .default
        a.textInput.isSecureTextEntry = true
        return a
    }()
    lazy var mobileNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Input your account"))
        return l
    }()
    lazy var pwdNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Input your password") )
        return l
    }()
    lazy var titleIC: LRIcon = {
        let i = LRIcon.init(icon: UIImage(named: "ic_mobile_login"))
        i.backgroundColor = THEME_COLOR_RED
        return i
    }()
    lazy var titleLabel: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("Password login") 
        l.textColor = THEME_COLOR_RED
        l.font = UIFont.boldSystemFont(ofSize: 18)
        return l
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
    
    init(option:LoginViewControllerOption){
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(completeBtn)
        view.addSubview(accountInput)
        view.addSubview(pwdInput)
        view.addSubview(mobileNote)
        view.addSubview(pwdNote)
        view.addSubview(titleIC)
        view.addSubview(titleLabel)
        view.addSubview(agreementBtn)
        view.addSubview(checkBox)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = accountInput.becomeFirstResponder()
    }
    
    let VIEW_MARGINT = 27
    override func layoutConstrints() {
        
        titleIC.snp.makeConstraints { (m) in
            m.width.height.equalTo(63)
            m.topMargin.equalTo(44)
            m.leftMargin.equalTo(VIEW_MARGINT)
        }
        
        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleIC)
            m.left.equalTo(titleIC.snp.right).offset(15)
        }
        
        mobileNote.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT+3)
            m.top.equalTo(titleIC.snp.bottom).offset(40)
        }
        accountInput.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(45)
            m.top.equalTo(mobileNote.snp.bottom).offset(10)
        }
        
        pwdNote.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT+3)
            m.top.equalTo(accountInput.snp.bottom).offset(37)
        }
        
        pwdInput.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(45)
            m.top.equalTo(pwdNote.snp.bottom).offset(10)
        }
        
        completeBtn.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(63)
            m.bottom.equalTo(-SCREEN_HEIGHT*0.4)
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
    
    //去信息页
    @objc func onClick (button:UIButton)->Void {
        if !agreementCheck {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showInfo(withStatus: DYLOCS("You have to agree <Software Usage Protocol>"))
            return
        }
        
        if accountInput.text!.count <= 0 {
            SVProgressHUD.showError(withStatus: DYLOCS("account error"))
            return
        }

        if pwdInput.text!.count <= 0 {
            SVProgressHUD.showError(withStatus: DYLOCS("password error"))
            return
        }
        
        SVProgressHUD.show()
        
        UserCenter.shared.pwdLogin(accountInput.text!, pwd: pwdInput.text!) { (respond) in
            
            SVProgressHUD.dismiss()
            let rootVC = HawaTabBarController()
            AppDelegate.window.rootViewController = rootVC

        } fail: { (error) in
            SVProgressHUD.showError(withStatus: error.message)
        }

        self.view.endEditing(true)
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

}


