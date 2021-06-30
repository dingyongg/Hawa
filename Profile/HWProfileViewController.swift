//
//  HWProfileViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/24.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SVProgressHUD
import SJVideoPlayer


class HWProfileViewController: HWBaseTableViewController {
    
    lazy var userModel: UserModel? = nil{
        
        didSet{
            profileV.userModel = userModel
            videoV.userModel = userModel
 
        }
    }
    
    var timer:Timer?
    var avcBtns:[HWAVCButton] = []
    var followed: Bool?
    
    lazy var profileV: HWProfileView = {
        let v = HWProfileView.init(frame: self.view.bounds)
        return v
    }()
    lazy var videoV: HWProfileVideoView = {
        let v = HWProfileVideoView.init(frame: self.view.bounds)
        return v
    }()
    
    lazy var scrollTab: HWScrollTabView = {
        let tab = HWScrollTabView.init(frame: view.bounds)
        tab.delegete = self
        tab.dataSource = self
        let gLayer: CAGradientLayer =  CAGradientLayer.init()
        gLayer.frame = tab.tabbarV.bounds
        gLayer.colors = [COLORFROMRGB(r: 0, 0, 0, alpha: 0.7).cgColor, COLORFROMRGB(r: 0, 0, 0, alpha: 0.0).cgColor]
        gLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gLayer.endPoint = CGPoint.init(x: 0, y: 1)
        gLayer.locations = [NSNumber(0), NSNumber(0.9), NSNumber(1)]
        tab.tabbarV.layer.addSublayer(gLayer)
        tab.tabbarV.tabbarLeftBtn = UIButton.init(frame: .zero)
        tab.tabbarV.tabbarLeftBtn?.setImage(UIImage.init(named: "ic_arrow_left"), for: .normal)
        tab.tabbarV.tabbarLeftBtn?.addTarget(self, action: #selector(pop), for: .touchUpInside)
        
        tab.tabbarV.tabbarRightBtn = UIButton.init(frame: .zero)
        tab.tabbarV.tabbarRightBtn?.setImage(UIImage.init(named: "ic_more"), for: .normal)
        tab.tabbarV.tabbarRightBtn?.addTarget(self, action: #selector(more), for: .touchUpInside)
        tab.tabbarV.tabbarRightBtn?.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 15)
        tab.tabbarV.tabbarRightBtn?.imageView?.contentMode = .scaleAspectFit
        
        tab.titles = [DYLOCS("Profile"),DYLOCS("Video")]
        tab.titleAlignment = .center
        tab.isTranslute = true
        
        return tab
    }()
    
    
    @objc init(_ userId: NSNumber) {
        super.init(nibName: nil, bundle: nil)
        HWHomeModel.shared.loadDetail(Int(truncating: userId)) { (respond) in
            let user = UserModel.init(dataSource: respond)
            self.userModel = user
            
            if user.userId != UserCenter.shared.userId {
                let imagesName = ["ic_chat","ic_audio", "ic_video"]
                let btnW: CGFloat = 72
                
                let space:CGFloat = (SCREEN_WIDTH - btnW*3)/4
                
                for i in 0..<imagesName.count {
                    let btn = HWAVCButton.init(frame: CGRect.init(x: space + CGFloat(i)*(btnW+space), y: SCREEN_HEIGHT - btnW - 20, width: btnW, height: btnW))
                    btn.setImage(UIImage(named: imagesName[i]), for: .normal)
                    btn.addTarget(self, action: #selector(self.actions), for: .touchUpInside)
                    btn.tag = i
                    self.view.addSubview(btn)
                    self.avcBtns.append(btn)
                }
                
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.randomShake), userInfo: nil, repeats: true)
                
            }

        } fail: { (error) in
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        self.preferredStatusColor = .lightContent
        self.title = ""
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(scrollTab)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.profileV.profileTv.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoV.videoPlayer.pause()
    }
    
    
    @objc func randomShake(_ userInfo: Any) -> Void {
        let r = Int.random(in: 0...2)
        avcBtns[r].shakeAshake()
    }
    
    @objc func more() -> Void{
        let action = HawaActionView.init("Do you want ?", options: [DYLOCS( "Report"), DYLOCS("Block")], cancel: DYLOCS("Cancel"))
        action.present()
        action.actionsBlock = { index, title in
            
            switch index {
            case 0:
                let vc = HWFeedbackViewController.init()
                vc.title = DYLOCS("Report") 
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                SVProgressHUD.setDefaultMaskType(.clear)
                SVProgressHUD.show()
                UserCenter.shared.block((self.userModel?.userId)!, type: 0){ (res) in
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showSuccess(withStatus: "BLock successfully")
                } fail: { (erro) in
                    SVProgressHUD.setDefaultMaskType(.clear)
                    SVProgressHUD.showError(withStatus: erro.message)
                }
                break
            default:
                break
            }
            
        }
    }

    
    @objc func actions(_ sender: UIButton) -> Void{
        if sender.tag == 0 {
            if self.userModel != nil {
                let msgList = WFCUMessageListViewController.init()
                msgList.conversation = WFCCConversation.init(type: .Single_Type, target: String((userModel?.userId)!) , line: 0)
                
                let userM = WFUseInfo.init()
                userM.userId = String(userModel!.userId!)
                userM.userInfo = [
                    "userId": userModel!.userId! as Any,
                    "nickname": userModel!.nickname! as Any,
                    "headImg":userModel!.headImg! as Any
                ]
                msgList.targetUserInfo = userM
                self.navigationController?.pushViewController(msgList, animated: true)
            }
        }else if sender.tag == 1 {
            if self.userModel != nil {
                self.videoV.videoPlayer.pause()
                HWAVAuthModel.shared.callAudio(self.userModel!)
            }
        }else if sender.tag == 2 {
            if self.userModel != nil {
                self.videoV.videoPlayer.pause()
                HWAVAuthModel.shared.callVideo(self.userModel!)
            }
        }
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}


extension HWProfileViewController: HWScrollTabviewDelegate, HWScrollTabviewDataSource {
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        if index == 1 {
            videoV.videoPlayer.play()
            return videoV
        }else if index == 0{
            videoV.videoPlayer.pause()
            return profileV
        }else{
            return UIView()
        }
    }
}

class HWProfileView: UIView {
    
