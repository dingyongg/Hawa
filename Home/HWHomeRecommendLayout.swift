//
//  HawaLayout.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/14.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import Darwin
import SwiftyJSON

class HWHomeRecommendLayout: UICollectionViewFlowLayout {
    
    let headerH: CGFloat = HWAppCenter.shared.rabbit == 2 ? 170 : 120
    lazy var attributeArray:[UICollectionViewLayoutAttributes] = []
    var listData: [UserModel] = []
    var column:CGFloat! = 0
    lazy var columnsH: [CGFloat] = {
        let a = Array.init(repeating: sectionInset.top, count: Int(column))
        return a
    }()
    
    override init() {
        super.init()
        self.minimumLineSpacing = 5
        self.minimumInteritemSpacing = 5
        self.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 20, right: 10)
        column = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        super.prepare()
        debugPrint("prepare")
        
        attributeArray = []
        columnsH = Array.init(repeating: sectionInset.top, count: Int(column))
        
        for i in 0..<listData.count {
            
            let model = listData[i] as UserModel
            let attrIndex = IndexPath.init(item: i, section: 0)
            
            let minCheight = minColumn(columnsH)
            let minCindex =  CGFloat(columnsH.firstIndex(of: minCheight) ?? 0)
            let x:CGFloat = sectionInset.left + model.headImgW! * minCindex + minimumInteritemSpacing * minCindex
            let y:CGFloat = minCheight + minimumLineSpacing + headerH
            
            let attr = UICollectionViewLayoutAttributes(forCellWith:attrIndex)
            attr.frame = CGRect.init(x: x, y: y, width: model.headImgW!, height: model.headImgH!)
            attributeArray.append(attr)
            columnsH[Int(minCindex)] = columnsH[Int(minCindex)] + model.headImgH! + minimumLineSpacing

        }
        
        let headerPath = IndexPath.init(index: 0)
        let h = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerPath)
        h.frame = CGRect.init(x: 0, y: 5, width: SCREEN_WIDTH, height: headerH)
        attributeArray.append(h)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributeArray
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize.init(width: SCREEN_WIDTH, height: maxColumn(columnsH)+sectionInset.bottom + headerH )
    }
    
    ///获取column的最小高度
    func minColumn(_ columsH:[CGFloat]) -> CGFloat {
        var m: CGFloat = CGFloat.greatestFiniteMagnitude
        for i:CGFloat in columsH {
            m = min(i, m)
        }
        return m
    }
    ///获取最大高度
    func maxColumn(_ columsH:[CGFloat]) -> CGFloat {
        var m: CGFloat = 0
        for i:CGFloat in columsH {
            m = max(i, m)
        }
        return m
    }
        
}
