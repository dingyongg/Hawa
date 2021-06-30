//
//  HWAboutViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/23.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit

class HWAboutViewController: HawaBaseViewController {


    @IBOutlet weak var versionL: UILabel!
    
    lazy var appNameL: UILabel = {
        let l = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        l.text = DYDeviceInfo.APP_NAME
        l.centerX = SCREEN_WIDTH/2
        l.y = logoIV.y+logoIV.height+15
        l.textColor = .lightGray
        l.textAlignment = .center
        return l
    }()
    
    lazy var logoIV: HWLogo = {
        let iv = HWLogo.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 110))
        iv.centerX = SCREEN_WIDTH/2
        iv.centerY = SCREEN_HEIGHT/3
        
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = COLORFROMRGB(r: 240, 240, 240, alpha: 1)
        self.title =  DYLOCS("About")
        view.addSubview(logoIV)
        view.addSubview(appNameL)
       
        versionL.text = "--  V" + DYDeviceInfo.APP_VERSION + "  --"
        
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logoIV.stop()
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
