//
//  HWImgesContainer.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/11/18.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON


@objc enum HWImgesContainerImageDirection : Int{
    case landscape = 0
    case protrait = 1
}

@objc protocol HWImgesContainerDelegete {
    func imageContainer(_ container: HWImgesContainer, tapedIndex: Int) -> Void
    func imageContainerCalculated(_ container: HWImgesContainer, direction: HWImgesContainerImageDirection ) -> Void
}

class HWImgesContainer: UIView {
    
    let space: CGFloat = 6
    let landscape = CGSize.init(width: 283, height: 216)
    let protrait = CGSize.init(width: 216, height: 283)
    
    weak var delegete: HWImgesContainerDelegete?
    
    var imagesData: JSON = []{
        didSet{
            loadImages()
        }
    }
    
    init(_ images: JSON?) {
        super.init(frame: CGRect.zero)
        imagesData = images!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        print("layoutSubviews")
        
    }
    
    func loadImages () -> Void {
        print("loadImages")
        
        for v in subviews {
            v.removeFromSuperview()
        }
        
        if imagesData.count == 1  {

            let imagebtn = imageButton(0)
            let thumb = imagesData[0]["img"].string
            imagebtn.sd_setImage(with: URL.init(string: thumb! ), for: .normal) { (image, error, type, url) in
                if error == nil {
                    imagebtn.isEnabled = true
                    if self.getDirection(image: image!) == HWImgesContainerImageDirection.landscape {
                        imagebtn.frame = CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 0, width: self.landscape.width, height: self.landscape.height)
                        self.delegete?.imageContainerCalculated(self, direction: .landscape)
                    }else{
                        imagebtn.frame = CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 0, width: self.protrait.width, height: self.protrait.height)
                        self.delegete?.imageContainerCalculated(self, direction: .protrait)
                    }
                    self.size = imagebtn.bounds.size
                }
            }
            
            addSubview(imagebtn)
            
        } else if imagesData.count > 1{
            let imageWH = (SCREEN_WIDTH - HAWA_SCREEN_HORIZATAL_SPACE - HAWA_SCREEN_HORIZATAL_SPACE - space - space) / 3
            for i in 0..<imagesData.count {
                let div: Double  = Double(i / 3)
                let row = floor(div)
                print(row)
                let imagebtn = imageButton(i)
                imagebtn.sd_setImage(with: URL.init(string: imagesData[i]["img"].string!), for: .normal) { (u, e, t, url) in
                    imagebtn.isEnabled = true
                }
                addSubview(imagebtn)
                imagebtn.frame = CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE + (imageWH + space) * CGFloat(i%3)  , y: CGFloat(row) * (imageWH + space ) , width: imageWH, height: imageWH)
            }
            
            let line = (imagesData.count-1) % 3 + 1
            self.size = CGSize.init(width: SCREEN_WIDTH, height: (imageWH + space) * CGFloat(line))
            
        }
    }
    
    
    func getDirection(image: UIImage) -> HWImgesContainerImageDirection {
        if image.cgImage!.width > image.cgImage!.height {
            return .landscape
        }else{
            return .protrait
        }
    }
    
    func imageButton(_ tag: Int) -> ImageContainerButton {
        let b = ImageContainerButton.init(frame: .zero)
        b.imageView?.contentMode = .scaleAspectFill
        b.imageView?.layer.cornerRadius = 8
        b.imageView?.layer.masksToBounds = true
        b.tag = tag
        b.addTarget(self, action: #selector(imageTab), for: .touchUpInside)
        b.isEnabled = false
        return b
    }
    
    @objc func imageTab(sender: UIButton) -> Void {

        if delegete != nil {
            delegete?.imageContainer(self , tapedIndex: sender.tag)
        }
    }
    
}

class ImageContainerButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return self.bounds
    }
}
