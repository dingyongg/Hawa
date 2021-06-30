//
//  HWVideoSuspendedView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SJVideoPlayer
import AgoraRtcKit

@objc protocol HWAVWaittingViewDelegate {
    func Accepted(_ view: HWAVWaittingView) -> Void
    func Refused(_ view: HWAVWaittingView) -> Void
}


class HWAVWaittingView: UIView, SJVideoPlayerControlLayerDelegate, AVAudioPlayerDelegate {
    
    lazy var audioPlay:AVAudioPlayer? = {
        let source = Bundle.main.path(forResource: "ring", ofType: "mp3")
        do{
            let p = try AVAudioPlayer.init(contentsOf: URL.init(string: source!)!)
            p.delegate = self
            p.prepareToPlay()
            p.numberOfLoops = -1
            print(p.duration)
            return p
        }catch  {
            return nil
        }
        
    }()

    weak var delegate: HWAVWaittingViewDelegate?

    lazy var bgImage: UIImageView = {
        let iv = UIImageView.init(frame: self.bounds)
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        return iv
    }()
    lazy var maskV: UIView = {
        let v = UIView.init(frame: self.bounds)
        v.backgroundColor = THEME_COVER_COLOR
        return v
    }()
    
    
    lazy var logo: HWLogo = {
        let iv = HWLogo.init(frame: CGRect.init(x: 0, y: 0, width: 75, height: 65))
        iv.centerX = centerX
        iv.centerY = SCREEN_HEIGHT/3
        iv.interval = 3
        return iv
    }()
    lazy var fromLogo: HWAvatar = {
        let a = HWAvatar.init(frame: .zero)
        a.layer.borderWidth = 2
        a.layer.borderColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        return a
    }()
    lazy var toLogo: HWAvatar = {
        let a = HWAvatar.init(frame: .zero)
        a.layer.borderWidth = 2
        a.layer.borderColor = COLORFROMRGB(r: 255, 255, 255, alpha: 1).cgColor
        return a
    }()
    
    lazy var noteL: UILabel = {
        let l = UILabel.init()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 18)
        return l
    }()
    
    lazy var refuseBtn: HWRoundButton = {
        let b = HWRoundButton.init()
        b.setImage(UIImage.init(named: "ic_video_hangup"), for: .normal)
        b.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return b
    }()
    lazy var acceptBtn: HWRoundButton = {
        let b = HWRoundButton.init()
        b.addTarget(self, action: #selector(accept), for: .touchUpInside)
        b.setImage(UIImage.init(named: "ic_video_accept"), for: .normal)
        return b
    }()
    
    
    var status: HWAVChatStatus? {
        
        didSet{
            self.audioPlay?.play()
            if status == HWAVChatStatus.from {
                acceptBtn.snp.updateConstraints { (m) in
                    m.centerX.equalToSuperview().offset(80)
                }
                refuseBtn.snp.updateConstraints { (m) in
                    m.centerX.equalToSuperview().offset(-80)
                }
                
            }else if  status == HWAVChatStatus.to  {
                refuseBtn.snp.updateConstraints { (m) in
                    m.centerX.equalToSuperview()
                }
                acceptBtn.snp.updateConstraints { (m) in
                    m.centerX.equalToSuperview().offset(800)
                }
                
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgImage)
        addSubview(maskV)
        addSubview(logo)
        addSubview(fromLogo)
        addSubview(toLogo)
        addSubview(noteL)
        addSubview(acceptBtn)
        addSubview(refuseBtn)

        fromLogo.snp.makeConstraints { (m) in
            m.centerY.equalTo(logo)
            m.size.equalTo(CGSize.init(width: 98, height: 98))
            m.right.equalTo(logo.snp.left).offset(-30)
        }
        toLogo.snp.makeConstraints { (m) in
            m.centerY.equalTo(logo)
            m.size.equalTo(CGSize.init(width: 98, height: 98))
            m.left.equalTo(logo.snp.right).offset(30)
        }

        noteL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(logo.snp.bottom).offset(150)
        }
        
        acceptBtn.snp.updateConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 67, height: 67))
            m.centerX.equalToSuperview().offset(800)
            m.bottom.equalToSuperview().offset(-100)
        }
        refuseBtn.snp.updateConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 67, height: 67))
            m.centerX.equalToSuperview().offset(-800)
            m.bottom.equalToSuperview().offset(-100)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit -- HWAVWaittingView")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.audioPlay?.stop()
        self.logo.stop()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.audioPlay?.play()
        self.logo.start()
    }

    
    @objc func accept() -> Void {
        delegate?.Accepted(self)
    }
    
    @objc func dismiss() -> Void {
        delegate?.Refused(self)
    }
    
    
}
