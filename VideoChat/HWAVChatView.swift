//
//  HWCallingVideoView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/24.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import AgoraRtcKit
import SwiftyJSON
import SJVideoPlayer

enum HWAVChatStatus :Int {
    case from = 0
    case to = 1
    case doing = 2
    case rest = 3
}

enum HWAVChatMode :Int {
    case video = 0
    case audio = 1
    case message = 3
}

class HWAVChatView: UIView {
    
    static let shared: HWAVChatView = HWAVChatView.init()
    var videoPlayer: SJVideoPlayer = HWVideoPlay.shared.player
    
    var videoDidFinishedCallBack: (() -> Void)? 
    var timer: Timer?
    var seconds: Int = 0
    
    var preVideoURL:String?{
        didSet{
            let asset = SJVideoPlayerURLAsset.init(url: URL.init(string: preVideoURL!)!)
            
            videoPlayer.urlAsset = asset
            videoPlayer.presentView.frame = self.bounds
            videoPlayer.presentView.y = 2
            videoPlayer.gestureControl.gestureRecognizerShouldTrigger = {a, b, c in
                return false
            }
            videoPlayer.playbackObserver.assetStatusDidChangeExeBlock = {[weak self] player in
                
                let strongSelf = self
                
                switch player.assetStatus {
                case .failed:
                    print(".failed")
                    strongSelf!.videoPlayer.presentView.removeFromSuperview()
                case .preparing:
                    print("preparing")
                    break
                case .readyToPlay:
                    print("readyToPlay")
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                        strongSelf?.channalID = "channelID"
                        strongSelf?.status = .doing
                        strongSelf?.startCount()
                    }
                    break
                case .unknown:
                    print("unknown")
                    break
                default:
                    break
                }
            }
            videoPlayer.playbackObserver.playbackDidFinishExeBlock = {[weak self] player in
                let strongSelf = self
                strongSelf!.videoPlayer.presentView.removeFromSuperview()
                strongSelf!.videoDidFinishedCallBack?()
                strongSelf!.stopCount()
            }

            self.chattingV.remoteLayer.addSubview(videoPlayer.presentView)
            
        }
    }
    
    var channalID: String?{
        didSet{
            if status == HWAVChatStatus.to {
                self.sendMsg(self.mode == HWAVChatMode.audio ? 50 : 60)
                agoraKit.joinChannel(byToken: nil, channelId: channalID ?? "" , info: nil, uid: UInt(UserCenter.shared.userId!)) { (string, id, status) in
                    print(string)
                    print(id)
                    print(status)
                }
            }
        }
    }
    
    var you: UserModel? {
        didSet{
            waittingV.bgImage.sd_setImage(with: URL.init(string: you?.headImg ?? ""), completed: nil)
            if status == .from {
                waittingV.fromLogo.setImage(you?.headImg ?? "")
                waittingV.toLogo.setImage(UserCenter.shared.theUser?.headImg ?? "")
                waittingV.noteL.text = (you?.nickname)!  + " is calling you..."
            }else if status == .to {
                waittingV.fromLogo.setImage(UserCenter.shared.theUser?.headImg ?? "")
                waittingV.toLogo.setImage(you?.headImg ?? "" )
                waittingV.noteL.text = "Wait for " +  (you?.nickname)!  + " to answer …"
            }else{
               
            }
        }
    }
    
    lazy var agoraKit: AgoraRtcEngineKit = {
        let a = AgoraRtcEngineKit.sharedEngine(withAppId: AGORA_APPID, delegate: self)
        return a
    }()
    
    lazy var chattingV: HWAVProcessingView = {
        let v = HWAVProcessingView.init(frame: self.bounds)
        v.delegate = self
        return v
    }()
    
    lazy var waittingV: HWAVWaittingView = {
        let v = HWAVWaittingView.init(frame: self.bounds)
        v.delegate = self
        return v
    }()
    
    var status: HWAVChatStatus = .rest {
        
        didSet{
            if status == HWAVChatStatus.from || status == HWAVChatStatus.to {
                addSubview(waittingV)
                waittingV.status = status
            }else if  status == HWAVChatStatus.doing{
                waittingV.removeFromSuperview()
                addSubview(chattingV)
                if self.mode == HWAVChatMode.audio {
                    chattingV.setBgImg(you?.headImg ?? "")
                }
            }
        }
    }
    
    var mode:HWAVChatMode? {
        didSet{
            self.chattingV.mode = mode
            if mode == HWAVChatMode.video {
                agoraKit.enableVideo()
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = UInt(UserCenter.shared.userId ?? 0)
                videoCanvas.view = chattingV.localLayer
                videoCanvas.renderMode = .hidden
                // 设置本地视图。
                agoraKit.setupLocalVideo(videoCanvas)
                
            }else{
                agoraKit.enableAudio()
                agoraKit.setAudioProfile(AgoraAudioProfile.musicHighQuality, scenario: AgoraAudioScenario.gameStreaming)
            }
        }
    }
    
    
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: -SCREEN_HEIGHT , width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
    }
    
    func setInit(mod: HWAVChatMode, sts: HWAVChatStatus) -> Void {
        self.mode = mod
        self.status = sts
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func present() -> Void {
        
        let rootVC = UIApplication.shared.delegate as! AppDelegate
        rootVC.window?.addSubview(self)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.y = 0
        } completion: { (complete) in
            
        }
        
        HWChargeFlyManager.shared.stopFly()
        
    }
    
    func dismiss() -> Void {
        HWChargeFlyManager.shared.startFly()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.y = -SCREEN_HEIGHT
        } completion: { (complete) in
            self.removeFromSuperview()
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        agoraKit.leaveChannel(nil)
        self.stopCount()
        self.status = .rest
        self.waittingV.removeFromSuperview()
        self.chattingV.removeFromSuperview()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    deinit {
        debugPrint("deinit -- HWAVChatView")
    }
    
    func startCount() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCount), userInfo: nil, repeats: true)
    }
    
    func stopCount() -> Void {
        timer?.invalidate()
        timer = nil
        seconds = 0
    }
    
    @objc func timerCount() -> Void {
        seconds += 1
        chattingV.chatBar.timeL.text = formatSecondsToString(TimeInterval(seconds))

        if preVideoURL != nil {
            if seconds >= 10 {
                self.videoPlayer.pause()
                self.videoDidFinishedCallBack?()
                self.stopCount()
            }
        }
        
        if  preVideoURL == nil && seconds%60 == 1 {
            self.consumeDiamond()
        }
    }
    
    func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    func consumeDiamond() -> Void {
        UserCenter.shared.avConsumeDi(channelID: channalID ?? "", receiveId: (you?.userId!)!, type: self.mode == HWAVChatMode.audio ? 0 : 1 ) { (respond) in

        } fail: { (error) in
            SVProgressHUD.showError(withStatus: error.message)
            if(error.code == 119 || error.code == 116 ){
                self.HangUp(nil)
            }
        }
    }
}


