//
//  HawaLiveLayout.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/21.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HawaLiveLayout: UICollectionViewFlowLayout {
    var attributeArray:[UICollectionViewLayoutAttributes]?
    var dataArray:[Any]?
    var column:CGFloat! = 0
    lazy var columnsH: [CGFloat] = {
        let a = Array.init(repeating: sectionInset.top, count: Int(column))
        return a
    }()
    
    override init() {
        attributeArray = []
        dataArray = []
        super.init()
        self.minimumLineSpacing = 5
        self.minimumInteritemSpacing = 5
        self.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 20, right: 10)
        column = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        let collectionW = collectionView?.bounds.width
        let marginL = sectionInset.left
        let marginR = sectionInset.right
        let space = minimumInteritemSpacing * (column - 1)
        let itemW:CGFloat = (collectionW! - marginL - marginR - space) / column
        for i in 0..<dataArray!.count {
            let attrIndex = IndexPath.init(item: i, section: 0)
            let minCheight = minColumn(columnsH)
            let minCindex =  CGFloat(columnsH.firstIndex(of: minCheight) ?? 0)
            let x:CGFloat = sectionInset.left + itemW * minCindex + minimumInteritemSpacing * minCindex
            let y:CGFloat = minCheight + minimumLineSpacing
            let itemH:CGFloat = CGFloat(arc4random()%200 + 100)
            let attr = UICollectionViewLayoutAttributes(forCellWith:attrIndex)
            attr.frame = CGRect.init(x: x, y: y, width: itemW, height: itemH)
            attributeArray?.append(attr)
            columnsH[Int(minCindex)] = columnsH[Int(minCindex)] + itemH + minimumLineSpacing
        }
        
        let headerPath = IndexPath.init(index: 0)
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("layoutAttributesForElements")
        return attributeArray
    }
    
    override var collectionViewContentSize: CGSize{
        print("collectionViewContentSize")
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
