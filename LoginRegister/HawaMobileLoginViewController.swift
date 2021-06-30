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


enum LoginViewControllerOption{
    case login
    case register
}

class HawaMobileLoginViewController: HawaBaseViewController,LoginRegisterInputDelegate {

    
    var agreementCheck: Bool = true
    var timer:Timer?
    var captcha:String?
    var number:String?{
        didSet{
            self.accountInput.text = number
        }
    }
    var regionCode:String?{
        didSet{
            self.regionL.text = regionCode
        }
    }
    
    lazy var completeBtn: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title:DYLOCS("Next") , image: nil, targte: self, action: #selector(onClick))
        b.titleWeight = .bold
        return b
    }()
    
    lazy var accountInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .account)
        a.maxLength = 12
        a.keyboardType = .numberPad
        return a
    }()
    
    lazy var regionL: UILabel = {
        let b = UILabel.init()
        b.textColor = .black
        b.font = UIFont.systemFont(ofSize: 18)
        return b
    }()
    
    lazy var captchaInput: LoginRegisterInput = {
        let a = LoginRegisterInput.init(frame: .zero, type: .captcha)
        a.maxLength = 6
        a.delegete = self
        a.keyboardType = .numberPad
        a.placeHolder = DYLOCS("Input code")
        return a
    }()
    lazy var mobileNote: LRLabel = {
        let l = LRLabel.init(text: DYLOCS("Your can modify your number here") )
        return l
    }()
//    lazy var captchaNote: LRLabel = {
//        let l = LRLabel.init(text: DYLOCS("Input verification code") )
//        return l
//    }()

    lazy var titleLabel: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("Mobile phone number login")
        l.textColor = .black
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
        
//        switch option {
//        case .login:
//           // button.title = "Login"
//        case .register:
//           // button.title = "Register"
//        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(completeBtn)
        view.addSubview(accountInput)
        view.addSubview(captchaInput)
        view.addSubview(mobileNote)
        //view.addSubview(captchaNote)
        view.addSubview(titleLabel)
        view.addSubview(regionL)
        view.addSubview(agreementBtn)
        view.addSubview(checkBox)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _  = self.captchaInput.becomeFirstResponder()
    }

    override func layoutConstrints() {
        let VIEW_MARGINT = 27
        titleLabel.snp.makeConstraints { (m) in
            m.topMargin.equalTo(50)
            m.leftMargin.equalTo(VIEW_MARGINT)
        }
        
        mobileNote.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.top.equalTo(titleLabel.snp.bottom).offset(40)
        }
        regionL.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT)
            m.top.equalTo(mobileNote.snp.bottom).offset(20)
        }
        accountInput.snp.makeConstraints { (m) in
            m.left.equalTo(regionL.snp.right)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(45)
            m.centerY.equalTo(regionL)
        }
        
//        captchaNote.snp.makeConstraints { (m) in
//            m.leftMargin.equalTo(VIEW_MARGINT+3)
//            m.top.equalTo(accountInput.snp.bottom).offset(37)
//        }
        
        captchaInput.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(VIEW_MARGINT-10)
            m.rightMargin.equalTo(-VIEW_MARGINT)
            m.height.equalTo(45)
            m.top.equalTo(accountInput.snp.bottom).offset(30)
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
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: DYLOCS("number error"))
            return
        }

        if captchaInput.text != captcha {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.clear)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showError(withStatus: DYLOCS("code error"))
            }
            return
        }
        
        self.view.endEditing(true)
        let infoVC = HawaRegisterInfoViewController()
        infoVC.mobile = accountInput.text!
        navigationController?.pushViewController(infoVC, animated: true)
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
    
    //发验证码
    func didClickCaptcha()-> Bool {
        
        if accountInput.text!.count <= 0 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: DYLOCS("number error"))
            return false
        }

        weak var weakSelf = self
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (Timer) in
            
            let captcha = HawaCaptchaDisplayView.init(frame: .zero, captcha:(weakSelf?.getCaptcha())!)
            captcha.determin = { captcha in
                self.captchaInput.text = captcha
                self.captchaInput.textInput.resignFirstResponder()
            }
            weakSelf?.view.addSubview(captcha)
            captcha.snp.makeConstraints { (m) in
                m.width.equalTo(270)
                m.height.equalTo(161)
                m.center.equalToSuperview()
            }
        })
        
        return true
    
    }
    ///生成随机验证码
    func getCaptcha() -> String {
        
        captcha = String(Int(arc4random()%1000000))
        if captcha!.count == 6 {
            return captcha!
        }else{
            return getCaptcha()
        }
    }

}


