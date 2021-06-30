//
//  HomeViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/17.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

class HomeViewController: HawaBaseViewController{
    
    var currentCountryCode:String = "IND"
    
    lazy var recommendLayout: HWHomeRecommendLayout = {
        let l = HWHomeRecommendLayout.init()
        return l
    }()
    
    lazy var nearLayout: HWHomeNearLayout = {
        let l = HWHomeNearLayout.init()
        return l
    }()
    lazy var recommendCollectionV: HWCollectionView = {
        
        let v = HWCollectionView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT  ) , collectionViewLayout: recommendLayout)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .white
        v.register(HWHomeCollectionViewCell.self, forCellWithReuseIdentifier: ID_HOME_COLLECTION_CELL)
        v.register(HWCollectionReusableHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ID_HOME_COLLECTION_HEADER)
        v.showsVerticalScrollIndicator = false
        
        v.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(recommendRefresh))
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(recommendLoadMore))
        v.mj_header?.beginRefreshing()
        return v
    }()
    
    lazy var nearCollectionV: HWCollectionView = {
        
        let v = HWCollectionView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - HAWA_NAVI_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT ) , collectionViewLayout: nearLayout)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = COLORFROMRGB(r: 25, 25, 25, alpha: 1)
        v.register(HWHomeCollectionViewCell.self, forCellWithReuseIdentifier: ID_HOME_COLLECTION_CELL)
        v.showsVerticalScrollIndicator = false
        
        v.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(nearRefresh))
        v.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(nearLoadMore))
        v.mj_header?.beginRefreshing()
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabV = HWScrollTabView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - HAWA_BOTTOM_TAB_HEIGHT ))
        tabV.delegete = self
        tabV.dataSource = self
        tabV.titleAlignment = .left
        tabV.tabbarV.deHighlightedColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
        tabV.tabbarV.highlightedColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        tabV.titles = [DYLOCS("Recommend")]
        view.addSubview(tabV)
        
        //加载推荐
        UserCenter.shared.recommendList { (respond) in
            if(respond.array!.count > 0){
                let recommend = HWRecommendListView()
                recommend.users = respond.array!
            }
        } fail: { (error) in }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
}

extension HomeViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HWCollectionReusableHeaderViewDelegate{
    
    func HeaderView(_ headerView: HWCollectionReusableHeaderView, didSelectedBanner index: Int) {
        
        let VC = HWMemberCenterViewController.init(nibName:"HWMemberCenterViewController", bundle: nil)
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    func HeaderView(_ headerView: HWCollectionReusableHeaderView, didSelectedCountry code: String) {
        
        self.currentCountryCode = code
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        HWHomeModel.shared.refresh (self.currentCountryCode){ (models) in
            SVProgressHUD.dismiss()
   
            self.recommendLayout.listData = models
            self.recommendCollectionV.reloadData()
            
            if self.currentCountryCode !=  "IND" {

                if !UserCenter.shared.isVIP(){
                    
                    if HWMemberShipModel.shared.products != nil {
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                            
                            let view = VipChargeView.init(HWMemberShipModel.shared.products!)
                            view.present()
                            view.didCancelBlock = {
                                
                                self.currentCountryCode = "IND"
                                self.recommendLayout.listData = HWHomeModel.shared.freeList
                                self.recommendCollectionV.reloadData()
                            }
                        }
                    }else{
                        HWMemberShipModel.shared.loadProduct()
                    }
                }
            }
            
            
        } fail: { (error) in
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: error.message)
        }
        
    }
    
    //collectin datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recommendCollectionV {
            return recommendLayout.listData.count
        }else{
            return nearLayout.listData.count
        }

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ID_HOME_COLLECTION_CELL, for: indexPath) as! HWHomeCollectionViewCell
        var data: UserModel
        if collectionView == recommendCollectionV {
            data = recommendLayout.listData[indexPath.row]
        }else{
            data = nearLayout.listData[indexPath.row]
        }
      
        cell.dataModel = data
        cell.collectionV = collectionView as? HWCollectionView
       
        return cell
        
    }
    //collection delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var data: UserModel
        if collectionView == recommendCollectionV {
            data = recommendLayout.listData[indexPath.row]
        }else{
            data = nearLayout.listData[indexPath.row]
        }
    
        let profileVC = HWProfileViewController.init(NSNumber(value: data.userId!))
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ID_HOME_COLLECTION_HEADER, for: indexPath) as! HWCollectionReusableHeaderView
        header.delegate = self
        header.selectedCountryCode = currentCountryCode
        return header
    }
    
    @objc func recommendRefresh() -> Void {
        HWHomeModel.shared.refresh (self.currentCountryCode){ (models) in
            self.recommendCollectionV.mj_header?.endRefreshing()
            self.recommendLayout.listData = models
            self.recommendCollectionV.reloadData()
        } fail: { (error) in
            self.recommendCollectionV.mj_header?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    @objc func recommendLoadMore() -> Void {
        HWHomeModel.shared.loadMore(self.currentCountryCode){ (models) in
            self.recommendCollectionV.mj_footer?.endRefreshing()
            self.recommendLayout.listData = models
            self.recommendCollectionV.reloadData()
        } fail: { (error) in
            self.recommendCollectionV.mj_footer?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }

    }
    
    
    @objc func nearRefresh() -> Void {
        HWHomeModel.shared.refresh (self.currentCountryCode){ (models) in
            self.nearCollectionV.mj_header?.endRefreshing()
            self.nearLayout.listData = models
            self.nearCollectionV.reloadData()
        } fail: { (error) in
            self.nearCollectionV.mj_header?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    @objc func nearLoadMore() -> Void {
        HWHomeModel.shared.loadMore (self.currentCountryCode){ (models) in
            self.nearCollectionV.mj_footer?.endRefreshing()
            self.nearLayout.listData = models
            self.nearCollectionV.reloadData()
        } fail: { (error) in
            self.nearCollectionV.mj_footer?.endRefreshing()
            SVProgressHUD.showError(withStatus: error.message)
        }

    }
}

extension HomeViewController: HWScrollTabviewDelegate, HWScrollTabviewDataSource{
    
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        if index == 0 {
            return self.recommendCollectionV
        }else if (index == 1){
            return nearCollectionV
        }else{
            return UIView()
        }
    }
    
    func scrollTabview(_ tabView: HWScrollTabView, didScrollToTabTitle: String!, index: Int) {
        
    }
}
