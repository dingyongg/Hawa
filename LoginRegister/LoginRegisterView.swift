//
//  LoginRegisterView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import Foundation

@objc protocol LoginRegisterInputDelegate {
    @objc optional func didClickCaptcha()-> Bool
    @objc optional func loginRegisterInputShouldBeginEditing(_ input: LoginRegisterInput) -> Bool
}


class LoginRegisterInput: UIView, UITextFieldDelegate {
    
    weak var delegete: LoginRegisterInputDelegate?
    
    var text: String? {
        get {
            return textInput.text
        }
        set {
            textInput.text = newValue
        }
    }
    
    var keyboardType: UIKeyboardType? {
        didSet{
            textInput.keyboardType = keyboardType!
        }
    }
    
    var placeHolder:String?{
        didSet{
            textInput.placeholder = placeHolder
        }
    }

    var seconds: Int = 60
    var timer : Timer?
    var maxLength: Int = 99
    
    lazy var textInput: TintTextField = {
        let tv = TintTextField.init(frame: .zero)
        tv.font = UIFont.systemFont(ofSize: 19)
        tv.textColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        tv.delegate = self
        tv.tintColor = THEME_COLOR_RED
        tv.clearButtonMode = .whileEditing
        return tv
    }()
    lazy var captchaButton: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: DYLOCS("Get captcha") , image: nil, targte: self, action: #selector(onClick))
        b.font = UIFont.systemFont(ofSize: 14)

        return b
    }()
    
    init(frame: CGRect, type:LoginRegisterInputType) {
        super.init(frame: frame)
        addSubview(textInput)
        textInput.delegate = self
        if type == .captcha {
            addSubview(captchaButton)
            captchaButton.snp.makeConstraints { (m) in
                m.width.equalTo(106)
                m.top.equalToSuperview().offset(2.5)
                m.bottom.equalToSuperview().offset(-2.5)
                m.rightMargin.equalTo(-2.5)
                m.centerY.equalTo(self)
            }
        }else{
          
        }
        
        textInput.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(18)
            m.height.equalToSuperview()
            m.rightMargin.equalTo(-10)
        }
        
    }
    
    @objc func onClick(button:UIButton) -> Void {
        
        if (delegete?.didClickCaptcha?())! {
            countDown()
        }
        
    }
    
    func countDown() -> Void {
        weak var weakSelf = self
        captchaButton.isEnabled = false
        captchaButton.setTitle(String(weakSelf!.seconds), for: .disabled)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            weakSelf?.seconds = weakSelf!.seconds - 1
            weakSelf?.captchaButton.setTitle(String(weakSelf!.seconds), for: .disabled)
            if weakSelf!.seconds < 0{
                weakSelf?.timer!.invalidate()
                weakSelf?.captchaButton.setTitle("Get captcha", for: .normal)
                weakSelf?.captchaButton.isEnabled = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text!.count + string.count <= maxLength;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let should = delegete?.loginRegisterInputShouldBeginEditing?(self)
        if should == nil {
            return true
        }else{
            return should!
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return textInput.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.height/2
        layer.masksToBounds = true
    }
    
}


extension LoginRegisterInput{
    enum LoginRegisterInputType:Int {
        case captcha = 0
        case account = 1
    }
}


class HawaCaptchaDisplayView: UIView {
    
    lazy var stateL : LRLabel = {
        let l = LRLabel.init(text: "Your code is")
        return l
    }()
    
    lazy var captchL : UILabel = {
        let l = UILabel.init()
        l.textColor = THEME_COLOR_RED
        l.font = UIFont.boldSystemFont(ofSize: 31)
        return l
    }()
    
    lazy var determineButton: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: "Yes", image: nil, targte: self, action: #selector(determinClick))
        b.backgroundColor = .white
        b.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return b
    }()
    
    var determin: ((_ captch: String) -> Void)?
    
    
    public init(frame: CGRect, captcha:String) {
        super.init(frame: frame)
        layer.backgroundColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.init(width: 1, height: 1)
        layer.shadowOpacity = 0.1;
        layer.shadowRadius = 7;
        
        let attrStr = NSMutableAttributedString(string: captcha)
        //设置行间距
        let style:NSMutableParagraphStyle  = NSMutableParagraphStyle()
        //每行的左右间距
        attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: (captcha.count)))
        //设置字间距
        attrStr.addAttribute(NSAttributedString.Key.kern, value: 5, range: NSRange(location: 0, length: (captcha.count)))
        captchL.attributedText = attrStr
        addSubview(stateL)
        addSubview(captchL)
        addSubview(determineButton)
        
        stateL.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(20)
            m.centerX.equalToSuperview()
        }
        captchL.snp.makeConstraints { (m) in
            m.top.equalTo(stateL.snp.bottom).offset(15)
            m.centerX.equalToSuperview()
        }
        determineButton.snp.makeConstraints { (m) in
            m.top.equalTo(captchL.snp.bottom).offset(10)
            m.centerX.equalToSuperview()
            m.width.equalTo(210)
            m.height.equalTo(35)
        }
        
    }
    
    @objc func determinClick(button:UIButton)->Void{
        determin!(captchL.text!)
        removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
}

//登录注册页面的文案
class LRLabel: UILabel {
    
    init(text:String?) {
        super.init(frame: .zero)
        textColor = COLORFROMRGB(r: 102, 102, 102, alpha: 1)
        font = UIFont.systemFont(ofSize: 16)
        self.text = text
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//登录注册页面的icon
class LRIcon: UIView {
    lazy var iconIV: UIImageView = {
        let iv = UIImageView.init(frame: .zero)
        iv.contentMode = .center
        return iv
    }()
    init(icon:UIImage?) {
        super.init(frame: .zero)
        iconIV.image = icon
        addSubview(iconIV)
        iconIV.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.edges.equalTo(UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5))
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = rect.height/2
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
