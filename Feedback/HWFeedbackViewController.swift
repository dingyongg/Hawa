//
//  HWFeedbackViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2021/1/7.
//  Copyright © 2021 丁永刚. All rights reserved.
//

import UIKit

class HWFeedbackViewController: HawaBaseViewController, UITextViewDelegate {

    let maxC = 150
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxC {
            if let str = textView.text {
                //截取前100个字符
                let subStr = str.prefix(100)
                textView.text = String(subStr)
            }
        }
        countL.text = String.init(format: "%ld/%d", textView.text.count, maxC)
    }
    
    
    var placeholder: String?{
        didSet{
            
        }
    }
    
    lazy var tv: UITextView = {
        let f = UITextView.init(frame: .zero)
        f.font = UIFont.systemFont(ofSize: 16)
        f.textColor = THEME_CONTENT_DARK_COLOR
        f.becomeFirstResponder()
        f.delegate = self
        return f
    }()
    
    lazy var countL: UILabel = {
        let l = UILabel.init()
        l.textColor = THEME_SUB_CONTEN_COLOR
        l.font = UIFont.systemFont(ofSize: 15)
        l.text = String.init(format: "0/%d", maxC)
        return l
    }()
    
    
    lazy var inp: HWShadowView = {
        let i = HWShadowView.init(frame: CGRect.init(x: 0, y: HAWA_NAVI_HEIGHT-20, width: SCREEN_WIDTH, height: 200))
        i.addSubview(tv)
        tv.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.bottom.equalToSuperview().offset(-10)
            m.left.equalToSuperview().offset(20)
        }
        i.addSubview(countL)
        countL.snp.makeConstraints { (m) in
            m.rightMargin.equalTo(-15)
            m.bottomMargin.equalTo(-10)
        }
        return i
    }()
    
    var cb: ((String)-> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let i = UIBarButtonItem.init(title: DYLOCS("Submit"), style: .plain, target: self, action: #selector(complete))
        i.tintColor = THEME_COLOR_RED
        self.navigationItem.rightBarButtonItem = i
        view.addSubview(inp)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func complete() -> Void {
        
        if self.tv.text.count <= 0 {
            SVProgressHUD.setDefaultMaskType(.none)
            SVProgressHUD.showError(withStatus: "Please input you advise, thanks!")
        }else{
            self.tv.resignFirstResponder()
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
            UserCenter.shared.feedback(self.tv.text) { (res) in
                
                let c = String(format: "We have recevied your %@, your %@ is very importent to us, we will consider it seriously! and we will feedback you as soon as possible. ", self.title ?? "", self.title ?? "")
                SVProgressHUD.showSuccess(withStatus: c)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                    self.pop()
                }
                
            } fail: { (err) in
                SVProgressHUD.setDefaultMaskType(.none)
                SVProgressHUD.showError(withStatus: err.message)
            }

        }
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
