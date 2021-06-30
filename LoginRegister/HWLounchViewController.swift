//
//  HWLounchViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/2/25.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit

class HWLounchViewController: HawaBaseViewController, FSRegionViewDelegate, UITextFieldDelegate{
    
   
    
    func regionView(didSelected value: String) {
        regionB.setTitle("+"+value, for: .normal)
    }
    
    lazy var backgroundV: HWLunchBackgroundView = {
        let b = HWLunchBackgroundView.init(frame: view.bounds)
        return b
    }()
    
    lazy var logoIV: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "ic_hw_logo"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
//    lazy var mobileNote: UILabel = {
//        let l = UILabel.init()
//        l.text = DYLOCS("Input your mobile phone number")
//        l.font = UIFont.systemFont(ofSize: 16)
//        l.textColor = .white
//        l.textAlignment = .center
//        return l
//    }()
    
    lazy var regionB: RegionCodeBtn = {
        let b = RegionCodeBtn.init(frame: .zero, title: "+91")
        b.addTarget(self, action: #selector(moreCode), for: .touchUpInside)
        return b
    }()
    
    
    lazy var mobileF: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.maxLength = 12
        a.keyboardType = .numberPad
        //a.placeHolder = DYLOCS("Mobile phone number")
        let placeholderText = NSAttributedString(string: DYLOCS("Mobile phone number"),
                                                 attributes: [NSAttributedString.Key.foregroundColor: COLORFROMRGB(r: 255, 255, 255, alpha: 0.5) ])
        a.textInput.attributedPlaceholder = placeholderText
        a.textInput.textColor = .white
        a.textInput.tintColor = .white
        //a.textInput.tintedClearImage = UIImage.init(named: "ic_clear")
        return a
    }()
    
    lazy var quickB: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setBackgroundImage(UIImage.init(named: "ic_quick_login"), for: .normal)
        b.addTarget(self, action: #selector(onQuickLogin), for: .touchUpInside)
        return b
    }()
    
    lazy var passwordB: UIButton = {
        let b = UIButton.init(type: .custom)
        b.setBackgroundImage(UIImage.init(named: "ic_password_login"), for: .normal)
        b.addTarget(self, action: #selector(onPasswordLogin), for: .touchUpInside)
        return b
    }()
    
    lazy var loginB: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title:DYLOCS("Here we go") , image: nil, targte: self, action: #selector(onLoginClick))
        b.titleWeight = .bold
        return b
    }()
    
    lazy var otherNoteL: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.text = DYLOCS("Other landing methods")
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundV)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.preferredStatusColor = .lightContent

        view.addSubview(logoIV)
        //view.addSubview(mobileNote)
        view.addSubview(regionB)
        view.addSubview(mobileF)
        view.addSubview(loginB)
        view.addSubview(quickB)
        view.addSubview(passwordB)
        view.addSubview(otherNoteL)


        for sub in self.view.subviews {
            if sub == self.backgroundV {
                continue
            }
            sub.alpha = 0
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func layoutConstrints() {
        
        logoIV.snp.makeConstraints { (m) in
            m.topMargin.equalTo(100)
            m.centerX.equalToSuperview()
            m.width.equalTo(100)
            m.height.equalTo(100)
        }
//        mobileNote.snp.makeConstraints { (m) in
//            m.top.equalToSuperview().offset(SCREEN_HEIGHT*0.4)
//            m.centerX.equalToSuperview()
//        }
        regionB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 50, height: 40))
            m.right.equalTo(mobileF.snp.left)
            m.centerY.equalTo(mobileF)
        }
        
        mobileF.snp.makeConstraints { (m) in
            m.left.equalTo(logoIV).offset(-50)
            m.right.equalTo(logoIV).offset(80)
            m.top.equalTo(SCREEN_HEIGHT*0.4)
            m.height.equalTo(45)
        }
        
        loginB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 200, height: 50))
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-SCREEN_HEIGHT*0.28)
        }
        
        let width:CGFloat = 36
        
