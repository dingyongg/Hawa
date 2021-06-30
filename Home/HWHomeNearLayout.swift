//
//  FSFSDFSD.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/3.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import Darwin
import SwiftyJSON

class HWHomeNearLayout: UICollectionViewFlowLayout {
    
    var attributeArray:[UICollectionViewLayoutAttributes] = []
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
        
        
        let collectionW = collectionView?.bounds.width
        let marginL = sectionInset.left
        let marginR = sectionInset.right
        let space = minimumInteritemSpacing * (column - 1)
        let itemW:CGFloat = (collectionW! - marginL - marginR - space) / column
        for i in 0..<listData.count {
            let attrIndex = IndexPath.init(item: i, section: 0)
            let minCheight = minColumn(columnsH)
            let minCindex =  CGFloat(columnsH.firstIndex(of: minCheight) ?? 0)
            let x:CGFloat = sectionInset.left + itemW * minCindex + minimumInteritemSpacing * minCindex
            let y:CGFloat = minCheight + minimumLineSpacing
            
            let model = listData[i] as UserModel
            var itemH: CGFloat = 0
            if model.headImgH != nil {
                let power = itemW/CGFloat(model.headImgW!)
                itemH = CGFloat(model.headImgH!)*power
            }else{
                itemH = CGFloat(arc4random()%200 + 100)
            }

            let attr = UICollectionViewLayoutAttributes(forCellWith:attrIndex)
            attr.frame = CGRect.init(x: x, y: y, width: itemW, height: itemH)
            attributeArray.append(attr)
            columnsH[Int(minCindex)] = columnsH[Int(minCindex)] + itemH + minimumLineSpacing
         
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributeArray
    }
    
    override var collectionViewContentSize: CGSize{
        return CGSize.init(width: SCREEN_WIDTH, height: maxColumn(columnsH)+sectionInset.bottom)
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
