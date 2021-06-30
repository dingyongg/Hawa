//
//  LiveViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/10/17.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class LiveViewController: HawaBaseViewController{

    lazy var layout: HawaLiveLayout = {
        let l = HawaLiveLayout.init()
        return l
    }()
    
    lazy var collectionV: UICollectionView = {
        
        let v = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - HAWA_NAVI_HEIGHT ) , collectionViewLayout: layout)
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = COLORFROMRGB(r: 25, 25, 25, alpha: 1)
        v.register(HWLiveCollectionViewCell.self, forCellWithReuseIdentifier: ID_LIVE_COLLECTION_CELL)
        v.showsVerticalScrollIndicator = false
        return v
    }()
    
    lazy var scrollTabV: HWScrollTabView = {
        let v = HWScrollTabView.init(frame: self.view.bounds)
        v.dataSource = self
        v.delegete = self
        v.titles = [DYLOCS("Recommend")]
        v.tabbarV.backgroundColor = COLORFROMRGB(r: 25, 25, 25, alpha: 1)
        v.titleAlignment = .left
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollTabV)
        
        for i in 0..<20 {
            let cellM =  HawaLiveUseModel()
            cellM.watch = Int(arc4random()%1000)
            let r = i%4
            switch r {
            case 0:
                cellM.imgPath = "https://c-ssl.duitang.com/uploads/blog/202011/09/20201109172221_69e2e.thumb.400_0.jpg"
                break
            case 1:
                cellM.imgPath = "https://c-ssl.duitang.com/uploads/blog/202010/25/20201025180701_9c394.thumb.400_0.jpg"
                break
            case 2:
                cellM.imgPath = "https://c-ssl.duitang.com/uploads/blog/202010/22/20201022193403_e900c.thumb.400_0.jpeg"
                break
            default: break
                
            }
            layout.dataArray?.append(cellM)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }


}

extension LiveViewController: HWScrollTabviewDataSource, HWScrollTabviewDelegate{
    func scrollTabview(_ tabView: HWScrollTabView, viewForTitle: String!, index: Int) -> UIView {
        return  collectionV
    }
    
}

extension LiveViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    //collectin datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layout.dataArray!.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ID_LIVE_COLLECTION_CELL, for: indexPath) as! HWLiveCollectionViewCell
        cell.dataModel = layout.dataArray![indexPath.item] as! HawaLiveUseModel
        
        return cell
        
    }
    //collection delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profileVC = HWProfileViewController.init(8)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ID_HOME_COLLECTION_HEADER, for: indexPath) as! HWCollectionReusableHeaderView
        header.dataSource = ["https://c-ssl.duitang.com/uploads/blog/202011/09/20201109172221_69e2e.thumb.400_0.jpg","https://c-ssl.duitang.com/uploads/blog/202010/25/20201025180701_9c394.thumb.400_0.jpg","https://c-ssl.duitang.com/uploads/blog/202010/22/20201022193403_e900c.thumb.400_0.jpeg"]
        
        return header
        
    }
    
}
    