//        quickB.snp.makeConstraints { (m) in
//            m.size.equalTo(CGSize.init(width: width, height: width))
//            m.centerX.equalToSuperview().offset(-50)
//            m.bottom.equalToSuperview().offset(-BOTTOM_HEIGHT - 40)
//        }
        
        passwordB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: width, height: width))
            m.centerX.equalToSuperview()
            m.bottom.equalToSuperview().offset(-BOTTOM_HEIGHT-40)
        }
        otherNoteL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.bottom.equalTo(passwordB.snp.top).offset(-20)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1.9) {
            self.logoIV.alpha = 1
        } completion: { (finish) in
            
            var time: TimeInterval = 0.1
            for sub in self.view.subviews {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                UIView.animate(withDuration: 0.7) {
                        sub.alpha = 1
                    }
                }
                time += 0.1
            }
        }

    }
    
    @objc func onQuickLogin(_ sender: UIButton) -> Void {
      
    }
    
    @objc func onPasswordLogin(_ sender: UIButton) -> Void {
        let VC = HawaPwdLoginViewController(option: .login)
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func onLoginClick(_ sender: UIButton) -> Void {
        
        if mobileF.text!.count <= 0 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: DYLOCS("number error"))
            mobileF.becomeFirstResponder()
            return
        }
        
        let loginVC = HawaMobileLoginViewController(option: .login)
        loginVC.number = mobileF.text
        loginVC.regionCode = self.regionB.title(for: .normal)
        navigationController?.pushViewController(loginVC, animated: true)
        self.view.endEditing(true)
    }
    
    @objc func moreCode(_ sender: UIButton) -> Void {
        let region = HWRegionView.init(CGPoint.init(x: regionB.x-8 , y: regionB.y + regionB.height ))
        region.delegate = self
        region.present()
    }
    
    var keyboardOriginFrame:CGRect?
    @objc func keyboardWillShow(_ sender: Notification) {
        keyboardOriginFrame = self.loginB.frame
        if let frame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let y = frame.cgRectValue.origin.y
            if y < loginB.y + loginB.height  {
                UIView.animate(withDuration: 0.4) {
                    self.loginB.y = y - self.loginB.height - 20
                } completion: { (finish) in
                    self.loginB.snp.updateConstraints { (m) in
                        m.bottom.equalToSuperview().offset( -(SCREEN_HEIGHT-self.loginB.y-self.loginB.height))
                    }
                }

            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.loginB.frame = self.keyboardOriginFrame!
        }
    }
    
    class RegionCodeBtn: UIButton{

         init(frame: CGRect, title:String) {
            super.init(frame: frame)
            self.setImage(UIImage(named: "ic_arrow_down"), for: .normal)
            self.setTitle(title, for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: 0, right: 5)
            self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 35, bottom: 0, right: 0)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}



class HWLunchBackgroundView: UIView {
    
    var timer: Timer?
    
    lazy var coverV: UIView = {
        let v = UIView.init(frame: self.bounds)
        v.backgroundColor = COLORFROMRGB(r: 0, 0, 0, alpha: 0.8)
        return v
    }()
    
    lazy var bg1 = self.creatBgImage()
    lazy var bg2 = self.creatBgImage()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bg1)
        bg2.y = bg1.x+bg1.height
        addSubview(bg2)
        addSubview(coverV)
        
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(goingUp), userInfo: nil, repeats: true)
        
    }

    @objc func goingUp(_ sender: Timer) -> Void {
      
        bg1.y -= 0.3
        bg2.y -= 0.3
        
        if bg1.y + bg1.height <= 0 {
            bg1.y = bg2.y + bg2.height
        }
        if bg2.y + bg2.height <= 0 {
            bg2.y = bg1.y + bg1.height
        }

    }
    
    func creatBgImage() -> UIImageView {
        let i = UIImageView.init(image: UIImage.init(named: "bg_login"))
        let originSize = CGSize.init(width: i.image?.cgImage?.width ?? 0, height: i.image?.cgImage?.height ?? 0)
        let toSize = DYresizeAspect(originSize, toSize: bounds.size)
        i.frame = CGRect.init(origin: CGPoint.zero, size: toSize)
        return i
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
