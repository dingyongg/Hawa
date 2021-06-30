//
//  HWCollectionView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/25.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWCollectionView: UICollectionView {
    
    var loadImageTask = 0{
        didSet{
            print(loadImageTask)
        }
    }

}
