//
//  HWMaterialEditingViewController.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/26.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import SwiftUI
import ImagePicker
import SwiftyJSON
import DatePickerDialog


class HWMaterialEditingViewController: HWBaseTableViewController, ImagePickerDelegate {
    
    var t1: JSON = [
        [
            "key":DYLOCS("Nickname"),
            "value": UserCenter.shared.theUser?.nickname
        ],
        [
            "key": DYLOCS("Personal profile"),
            "value":  UserCenter.shared.theUser?.profile
        ]
    ]
    var t2: JSON = [
        [
            "key": DYLOCS("Place of residence"),
            "value": UserCenter.shared.theUser?.city as Any
        ],
        [
            "key":DYLOCS("Height"),
            "value" :UserCenter.shared.theUser?.height as Any
        ],
        [
            "key":DYLOCS("Weight"),
            "value" : UserCenter.shared.theUser?.weight as Any
        ],
        [
            "key":DYLOCS("Birthday"),
            "value" : UserCenter.shared.theUser?.birthday as Any,
        ],
        [
            "key":DYLOCS("Emotional state"),
            "value" : UserCenter.shared.theUser?.maritalStatus as Any,
        ],
        [
            "key":DYLOCS("Purpose of making friends"),
            "value": "",
        ]
    ]
    
    // height values
    var hs: [Int] {
        get{
            var a: [Int] = []
            for i in 100..<300 {
                a.append(i)
            }
            return a
        }
    }
    
    // weight values
    var ws: [Int] {
        get{
            var a: [Int] = []
            for i in 30..<200 {
                a.append(i)
            }
            return a
        }
    }
    
    let ms: [String] = [DYLOCS("Secret"),DYLOCS("Single"),DYLOCS("In love"),DYLOCS("Married"),DYLOCS("Divorced") ]
    
