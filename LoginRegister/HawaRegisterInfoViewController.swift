//
//  HawaRegisterViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SVProgressHUD
import ImagePicker
import DatePickerDialog
import SwiftyJSON
import Qiniu

class HawaRegisterInfoViewController: HawaBaseViewController, LoginRegisterInputDelegate {

    var mobile:String?
    var genderIndex:Int = 1
    var avatarPath: String = ""
    

    lazy var titleLabel: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("Welcome to " + DYDeviceInfo.APP_NAME )
        l.font = UIFont.boldSystemFont(ofSize: 24)
        l.textAlignment = .center
        l.textColor = .black
        return l
    }()
    
    
    
    lazy var avatarNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Perfect information, let more people find you"))
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    lazy var boyNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Boy") )
        return l
    }()
    lazy var girlNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Girl") )
        return l
    }()
//    lazy var birthdayNote: LRLabel = {
//        let l = LRLabel.init(text: DYLOCS("Please enter your birthday"))
//        return l
//    }()
    
//    lazy var avatar: UIButton = {
//        let b = UIButton.init(frame: .zero)
//        b.setImage(UIImage(named: "ic_avatar_ph"), for: .normal)
//        b.addTarget(self, action: #selector(avatarClick), for: .touchUpInside)
//        b.layer.cornerRadius = 52
//        b.layer.masksToBounds = true
//        b.imageView?.contentMode = .scaleAspectFill
//        return b
//    }()
    
    lazy var maleIC: UIButton = {
        let i = UIButton.init(frame: .zero)
        i.setImage(UIImage.init(named: "ic_gender_male_select"), for: .normal)
        i.addTarget(self, action: #selector(maleClick), for: .touchUpInside)
        return i
    }()
    lazy var femaleIC: UIButton = {
        let i = UIButton.init(frame: .zero)
        i.setImage(UIImage.init(named: "ic_gender_female_unselect"), for: .normal)
        i.addTarget(self, action: #selector(femaleClick), for: .touchUpInside)
        return i
    }()
    lazy var completeBtn: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: NSLocalizedString("Complete", comment:""), image: nil, targte: self, action: #selector(onClick))
        b.backgroundColor = COLORFROMRGB(r: 247, 247, 247, alpha: 1)
        b.titleWeight = .bold
        return b
    }()
    
    lazy var nicknameInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.backgroundColor = COLORFROMRGB(r: 247, 247, 247, alpha: 1)
        a.maxLength = 12
        a.placeHolder = DYLOCS("Please fill in your nickname")
        return a
    }()
    
    lazy var birthdayInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.backgroundColor = COLORFROMRGB(r: 247, 247, 247, alpha: 1)
        a.delegete = self
        a.placeHolder = DYLOCS("Please input your birthday")
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        a.text = formatter.string(from: date ?? Date())
        return a
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.addSubview(titleLabel)
        view.addSubview(avatarNote)
        view.addSubview(boyNote)
        view.addSubview(girlNote)
//        view.addSubview(birthdayNote)
        view.addSubview(maleIC)
        view.addSubview(femaleIC)
        view.addSubview(nicknameInput)
        view.addSubview(birthdayInput)
        view.addSubview(completeBtn)
        
        UserCenter.shared.getRandomNickname { (respond) in
            print(respond)
            self.nicknameInput.text = respond["nickname"].string
        } fail: { (error) in
            SVProgressHUD.showError(withStatus: error.message)
        }

        
        
    }
    
    let VIEW_MARGINT = 27
    override func layoutConstrints() {
        
//        titleIC.snp.makeConstraints { (m) in
//            m.width.height.equalTo(63)
//            m.topMargin.equalTo(40)
//            m.leftMargin.equalTo(VIEW_MARGINT)
//        }
        
        titleLabel.snp.makeConstraints { (m) in
            m.topMargin.equalTo(90)
            m.centerX.equalToSuperview()
        }
        
        
        avatarNote.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(25)
            m.centerX.equalToSuperview()
            m.leftMargin.equalTo(50)
            m.rightMargin.equalTo(-50)
        }
        
