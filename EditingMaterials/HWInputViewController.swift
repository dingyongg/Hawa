//
//  HWInputViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/8.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWInputViewController: HawaBaseViewController {
    
    var placeholder: String?{
        didSet{
            
        }
    }
    
    lazy var tv: UITextView = {
        let f = UITextView.init(frame: .zero)
        f.font = UIFont.systemFont(ofSize: 16)
        f.textColor = THEME_CONTENT_DARK_COLOR
        f.becomeFirstResponder()
        return f
    }()
    
    lazy var inp: HWShadowView = {
        let i = HWShadowView.init(frame: CGRect.init(x: 0, y: HAWA_NAVI_HEIGHT-20, width: SCREEN_WIDTH, height: 100))
        i.addSubview(tv)
        tv.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(20)
            m.right.equalToSuperview().offset(-20)
            m.bottom.equalToSuperview().offset(-10)
            m.left.equalToSuperview().offset(20)
        }
        return i
    }()
    
    var cb: ((String)-> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let i = UIBarButtonItem.init(title: DYLOCS("complete"), style: .plain, target: self, action: #selector(complete))
        i.tintColor = THEME_COLOR_RED
        self.navigationItem.rightBarButtonItem = i
        
        view.addSubview(inp)

    }
    
    @objc func complete() -> Void {
        pop()
        cb?(tv.text ?? "")
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