    var headerImgSize: CGSize?
    
    lazy var userModel: UserModel? = nil{
        didSet{
            profileHeader.userModel = userModel
            bgView.sd_setImage(with: URL.init(string: (userModel!.headImg)!)) { [self] (image, error, type, url) in
                
                let originSize = CGSize.init(width: image?.cgImage?.width ?? 100, height: image?.cgImage?.height ?? 100)
                
                let aspectSize = DYresizeAspect(originSize, toSize: self.bounds.size)
                
                bgView.height = aspectSize.height
                headerImgSize = bgView.size
            
                profileTv.contentInset = UIEdgeInsets.init(top: bgView.height-HAWA_STATUS_BAR_HEIGHT, left: 0, bottom: 0, right: 0)
                
                profileTv.contentOffset = CGPoint.init(x: 0, y: -profileTv.height*0.35)
            }
            profileTv.reloadData()
        }
    }
    
    lazy var bgView: UIImageView = {
        let iv = UIImageView.init(frame: bounds)
        iv.contentMode = .scaleAspectFit
        iv.y = -iv.height/2
        return iv
    }()
    
    lazy var profileHeader: HWprofileHeader = {
        let v = HWprofileHeader.init(frame:CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 110))
        return v
    }()
    
    lazy var profileFooter: UIView = {
        let v = UIView.init(frame: bounds)
        v.height = v.height/2
        v.backgroundColor = .white
        return v
    }()
    

    lazy var profileTv: UITableView = {
        let v = UITableView.init(frame: self.bounds)
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.register(HWProfilePicTableViewCell.self, forCellReuseIdentifier:ID_PROFILE_PIC_TABLE_CELL )
        v.register(HWProfilePresentTableViewCell.self, forCellReuseIdentifier:ID_PROFILE_PRESENT_TABLE_CELL )
        v.tableHeaderView = profileHeader
        v.tableFooterView = profileFooter
        v.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        v.layoutMargins = .zero
        v.contentInset = UIEdgeInsets.init(top: self.height*0.4, left: 0, bottom: 0, right: 0)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .clear
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgView)
        addSubview(profileTv)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        if y < 0 {
            bgView.center = CGPoint.init(x: width/2, y:abs(y/2)<(height/2) ? abs(y/2):(height/2) )
            if abs(y) >= (headerImgSize?.height ?? 9999) {  //固定位置开始放大
                bgView.size = CGSize.init(width:  abs(y)/headerImgSize!.height*headerImgSize!.width  , height: abs(y))
                bgView.centerY = abs(y)/2
                bgView.centerX = width/2
            }
        }
    }

}

extension HWProfileView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            
        }else if(indexPath.row == 1){
            
        }else if(indexPath.row == 2){
            
        }else{
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 2 {
            let h = 50 + ceil(CGFloat((userModel?.buyGiftList!.count)!)/4)*95   //基础高，加每行礼物的高
            return h
        }else{
            return 180
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_PROFILE_PIC_TABLE_CELL, for: indexPath) as! HWProfilePicTableViewCell
            cell.title = DYLOCS("My Photo")
            cell.images = userModel?.album
            return cell
        }else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_PROFILE_PIC_TABLE_CELL, for: indexPath) as! HWProfilePicTableViewCell
            cell.title = DYLOCS("Private photos")
            cell.images = userModel?.privateAlbum
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_PROFILE_PRESENT_TABLE_CELL, for: indexPath) as! HWProfilePresentTableViewCell
            cell.title = DYLOCS("Gift Wall")
            cell.presents = userModel?.buyGiftList
            return cell
        }else{
            let cell = UITableViewCell.init()
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel == nil ? 0 : 3
    }
}