extension HWAVChatView: HWAVWaittingViewDelegate, HWAVProcessingViewDelegate{
    
    func Refused(_ view: HWAVWaittingView) {
        
        self.sendMsg(self.mode == HWAVChatMode.audio ? 54 : 64)
        agoraKit.leaveChannel(nil)
        dismiss()
    }
    
    func Accepted(_ view: HWAVWaittingView) {
        
        HWAVAuthModel.shared.receiveAuth(you!) { (result) in
            if result>=0{
                self.sendMsg(self.mode == HWAVChatMode.audio ? 51 : 61)
                self.status = .doing
                self.agoraKit.joinChannel(byToken: nil, channelId: self.channalID ?? "", info: nil, uid: UInt(UserCenter.shared.userId!)) { (string, id, status) in
                    print(string)
                    print(id)
                    print(status)
                }
            }else{
                
            }
        }
    }
    
    func HangUp(_ view: HWAVProcessingView?) {
        
        self.sendMsg(self.mode == HWAVChatMode.audio ? 52 : 62)
        agoraKit.leaveChannel(nil)
        self.stopCount()
        if self.videoPlayer.isPlaying {
            self.videoPlayer.stop()
        }
        dismiss()
    }
    
    func sendMsg(_ msgType: Int) -> Void {
        let conv = WFCCConversation.init(type: .Single_Type, target: String((self.you?.userId)!), line: 0)
        let content = WFCCVideoCallMessageContent.init()
        
        let extro: JSON = [
            "avatar": UserCenter.shared.theUser?.headImg as Any,
            "sex": UserCenter.shared.theUser?.gender as Any,
            "nickname":UserCenter.shared.theUser?.nickname as Any,
            "vipType": UserCenter.shared.theUser?.vipType as Any,
            "sentTime": Date.init().timeIntervalSince1970 as Any,
            "msgType":msgType,
            "channelId": (self.channalID ?? "")  as Any
        ]
        
        content.extra = extro.rawString()
        WFCCIMService.sharedWFCIM()?.send(conv, content: content, success: { (sdf, sf) in
            print(sdf, sf)
        }, error: { (error) in
            print(error)
        })

    }
}


extension HWAVChatView:AgoraRtcEngineDelegate{
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameDecodedOfUid uid: UInt, elapsed: Int) {
        
        status = .doing
        startCount()
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = chattingV.remoteLayer
        videoCanvas.renderMode = .hidden
        // 设置远端视图。
        agoraKit.setupRemoteVideo(videoCanvas)
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        
        agoraKit.leaveChannel(nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
            self.dismiss()
        }
    }
 
    
    
}