    var proH: CGFloat{
        get{
            let nss =  t1[1]["value"].string as NSString?
            let size = CGSize.init(width: SCREEN_WIDTH-70, height: 999)
            let arrs: [NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16) as Any
            ]
            let rect = nss?.boundingRect(with:size, options: .usesLineFragmentOrigin, attributes: arrs, context: nil)
            return (rect?.height ?? 0) + 60
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = DYLOCS("Editing materials") 
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableView.register(HWAvatarEdtTableViewCell.self, forCellReuseIdentifier: ID_MATERIAL_EDIT_AVATAR_TABLE_CELL)
        tableView.register(HWRegularEdtTableViewCell.self, forCellReuseIdentifier: ID_MATERIAL_EDIT_REGULAR_TABLE_CELL)
        tableView.showsVerticalScrollIndicator = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func updata(_ key: String, value: Any) -> Void {
        
        var p : [String: Any] = [:]
        p[key] = value
        
        UserCenter.shared.updateInfo(p) { (respond) in
        } fail: { (error) in
            SVProgressHUD.showError(withStatus: error.message)
        }
    }
    
    
    func descripForMaritalStatus(_ status: Int) -> String {
        switch status {
        case 0:
            return DYLOCS("Secret")
        case 1:
            return DYLOCS("Single")
        case 2:
            return DYLOCS("In love")
        case 3:
            return DYLOCS("Married")
        case 4:
            return DYLOCS("Divorced")
        default:
            return ""
        
        }
    }
    
    func MaritalStatusForDescripe(_ des: String) -> Int {
        switch des {
        case DYLOCS("Secret") :
            return 0
        case DYLOCS("Single"):
            return 1
        case DYLOCS("In love"):
            return 2
        case DYLOCS("Married"):
            return 3
        case DYLOCS("Divorced"):
            return 4
        default:
            return -1
        
        }
    }
    
    
}


extension HWMaterialEditingViewController{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let c = HWInputViewController()
        if indexPath.section == 0 {
            let imagePickerController = ImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.imageLimit = 1
            present(imagePickerController, animated: true, completion: nil)
            
        }else if indexPath.section == 1{
            
            c.title = t1[indexPath.row]["key"].string
            if indexPath.row == 0 { // nickname
                c.cb = { value in
                    self.t1[indexPath.row]["value"].string = value
                    tableView.reloadData()
                    self.updata("nickname", value: value)
                }
            }else{
                c.cb = { value in
                    self.t1[indexPath.row]["value"].string = value
                    self.updata("profile", value: value)
                    tableView.reloadData()
                }
            }
            navigationController?.pushViewController(c, animated: true)
            
        }else {
            
            switch indexPath.row {
            case 0: // city
                let c = HWInputViewController()
                c.title = t2[indexPath.row]["key"].string
                c.cb = { value in
                    self.t2[indexPath.row]["value"].string = value
                    self.updata("city", value: value)
                    self.tableView.reloadData()
                }
                navigationController?.pushViewController(c, animated: true)
                break
            case 1: //height
                
                HWDataPicker().show(t2[indexPath.row]["key"].string!, data: hs) { (v) in
                    self.t2[indexPath.row]["value"].int = v as? Int
                    self.tableView.reloadData()
                    self.updata("height", value: v)
                }
                
                break
            case 2:  //weight
                HWDataPicker().show(t2[indexPath.row]["key"].string!, data: ws) { (v) in
                    self.t2[indexPath.row]["value"].int = v as? Int
                    self.tableView.reloadData()
                    self.updata("weight", value: v)
                }
                break
            case 3: // birthday
                
                let date =  Calendar.current.date(byAdding: .year, value: -20, to: Date())
                DatePickerDialog().show(DYLOCS("Choose Your Birthday"), doneButtonTitle: DYLOCS("Done"), cancelButtonTitle: DYLOCS("Cancel"), defaultDate: date!, minimumDate: nil, maximumDate: nil, datePickerMode: .date) { (date) in
                    if let dt = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let d = formatter.string(from: dt)
                        self.t2[indexPath.row]["value"].string = d
                        self.tableView.reloadData()
                        self.updata("birthday", value: d)
                    }
                }
                break
            case 4: //status
                HWDataPicker().show(t2[indexPath.row]["key"].string!, data: ms) { (v) in
                    
                    let m = self.MaritalStatusForDescripe(v as! String )
                    self.t2[indexPath.row]["value"].int = m
                    self.tableView.reloadData()
                    self.updata("weight", value: m )
                }
                break
            default:
                print("miss")
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_MATERIAL_EDIT_AVATAR_TABLE_CELL, for: indexPath) as! HWAvatarEdtTableViewCell
            cell.avartIV.image = UserCenter.shared.theUser?.headImage
            return cell
        }else if indexPath.section == 1{
            let  cell = tableView.dequeueReusableCell(withIdentifier: ID_MATERIAL_EDIT_REGULAR_TABLE_CELL, for: indexPath) as! HWRegularEdtTableViewCell
            cell.title = t1[indexPath.row]["key"].string
            if indexPath.row == 0 {
                cell.value = t1[indexPath.row]["value"].string
            }else{
                cell.subTitle = t1[indexPath.row]["value"].string
            }
            
            
            return cell
            
        }else {
            let  cell = tableView.dequeueReusableCell(withIdentifier: ID_MATERIAL_EDIT_REGULAR_TABLE_CELL, for: indexPath) as! HWRegularEdtTableViewCell
            cell.title = t2[indexPath.row]["key"].string
            
            switch indexPath.row {
            case 0:  //city
                cell.value =  t2[indexPath.row]["value"].string
            case 1:  //身高
                let v = t2[indexPath.row]["value"].int
                cell.value = v == nil ? "" :  String(format: "%d cm", v!)
            case 2:  //体重
                let v = t2[indexPath.row]["value"].int
                cell.value = v == nil ? "" :  String(format: "%d kg", v!)
            case 3: // 生日
                cell.value = t2[indexPath.row]["value"].string ?? ""
            case 4: // 情感状态
                let v = t2[indexPath.row]["value"].int
                cell.value = descripForMaritalStatus( v ?? 0 )
            default:
                print("miss")
            }
            
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return 2
        }else if section == 2{
            return 6
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }else if indexPath.section == 1 && indexPath.row == 1 {
            return proH
        }else{
            return 57
        }
    }
    
    
}


extension HWMaterialEditingViewController{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            dismiss(animated: true, completion: nil)
            //avatar.setImage(images[0], for: .normal)
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            
            if(images.count>0){
                SVProgressHUD.show()
                UserCenter.shared.upLoadImage(images[0]) { ( key) in
                    SVProgressHUD.dismiss()
                    self.updata("headImg", value: key)
                    UserCenter.shared.theUser?.headImage = images[0]
                    self.tableView.reloadData()
                } fail: { (error) in
                    SVProgressHUD.showError(withStatus: error.message)
                }
            }
        }
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
}
