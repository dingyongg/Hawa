//
//  DynamicViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/17.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import MJRefresh
import SJVideoPlayer

class DynamicViewController: HawaBaseViewController, SJPlayerAutoplayDelegate {
    
    func sj_playerNeedPlayNewAsset(at indexPath: IndexPath) {
        let dataSource = HWSDModel.shared.shortVideoData![indexPath.row]
        let playM =  SJPlayModel.init(tableView: shortVideoTableV, indexPath: indexPath)
        let playUrl = URL.init(string: dataSource["videoFile"].string!)!
        videoPlayer.urlAsset = SJVideoPlayerURLAsset.init(url: playUrl, playModel: playM)
        
        let cell = shortVideoTableV.cellForRow(at: indexPath) as! HWShortVideoTableViewCell
        videoPlayer.presentView.placeholderImageView.image = cell.mainImageV.image
        videoPlayer.presentView.placeholderImageView.contentMode = .scaleAspectFit
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
    
    
    lazy var shortVideoTableV: UITableView = {
        let v = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: HAWA_CONTENT_HEIGHT))
        v.separatorStyle = .none
        v.backgroundColor = .white
        v.isPagingEnabled = true
        v.separatorInset = UIEdgeInsets.zero
        v.layoutMargins = UIEdgeInsets.zero
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.register(HWShortVideoTableViewCell.self, forCellReuseIdentifier: ID_SHORT_VIDEO_TABLE_CELL)
        v.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(shortVideoRefresh))
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(shortVideoLoadMore))
        v.mj_header?.beginRefreshing()
        let config = SJPlayerAutoplayConfig.init(autoplayDelegate: self)
        v.sj_enableAutoplay(with: config)
        return v
    }()
    lazy var dynamicTableV: UITableView = {
        let v = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT ))
        v.separatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        v.layoutMargins = UIEdgeInsets.zero
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.register(HWDynamicTableViewCell.self, forCellReuseIdentifier: ID_DYNAMIC_TABLE_CELL)
        v.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(dynamicRefresh))
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(dynamicLoadMore))
        v.mj_header?.beginRefreshing()
        return v
    }()
    
    lazy var matchV: HWMatchView = {
        let v = HWMatchView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT))
        v.controller = self
        return v
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return self.preferredStatusColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        let tabV = HWScrollTabView.init(frame: view.bounds)
        shortVideoTableV.delegate = self
        shortVideoTableV.dataSource = self
        dynamicTableV.delegate = self
        dynamicTableV.dataSource = self
        tabV.delegete = self
        tabV.dataSource = self
        //tabV.tabbarV.backgroundColor = .white
        tabV.tabbarV.deHighlightedColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        tabV.tabbarV.highlightedColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        tabV.titles = [DYLOCS("Short video"), DYLOCS("Dynamic"), DYLOCS("Matching")]
        tabV.titleAlignment = .left
        view.addSubview(tabV)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayer.pause()
    }
    
    @objc func  shortVideoRefresh() -> Void {
        
        HWSDModel.shared.shortVideoRefresh { (respond) in
            self.shortVideoTableV.mj_header?.endRefreshing()
            self.shortVideoTableV.reloadData()
            
        } fail: { (error) in
            self.shortVideoTableV.mj_header?.endRefreshing()
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
        
    }
    
    @objc func  shortVideoLoadMore() -> Void {
        
        HWSDModel.shared.shortVideoLoadMore({ (respond) in
            self.shortVideoTableV.mj_footer?.endRefreshing()
            self.shortVideoTableV.reloadData()
            
        }) { (error) in
            self.shortVideoTableV.mj_footer?.endRefreshing()
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    @objc func  dynamicRefresh() -> Void {
        
        HWSDModel.shared.dynamicRefresh({ (respond) in
            self.dynamicTableV.mj_header?.endRefreshing()
            self.dynamicTableV.reloadData()
        }) { (error) in
            self.dynamicTableV.mj_header?.endRefreshing()
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    @objc func  dynamicLoadMore() -> Void {
        
        HWSDModel.shared.dynamicLoadMore({ (respond) in
            self.dynamicTableV.mj_footer?.endRefreshing()
            self.dynamicTableV.reloadData()
        }) { (error) in
            self.dynamicTableV.mj_footer?.endRefreshing()
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    
}

extension DynamicViewController: HWScrollTabviewDelegate, HWScrollTabviewDataSource{
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        switch index {
        case 0:
            //tabView.tabbarV.highlightedColor = COLORFROMRGB(r: 25, 25, 25, alpha: 1)
           
            return shortVideoTableV
        case 1:
            videoPlayer.pause()
            //tabView.tabbarV.highlightedColor = COLORFROMRGB(r: 25, 25, 25, alpha: 1)
          
            return dynamicTableV
        case 2:
            videoPlayer.pause()
            //tabView.tabbarV.highlightedColor =
          
            return matchV
        default:
            return UIView()
        }
    }
}

extension DynamicViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == shortVideoTableV {
            return HWSDModel.shared.shortVideoData!.count
        }else{
            return HWSDModel.shared.dynamicModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == shortVideoTableV {
            return  shortVideoTableV.height
        }else{
            return HWSDModel.shared.dynamicModels[indexPath.row].cellH
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == shortVideoTableV {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_SHORT_VIDEO_TABLE_CELL, for: indexPath) as! HWShortVideoTableViewCell
            cell.dataSource = HWSDModel.shared.shortVideoData![indexPath.row]
            cell.avartarClick = { id in
                let c = HWProfileViewController.init(NSNumber(value: id))
                c.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(c, animated: true)
            }
            cell.chatClick = { dataSource in
                let msgList = WFCUMessageListViewController.init()
                msgList.conversation = WFCCConversation.init(type: .Single_Type, target: String(dataSource["userId"].int!) , line: 0)
                msgList.hidesBottomBarWhenPushed = true
                let userM = WFUseInfo.init()
                userM.userId = String(dataSource["userId"].int!)
                userM.userInfo = [
                    "userId": dataSource["userId"] as Any,
                    "nickname": dataSource["nickname"].string as Any,
                    "headImg": dataSource["imageUrl"] as Any
                ]
                msgList.targetUserInfo = userM
                self.navigationController?.pushViewController(msgList, animated: true)
            }
            cell.videoClick = {  userM in
                HWAVAuthModel.shared.callVideo(userM)
                self.videoPlayer.pause()
            }
            cell.audioClick = { userM in
                HWAVAuthModel.shared.callAudio(userM)
                self.videoPlayer.pause()
            }
            
            return cell
        }else if(tableView == dynamicTableV ){
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_DYNAMIC_TABLE_CELL, for: indexPath) as! HWDynamicTableViewCell
            cell.tableView = tableView
            cell.model = HWSDModel.shared.dynamicModels[indexPath.row]
            cell.avartarClick = { id in
                let c = HWProfileViewController.init(NSNumber(value: id))
                c.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(c, animated: true)
            }
            cell.likeClick = { model in
                if model.liked {
                    model.likeTimes -= 1
                }else{
                    model.likeTimes += 1
                }
                model.liked = !model.liked
                self.dynamicTableV.reloadData()
            }
            cell.letterClick = { id in
                let model = HWSDModel.shared.dynamicModels[indexPath.row]
                let msgList = WFCUMessageListViewController.init()
                msgList.conversation = WFCCConversation.init(type: .Single_Type, target: String(id) , line: 0)
                msgList.hidesBottomBarWhenPushed = true
                let userM = WFUseInfo.init()
                userM.userId = String(model.userId!)
                userM.userInfo = [
                    "userId": model.userId as Any,
                    "nickname": model.name as Any,
                    "headImg":model.headUrl as Any
                ]
                msgList.targetUserInfo = userM
                self.navigationController?.pushViewController(msgList, animated: true)
            }
            cell.moreClick = { model in
                
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
                        UserCenter.shared.block((model.userId)!, type: 0){ (res) in
                            
                            HWSDModel.shared.dynamicModels.remove(at: indexPath.row)
                            tableView.reloadData()
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
            return cell
        }else{
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // tableView.contentSize = CGSize.init(width: tableView.size.width, height: tableView.size.height*4)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
