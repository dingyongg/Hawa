//
//  HWWalkView.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/28.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import Charts

class HWWalkView: UIScrollView, ChartViewDelegate {

    var stepsCount: Int = 0{
        didSet{
            DispatchQueue.main.async {
                self.stepL.text = String(self.stepsCount)
            }
        }
    }
    
    lazy var stepL: UILabel = {
        let l = UILabel.init()
        l.textColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 63, weight: .semibold)
        return l
    }()
    
    lazy var step: UILabel = {
        let l = UILabel.init()
        l.text = "steps"
        l.textColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 17)
        return l
    }()
    
    lazy var topBg: UIImageView = {
        let i = UIImageView.init(frame: CGRect.init(x: 0, y: 20, width: SCREEN_WIDTH, height: 300))
        i.image = UIImage.init(named: "bg_walk")
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    lazy var collectionBtn: HawaBaseButton = {
        let b = HawaBaseButton.init(frame: .zero, title: DYLOCS("Collect diamonds"), image: nil, targte: self, action: #selector(onClick))
        b.backgroundColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
        b.titleWeight = .bold
        return b
    }()
    
    lazy var rewardV: HWStepReward = {
        let r = HWStepReward.init(frame: CGRect.init(x: HAWA_SCREEN_HORIZATAL_SPACE, y: 400, width: SCREEN_WIDTH-HAWA_SCREEN_HORIZATAL_SPACE-HAWA_SCREEN_HORIZATAL_SPACE, height: 130))
        return r
    }()
    
    let healthManager = HWHealthkitManager.init()
    
    lazy var dates: [String] = {
        var d: [String] = []
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        for i in 0..<7{
            let preDate = Calendar.current.date(byAdding: DateComponents(day:-i), to: startOfToday)
            let dataComponnet = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.day], from: preDate!)
            var dateStr = String(dataComponnet.month!) + "/" + String(dataComponnet.day!)
            
            if i == 0 {
                dateStr = DYLOCS("Today")
            }
            d.append(dateStr)
        }
        d.reverse()
        return d
    }()

    
    lazy var walkChart: LineChartView = {
        let c = LineChartView.init(frame: CGRect.init(x: 20, y: rewardV.y+rewardV.height+110 , width: SCREEN_WIDTH-40, height: 250))
        c.fitScreen()
        c.delegate = self
        c.noDataText = DYLOCS("No data")
        
        c.doubleTapToZoomEnabled = false //双击缩放
        c.pinchZoomEnabled = false

        let xAxis = c.xAxis
        xAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置X轴线宽
        xAxis.labelPosition = .bottom //X轴的显示位置，默认是显示在上面的
    
        xAxis.drawGridLinesEnabled = true;//不绘制网格线
        xAxis.gridColor = COLORFROMRGB(r: 217, 230, 226, alpha: 1)
        xAxis.spaceMin = 0;//设置label间隔
        xAxis.axisMinimum = 0
    
        xAxis.valueFormatter = IndexAxisValueFormatter.init(values: dates)
        xAxis.drawAxisLineEnabled = false
        
        c.rightAxis.enabled = false  //不绘制右边轴
        c.leftAxis.enabled = false
        let leftAxis = c.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.labelCount = 16 //Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = false //不强制绘制指定数量的label
        leftAxis.axisMinimum = 0 //设置Y轴的最小值
        leftAxis.drawZeroLineEnabled = true //从0开始绘制
        leftAxis.inverted = false //是否将Y轴进行上下翻转
        leftAxis.axisLineWidth = 1.0/UIScreen.main.scale //设置Y轴线宽
        leftAxis.axisLineColor = UIColor.cyan//Y轴颜色
        leftAxis.labelPosition = .outsideChart//label位置
        leftAxis.labelFont = UIFont.systemFont(ofSize: 10)//文字字体
        
        c.chartDescription?.textColor = UIColor.cyan  //描述字体颜色
        c.legend.form = .line  // 图例的样式
        c.legend.formSize = 20  //图例中线条的长度
        c.legend.textColor = UIColor.darkGray
        return c
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentSize = CGSize.init(width: SCREEN_WIDTH, height: 300+58+130+250+150 )
        showsVerticalScrollIndicator = false
        addSubview(topBg)
        addSubview(collectionBtn)
        addSubview(stepL)
        addSubview(step)
        addSubview(rewardV)
        addSubview(walkChart)
        
        stepL.text = "-"
        
        collectionBtn.snp.makeConstraints { (m) in
            m.leftMargin.equalTo(30)
            m.width.equalTo(SCREEN_WIDTH-60)
            m.height.equalTo(58)
            m.top.equalTo(topBg.snp.bottom)
        }
        
        stepL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.topMargin.equalTo(120)
        }
        step.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(stepL.snp.bottom)
        }
        
        let noteL = UILabel.init()
        noteL.text = "Today's data"
        noteL.textColor =  COLORFROMRGB(r: 71, 132, 116, alpha: 1)
        noteL.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        addSubview(noteL)
        
        noteL.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(rewardV.snp.bottom).offset(10)
        }
        
        
        let w = SCREEN_WIDTH/2
        let dis = HealthDataItem.init(frame: CGRect.init(x: 0, y: rewardV.y+rewardV.height+40, width: w, height: 50))
        dis.title = "Distance"
        
        let cal = HealthDataItem.init(frame: CGRect.init(x: w, y: rewardV.y+rewardV.height+40, width: w, height: 50))
        cal.title = "Calorie"
        
        addSubview(dis)
        addSubview(cal)
    
        if healthManager.isHealthDataAvailable()  {

            healthManager.auth({ (success, error) in
                if success{
                    
                    let pre = self.healthManager.predicateForToday()
                    self.healthManager.getCalorieFor(pre) { (result, error) in
                        if error == nil{
                            let s = result[0] as! Double
                            cal.value = String(Int(s))
                        }else{
                            cal.value = "1" + "kcal"
                        }
                    }
                    
                    self.healthManager.getStepsFor(pre) { (result, error) in
                        if error == nil{
                            let s = result[0] as! Double
                            self.stepsCount = Int(s)
                        }else{
                            self.stepsCount = 0
                        }
                    }
                    self.healthManager.getDistanceFor(pre) { (result, error) in
                        if error == nil{
                            let s = result[0] as! Double
                            dis.value = String(Int(s)) + "m"
                        }else{
                            cal.value = "0" + "m"
                        }
                    }
                    
                    
                    let preCollection = self.healthManager.predicateForLastWeek()
                    
                    self.healthManager.getStepsCollection(preCollection) { (result, erro) in
                        if erro != nil{
                            
                        }else{
                            var dataArray = [ChartDataEntry]()
                            for i in 0..<result.count {
                                let entry = ChartDataEntry.init(x: Double(i), y: result[i])
                                dataArray.append(entry)
                            }
                            let dataSet = LineChartDataSet.init(entries: dataArray, label: DYLOCS("Step") )
                            dataSet.colors = [COLORFROMRGB(r: 71, 132, 116, alpha: 1)]
                            dataSet.drawCirclesEnabled = false //是否绘制转折点
                            dataSet.lineWidth = 2
                            dataSet.mode = .horizontalBezier  //设置曲线是否平滑‚
                            dataSet.lineCapType = .round
                            self.walkChart.data = LineChartData.init(dataSet: dataSet)
                        }
                    }

                }else{
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
            })
                
        }else{
            SVProgressHUD.showInfo(withStatus: "Device not support for health kit")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onClick(_ sender: UIButton) -> Void {
        
        
        if UserCenter.shared.theUser?.stepDiamondtoken == 0 {
            if stepsCount <= 0 {
                SVProgressHUD.showError(withStatus: "No more steps")
            }else{
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
                UserCenter.shared.stepsDiamond(stepNumber: stepsCount) { (res) in
                    UserCenter.shared.theUser?.stepDiamondtoken = 1
                    let num =  res["receiveNumber"].int
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showSuccess(withStatus: "Collect Successfully " + String(num!) + "+" )
                } fail: { (err) in
                    SVProgressHUD.setDefaultMaskType(.none)
                    SVProgressHUD.showError(withStatus: err.message)
                }
            }
            
        }else{
            SVProgressHUD.showInfo(withStatus: "Diamonds Collected")
        }
    }
    
    class HealthDataItem:UIView{
        
        
        lazy var titleL: UILabel = {
            let l = UILabel.init()
            l.textColor = COLORFROMRGB(r: 153, 153, 153, alpha: 1)
            l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            return l
        }()
        
        
        lazy var valueL: UILabel = {
            let l = UILabel.init()
            l.textColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
            l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return l
        }()
        
        
        var title: String? {
            didSet{
                titleL.text = title
            }
        }
        
        var value: String?{
            didSet{
                valueL.text = value
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(titleL)
            addSubview(valueL)
            
            titleL.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.topMargin.equalTo(0)
            }
            valueL.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(titleL.snp.bottom).offset(8)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

}

class HWStepReward: UIView {
    
    let rewards = ["ic_tv", "ic_task_diamond","ic_task_diamond","ic_cupon","ic_task_diamond","ic_task_diamond","ic_box"]
    let dates = [DYLOCS("Mon"),DYLOCS("Tues"),DYLOCS("Wed"),DYLOCS("Thur"),DYLOCS("Fri"),DYLOCS("Sat"),DYLOCS("Sun")]
    
    
    lazy var title: UILabel = {
        let l = UILabel.init()
        l.text = DYLOCS("Walk to the diamond")
        l.textColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 17 , weight: .semibold)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = COLORFROMRGB(r: 239, 246, 244, alpha: 1)
        layer.cornerRadius = 17
        layer.masksToBounds = true
        
        addSubview(title)
        title.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.topMargin.equalTo(20)
        }
        
        let w = Int(frame.width) / rewards.count
        for i in 0..<rewards.count {
            let reward = Reward.init(frame: CGRect.init(x: i*w , y: 60, width: w, height: 50))
            reward.rewardImage = UIImage.init(named: rewards[i])
            reward.rewardDate = dates[i]
            addSubview(reward)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class Reward: UIView{
        
        lazy var icon: UIImageView = {
            let iv = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: 25))
            iv.contentMode = .scaleAspectFit
            return iv
        }()
        lazy var title: UILabel = {
            let l = UILabel.init()
            l.textColor = COLORFROMRGB(r: 71, 132, 116, alpha: 1)
            l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
            return l
        }()
        
        var rewardImage: UIImage?{
            didSet{
                icon.image = rewardImage
            }
        }
        var rewardDate = ""{
            didSet{
                title.text = rewardDate
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(icon)
            addSubview(title)
            
            icon.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalToSuperview()
                m.size.equalTo(CGSize.init(width: 25, height: 25))
            }
            title.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(icon.snp.bottom).offset(10)
            }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