//        avatar.snp.makeConstraints { (m) in
//            m.width.height.equalTo(104)
//            m.centerX.equalToSuperview()
//            m.top.equalTo(avatarNote.snp.bottom).offset(15)
//        }
//        genderNote.snp.makeConstraints { (m) in
//           m.leftMargin.equalTo(VIEW_MARGINT+3)
//            m.top.equalTo(avatar.snp.bottom).offset(20)
//        }
        maleIC.snp.makeConstraints { (m) in
            m.width.height.equalTo(120)
            m.centerX.equalToSuperview().offset(-90)
            m.top.equalTo(avatarNote.snp.bottom).offset(30)
        }
        femaleIC.snp.makeConstraints { (m) in
            m.width.height.equalTo(120)
            m.centerX.equalToSuperview().offset(90)
            m.top.equalTo(avatarNote.snp.bottom).offset(30)
        }
        
        boyNote.snp.makeConstraints { (m) in
            m.centerX.equalTo(maleIC)
            m.top.equalTo(maleIC.snp.bottom).offset(15)
            
        }
        
        girlNote.snp.makeConstraints { (m) in
            m.centerX.equalTo(femaleIC)
            m.top.equalTo(femaleIC.snp.bottom).offset(15)
        }
        
//        nicknameNote.snp.makeConstraints { (m) in
//            m.leftMargin.equalTo(VIEW_MARGINT+3)
//            m.top.equalTo(maleIC.snp.bottom).offset(25)
//        }
        nicknameInput.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(55)
            m.top.equalTo(maleIC.snp.bottom).offset(80)
        }
//        birthdayNote.snp.makeConstraints { (m) in
//            m.leftMargin.equalTo(VIEW_MARGINT+3)
//            m.top.equalTo(nicknameInput.snp.bottom).offset(25)
//        }
        birthdayInput.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(55)
            m.top.equalTo(nicknameInput.snp.bottom).offset(30)
        }
        completeBtn.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(63)
            m.bottom.equalTo(-30+(-BOTTOM_HEIGHT))
        }
    }
    
    ///注册
    @objc func onClick (button:UIButton)->Void {
        
        SVProgressHUD.setDefaultMaskType(.none)
        
        if nicknameInput.text!.count <= 0 {
            SVProgressHUD.showError(withStatus: DYLOCS("nickname error"))
            return
        }
        
        if birthdayInput.text!.count <= 0 {
            SVProgressHUD.showError(withStatus: DYLOCS("birthday error"))
            return
        }
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        let info: JSON = [
            "thirdParty": mobile as Any,
            "birthday": birthdayInput.text as Any,
            "gender":genderIndex as Any,
            "nickname":nicknameInput.text as Any,
            "headImg":avatarPath as Any
        ]
        
        UserCenter.shared.login(info) { (respond) in
            
            SVProgressHUD.dismiss()

            let rootVC = HawaTabBarController()
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.window?.rootViewController = rootVC
            
            //self.navigationController?.dismiss(animated: true, completion: nil)

        } fail: { (error) in
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }

    }
    
    @objc func maleClick (button:UIButton)->Void {
        genderIndex = 1
        button.setImage(UIImage.init(named: "ic_gender_male_select"), for: .normal)
        femaleIC.setImage(UIImage.init(named: "ic_gender_female_unselect"), for: .normal)
        UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        
    }
    
    @objc func femaleClick (button:UIButton)->Void {
        genderIndex = 0
        button.setImage(UIImage.init(named: "ic_gender_female_select"), for: .normal)
        maleIC.setImage(UIImage.init(named: "ic_gender_male_unselect"), for: .normal)
        UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
    }

//    @objc func avatarClick (button:UIButton)->Void {
//        let imagePickerController = ImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.imageLimit = 1
//        present(imagePickerController, animated: true, completion: nil)
//
//    }
    
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        if images.count > 0 {
//            dismiss(animated: true, completion: nil)
//            avatar.setImage(images[0], for: .normal)
//        }
//    }
    
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        imagePicker.dismiss(animated: true) {
//            if images.count > 0 {
//                SVProgressHUD.setDefaultMaskType(.clear)
//                SVProgressHUD.show()
//                UserCenter.shared.upLoadImage(images[0]) { ( key) in
//                    SVProgressHUD.dismiss()
//                    self.avatarPath = key
//                    self.avatar.setImage(images[0], for: .normal)
//                } fail: { (error) in
//                    SVProgressHUD.setDefaultMaskType(.none)
//                    SVProgressHUD.showError(withStatus: error.message)
//                }
//            }
//        }
//
//    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func didClickCaptcha() -> Bool {
        return false
    }
    
    func loginRegisterInputShouldBeginEditing(_ input: LoginRegisterInput) -> Bool {
        
        let date =  Calendar.current.date(byAdding: .year, value: -18, to: Date())
        DatePickerDialog().show(DYLOCS("Choose Your Birthday"), doneButtonTitle: DYLOCS("Done"), cancelButtonTitle: DYLOCS("Cancel"), defaultDate: date!, minimumDate: nil, maximumDate: nil, datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.birthdayInput.text = formatter.string(from: dt)
            }
        }
        return false
    }
    
}
