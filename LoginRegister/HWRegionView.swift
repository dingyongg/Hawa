//
//  FSRegionView.swift
//  Fresh
//
//  Created by 丁永刚 on 2021/2/4.
//

import UIKit

@objc protocol FSRegionViewDelegate {
    func regionView(didSelected value: String) -> Void
}

class HWRegionView: UIView, UIGestureRecognizerDelegate{
    
    let dataS = [
        "91",
        "63",
        "966",
        "971",
        "84",
        "65",
        "66",
        "44",
        "60",
        "673",
        "81",
        "82",
        "886",
        "960",
        "965",
    ]
    
    weak var delegate:FSRegionViewDelegate?
    
    var anchorPoint: CGPoint?
    var tb:UITableView?
    lazy var container: UIView  = {
        
        tb = UITableView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 70, height: 0)), style: .plain)
        tb?.delegate = self
        tb?.dataSource =  self
        tb?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb?.separatorStyle  = .none
        tb?.backgroundColor = COLORFROMRGB(r: 86, 86, 86, alpha: 1)
        tb?.layer.cornerRadius = 10
        let container =  UIView.init(frame: CGRect.init(origin: self.anchorPoint ?? CGPoint.zero , size: CGSize.init(width: 70, height: 0)))
        container.addSubview(tb ?? UIView())
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 10
        container.layer.cornerRadius = 10
        return container
    }()
    

    init(_ anchorPoint: CGPoint) {
        self.anchorPoint = anchorPoint
        super.init(frame: SCREEN_BOUNDS )
        addSubview(container)
        self.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapA))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    @objc func tapA(_ sender: UIGestureRecognizer) -> Void {
        removeFromSuperview()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        
        let touch = event.allTouches?.first
        if  (touch?.view?.isDescendant(of: container))!{
            return false
        }
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() -> Void {
        UIView.window().addSubview(self)
        UIView.animate(withDuration: 0.4) {
            self.container.height = 140
            self.tb?.height = 140
        } completion: { (fini) in
        }
    }
    
    
    deinit {
        print("deinit" + String(describing: self))
    }
    
}

extension HWRegionView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataS[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.removeFromSuperview()
        delegate?.regionView(didSelected: dataS[indexPath.row] )
    }
}
