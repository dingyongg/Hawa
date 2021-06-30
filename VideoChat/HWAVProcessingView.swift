//
//  HWVideoProcessView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import AgoraRtcKit

@objc protocol HWAVProcessingViewDelegate {
    func HangUp(_ view:HWAVProcessingView?) -> Void
}

class HWAVProcessingView: UIView {
    
    var mode: HWAVChatMode? {
        didSet{
           
            if mode == HWAVChatMode.video {
                
                audioBgContainer.removeFromSuperview()
                
                addSubview(remoteLayer)
                addSubview(localLayer)
                addSubview(chatBar)
                
                localLayer.snp.makeConstraints { (m) in
                    m.size.equalTo(CGSize.init(width: 110, height: 142))
                    m.rightMargin.equalTo(-HAWA_SCREEN_HORIZATAL_SPACE)
                    m.bottomMargin.equalTo(-25)
                }
                chatBar.snp.removeConstraints()
                chatBar.snp.makeConstraints { (m) in
                    m.bottomMargin.equalTo(-25)
                    m.right.equalTo(localLayer.snp.left).offset(-15)
                    m.leftMargin.equalTo(15)
                    m.height.equalTo(43)
                }
                
            }else{
                remoteLayer.removeFromSuperview()
                localLayer.snp.removeConstraints()
                localLayer.removeFromSuperview()
                
                addSubview(audioBgContainer)
                addSubview(chatBar)
                chatBar.snp.removeConstraints()
                chatBar.snp.makeConstraints { (m) in
                    m.bottomMargin.equalTo(-25)
                    m.width.equalTo(300)
                    m.height.equalTo(43)
                    m.centerX.equalToSuperview()
                }

            }
        }
    }
    
    weak var delegate: HWAVProcessingViewDelegate?
    
    lazy var fromLogo: HWAvatar = {
        let a = HWAvatar.init(frame: .zero)
        return a
    }()
    
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
    
    lazy var audioBgContainer: UIView = {
        let v = UIView.init(frame: self.bounds)
        v.addSubview(bgImage)
        v.addSubview(maskV)
        v.addSubview(fromLogo)

        fromLogo.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize.init(width: 98, height: 98))
            m.centerX.equalToSuperview()
            m.centerY.equalToSuperview().offset(-120)
        }
    
        return v
    }()
    

    
    lazy var remoteLayer: UIView = {
        let l = UIView.init(frame: self.bounds)
        l.backgroundColor = UIColor.darkText
        return l
    }()
    lazy var localLayer: UIView = {
        let l = UIView.init(frame: .zero)
        l.backgroundColor = UIColor.darkGray
        return l
    }()
    
    lazy var chatBar: HWChattinBar = {
        let c = HWChattinBar()
        c.hangUpBlock = {
            self.delegate?.HangUp(self)
        }
        return c
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = COLORFROMRGB(r: 51, 51, 51, alpha: 1)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.chatBar.timeL.text = "00:00"
    }
    
    deinit {
        debugPrint("deinit -- HWAVProcessingView")
    }
    
    func setBgImg(_ imageURL: String) -> Void {
        fromLogo.setImage(imageURL)
        bgImage.sd_setImage(with: URL.init(string: imageURL), completed: nil)
    }
    
    class HWChattinBar: UIView {
        
        lazy var timeL: UILabel = {
            let l = UILabel.init()
            l.textColor = .white
            l.font = UIFont.systemFont(ofSize: 18)
            l.textAlignment = .center
            return l
        }()
        
        lazy var separator: UIView = {
            let l = UIView.init()
            l.backgroundColor = .white
            return l
        }()
        
        lazy var hangUpBtn: UIButton = {
            let b = UIButton.init()
            b.setImage(UIImage.init(named: "ic_hang"), for: .normal)
            b.addTarget(self, action: #selector(hangUp), for: .touchUpInside)
            b.imageView?.contentMode = .scaleAspectFit
            return b
        }()
        
        lazy var chatBtn: UIButton = {
            let b = UIButton.init()
            b.setImage(UIImage.init(named: "ic_video_to_chat"), for: .normal)
            b.imageView?.contentMode = .scaleAspectFit
            return b
        }()
        
        lazy var hangUpBtnContainer: UIView = {
            let v = UIView.init(frame: .zero)
            return v
        }()
        
        var hangUpBlock: (()->Void)?
        
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = COLORFROMRGB(r: 0, 0, 0, alpha: 0.3)
            addSubview(timeL)
            addSubview(separator)
            addSubview(hangUpBtnContainer)
            hangUpBtnContainer.addSubview(hangUpBtn)
            
            
            timeL.text = "00:00"
            
            timeL.snp.makeConstraints { (m) in
                m.leftMargin.equalTo(15)
                m.centerY.equalToSuperview()
                m.width.equalTo(65)
            }
            
            separator.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalTo(timeL.snp.right).offset(15)
                m.topMargin.equalTo(8)
                m.bottomMargin.equalTo(-8)
                m.width.equalTo(1)
            }
            hangUpBtnContainer.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.right.equalToSuperview()
                m.left.equalTo(separator.snp.right)
                m.bottom.equalToSuperview()
            }
            hangUpBtn.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.centerX.equalToSuperview()
                m.size.equalTo(CGSize.init(width: 25, height: 25))
            }
//            chatBtn.snp.makeConstraints { (m) in
//                m.size.equalTo(CGSize.init(width: 25, height:25))
//                //m.left.equalTo(hangOnBtn.snp.right).offset(30)
//                m.centerY.equalToSuperview()
//                m.rightMargin.equalTo(-15)
//            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        @objc func hangUp(_ sender: UIButton) -> Void {
            self.hangUpBlock?()
        }
        
        override func draw(_ rect: CGRect) {
            layer.cornerRadius = rect.size.height/2
            layer.masksToBounds = true
        }
        
    }
}

