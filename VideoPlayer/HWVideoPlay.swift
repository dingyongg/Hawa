//
//  HWVideoPlay.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/14.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit
import SJVideoPlayer

class HWVideoPlay: NSObject {
    
    static let shared: HWVideoPlay = HWVideoPlay.init()
    
    lazy var player: SJVideoPlayer = {
        let p = SJVideoPlayer.lightweight()
        p.gestureControl.singleTapHandler = {con, p in }
        p.defaultEdgeControlLayer.isHiddenBottomProgressIndicator =  false
        p.playbackObserver.playbackDidFinishExeBlock = { a in
            a.play()
        }
        return p
    }()
    
    
}