/*
* 1：美国
* 1：加拿大 [3]
* 1-264：安圭拉岛
* 1-268：安提瓜和巴布达
* 1-242：巴哈马
* 1-246：巴巴多斯
* 1-441：百慕大
* 1-284：英属维京群岛
* 1-345：开曼群岛
* 1-684：美属萨摩亚
* 1-767：多米尼克
* 1-809：多米尼加共和国
* 1-473：格林纳达
* 1-876：牙买加
* 1-664：蒙特塞拉特
* 1-787/1-939：波多黎各
* 1-869：圣基茨和尼维斯
* 1-758：圣卢西亚
* 1-784：圣文森特和格林纳丁斯
* 1-868：特立尼达和多巴哥
* 1-649：特克斯和凯科斯群岛
* 1-340：美属维京群岛
* 1-671：关岛
* 1-670：北马里亚纳群岛
区域2
* 20 --埃及
* 211 --南苏丹
* 212 --摩洛哥
* 213 --阿尔及利亚
* 216 --突尼斯
* 218 --利比亚
* 220 --冈比亚
* 221 --塞内加尔
* 222 --毛里塔尼亚
* 223 --马里
* 224 --几内亚
* 225 --科特迪瓦
* 226 --布基纳法索
* 227 --尼日尔
* 228 --多哥
* 229 --贝宁
* 230 --毛里求斯
* 231 --利比里亚
* 232 --塞拉利昂
* 233 --加纳
* 234 --尼日利亚
* 235 --乍得
* 236 --中非共和国
* 237 --喀麦隆
* 238 --佛得角
* 239 --圣多美和普林西比
* 240 --赤道几内亚
* 241 --加蓬
* 242 --刚果共和国（布）
* 243 --刚果民主共和国（金）
* 244 --安哥拉
* 245 --几内亚比绍
* 246 -- 迪戈加西亚岛
* 247 --阿森松岛
* 248 --塞舌尔
* 249 --苏丹
* 250 --卢旺达
* 251 --埃塞俄比亚
* 252 --索马里
* 253 --吉布提
* 254 --肯尼亚
* 255 --坦桑尼亚
* 256 --乌干达
* 257 --布隆迪
* 258 --莫桑比克
* 259 -- 桑给巴尔
* 260 --赞比亚
* 261 --马达加斯加
* 262 --留尼汪
* 263 --津巴布韦
* 264 --纳米比亚
* 265 --马拉维
* 266 --莱索托
* 267 --博茨瓦纳
* 268 --斯威士兰
* 269 --科摩罗和马约特
* 27 --南非
* 290 --圣赫勒拿
* 291 --厄立特里亚
* 297 --阿鲁巴
* 298 --法罗群岛
* 299 -- 格陵兰
区域3
* 30 --希腊
* 31 --荷兰
* 32 --比利时
* 33 --法国
* 34 --西班牙
* 350 --直布罗陀
* 351 --葡萄牙
* 352 --卢森堡
* 353 --爱尔兰
* 354 --冰岛
* 355 --阿尔巴尼亚
* 356 --马耳他
* 357 --塞浦路斯
* 358 --芬兰
* 359 --保加利亚
* 36 --匈牙利
* 37 -- 东德
* 370 --立陶宛
* 371 --拉脱维亚
* 372 --爱沙尼亚
* 373 --摩尔多瓦
* 374 --亚美尼亚
* 375 --白俄罗斯
* 376 --安道尔
* 377 --摩纳哥
* 378 -- 圣马力诺
* 379 -- 梵蒂冈
* 38 --南斯拉夫
* 380 --乌克兰
* 381 --塞尔维亚
* 382 --黑山
* 385 --克罗地亚
* 386 --斯洛文尼亚
* 387 --波黑
* 388 --欧洲电话号码空间――环欧洲服务
* 389 --马其顿
* 39 -- 意大利
区域4
* 40 --罗马尼亚
* 41 --瑞士
* 42 -- 捷克斯洛伐克
* 420 --捷克共和国
* 421 --斯洛伐克
* 423 --列支敦士登
* 43 --奥地利
* 44 --英国
* 45 --丹麦
* 46 --瑞典
* 47 --挪威
* 48 --波兰
* 49 -- 德国
区域5
* 500 --福克兰群岛
* 501 --伯利兹
* 502 --危地马拉
* 503 --萨尔瓦多
* 504 --洪都拉斯
* 505 --尼加拉瓜
* 506 --哥斯达黎加
* 507 --巴拿马
* 508 --圣皮埃尔和密克隆群岛
* 509 --海地
* 51 --秘鲁
* 52 --墨西哥
* 53 --古巴
* 54 --阿根廷
* 55 --巴西
* 56 --智利
* 57 --哥伦比亚
* 58 --委内瑞拉
* 590 --瓜德罗普（含法属圣马丁和圣巴泰勒米岛）
* 591 --玻利维亚
* 592 --圭亚那
* 593 --厄瓜多尔
* 594 --法属圭亚那
* 595 --巴拉圭
* 596 --马提尼克
* 597 --苏里南
* 598 --乌拉圭
* 599 -- 荷属安的列斯
* 599 -- 荷属圣马丁
* 599-9 -- 库拉索
区域6
* 60 --马来西亚
* 61 --澳大利亚
* 62 --印度尼西亚
* 63 --菲律宾
* 64 --新西兰
* 65 --新加坡
* 66 --泰国
* 670 --东帝汶
* 672 -- 澳大利亚海外领地：南极洲、圣诞岛、科科斯群岛、诺福克岛
* 673 --文莱
* 674 --瑙鲁
* 675 --巴布亚新几内亚
* 676 --汤加
* 677 --所罗门群岛
* 678 --瓦努阿图
* 679 --斐济
* 680 --帕劳
* 681 --瓦利斯和富图纳群岛
* 682 --库克群岛
* 683 --纽埃
* 685 --萨摩亚
* 686 --基里巴斯，吉尔伯特群岛
* 687 --新喀里多尼亚
* 688 --图瓦卢，埃利斯群岛
* 689 --法属波利尼西亚
* 690 --托克劳群岛
* 691 --密克罗尼西亚联邦
* 692 --马绍尔群岛
区域7
* 7 --俄罗斯、哈萨克斯坦 [3]
区域8
* 81 -- 日本
* 82 -- 韩国
* 84 -- 越南
* 850 -- 朝鲜
* 852 -- 中国香港
* 853 -- 中国澳门
* 855 -- 柬埔寨
* 856 -- 老挝
* 86 -- 中国
* 870 -- 国际海事卫星组织 "SNAC" 卫星电话
* 878 -- 环球个人通讯服务
* 880 -- 孟加拉国
* 881 -- 移动卫星系统
* 882 -- 国际网络
* 886 -- 中国台湾
区域9
* 90 --土耳其
* 91 -- 印度
* 92 -- 巴基斯坦
* 93 --阿富汗
* 94 --斯里兰卡
* 95 --缅甸
* 960 --马尔代夫
* 961 --黎巴嫩
* 962 --约旦
* 963 --叙利亚
* 964 --伊拉克
* 965 --科威特
* 966 --沙特阿拉伯
* 967 --也门
* 968 --阿曼
* 969 -- 也门民主共和国
* 970 -- 巴勒斯坦
* 971 --阿拉伯联合酋长国
* 972 --以色列
* 973 --巴林
* 974 --卡塔尔
* 975 --不丹
* 976 --蒙古
* 977 --尼泊尔
* 979 -- 国际费率服务（International Premium Rate Service）
* 98 --伊朗
* 991 -- 国际电信公众通信服务试验（International Telecommunications Public Correspondence Service trial , ITPCS）
* 992 --塔吉克斯坦
* 993 --土库曼斯坦
* 994 --阿塞拜疆
* 995 --格鲁吉亚
* 996 --吉尔吉斯斯坦
* 998 --乌兹别克斯坦
*/