class HWProfileVideoView: UIView,SJPlayerAutoplayDelegate{
    
    func sj_playerNeedPlayNewAsset(at indexPath: IndexPath) {
        let dataSource = userModel!.viewShowList?[indexPath.row]
        let playM =  SJPlayModel.init(tableView: shortVideoTableV, indexPath: indexPath)
        let playUrl = URL.init(string: dataSource!["videoFile"].string!)!
        videoPlayer.urlAsset = SJVideoPlayerURLAsset.init(url: playUrl, playModel: playM)
        
        videoPlayer.presentView.placeholderImageView.sd_setImage(with: URL.init(string: dataSource!["videoShotImg"].string! ), completed: nil)
        //videoPlayer.playbackController.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    lazy var videoPlayer: SJVideoPlayer = {
        let p = SJVideoPlayer.init()
        p.gestureControl.singleTapHandler = {con, p in }
        p.defaultEdgeControlLayer.isHiddenBottomProgressIndicator =  false
        p.playbackObserver.playbackDidFinishExeBlock = { a in
            a.play()
        }
        return p
    }()
    
    lazy var userModel: UserModel? = nil{
        didSet{
            shortVideoTableV.reloadData()
            addSubview(flyV)
            fly()
        }
    }
    
    lazy var shortVideoTableV: UITableView = {
        let v = UITableView.init(frame: bounds )
        v.separatorStyle = .none
        v.backgroundColor = THEME_DARK_BG_COLOR
        v.isPagingEnabled = true
        v.separatorInset = UIEdgeInsets.zero
        v.layoutMargins = UIEdgeInsets.zero
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.delegate = self
        v.dataSource = self
        v.register(HWProfileVideoTableViewCell.self, forCellReuseIdentifier: ID_PROFILE_VIDEO_TABLE_CELL)
        let config = SJPlayerAutoplayConfig.init(autoplayDelegate: self)
        v.sj_enableAutoplay(with: config)
        v.bounces = false
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .never
        } else {
            //self.automaticallyAdjustsScrollViewInsets = false
        }
        return v
    }()
    
    
    
    
    lazy var flyV: UIView = {
        
        let v =  UIView.init(frame: CGRect.init(x: SCREEN_WIDTH, y: SCREEN_HEIGHT-200, width: SCREEN_WIDTH - 100, height: 75))
        v.layer.cornerRadius = 10
        v.backgroundColor = .white
        
        let a = HWAvatar.init(frame: CGRect.init(x: 10, y:7.5 , width: 60, height: 60))
        a.setImage((userModel?.headImg ?? ""))
        
        let nic = UILabel.init(frame: .zero)
        
        nic.text = userModel?.nickname
        nic.textColor = THEME_DARK_BG_COLOR
        nic.font = UIFont.systemFont(ofSize: 18)
        
        let pro = UILabel.init(frame: CGRect.init(x: 80, y: 33, width: SCREEN_WIDTH - 180, height: 40))
        pro.numberOfLines = 0
        pro.text = userModel?.profile
        pro.textColor = THEME_SUB_CONTEN_COLOR
        pro.font = UIFont.systemFont(ofSize: 16)
        
        let gender = UIImageView.init(image:UIImage.init(named: "ic_gender_female"))
        gender.contentMode = .scaleAspectFit
        v.addSubview(gender)
        v.addSubview(nic)
        v.addSubview(pro)
        v.addSubview(a)
        
        nic.snp.makeConstraints { (m) in
            m.top.equalTo(a).offset(2)
            m.left.equalTo(a.snp.right).offset(10)
        }
        
        gender.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 15, height: 15))
            m.centerY.equalTo(nic)
            m.left.equalTo(nic.snp.right).offset(5)
        }
        return  v
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(shortVideoTableV)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func fly() -> Void {
        
        UIView.animate(withDuration: 0.6, delay: 3, options: UIView.AnimationOptions.curveEaseOut) {
            self.flyV.x = 15
        } completion: { (fini) in
            
            UIView.animate(withDuration: 0.8, delay: 4, options: UIView.AnimationOptions.curveEaseIn) {
                self.flyV.x = -SCREEN_WIDTH
            } completion: { (fini) in
                self.flyV.removeFromSuperview()
            }
        }
    }
    
}

extension HWProfileVideoView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel?.viewShowList?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.height
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID_PROFILE_VIDEO_TABLE_CELL, for: indexPath) as! HWProfileVideoTableViewCell
        cell.dataSource = userModel!.viewShowList?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

