//
//  HWHealthkitManager.swift
//  Hawa
//
//  Created by 丁永刚 on 2020/12/31.
//  Copyright © 2020 丁永刚. All rights reserved.
//

import UIKit
import HealthKit


class HWHealthkitManager: NSObject {

    static let shared: HWHealthkitManager = HWHealthkitManager()
    
    let healthStore: HKHealthStore = HKHealthStore()
    
    
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func auth(_ completion: @escaping(_ success:Bool, _ error:Error?)->Void ) -> Void {
        
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                            HKObjectType.quantityType(forIdentifier: .stepCount)!,
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
        
        healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func getCalorieFor(_ pre: NSPredicate, complication: @escaping(_ success:[Any?], _ error:Error?)->Void) -> Void {
        let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        let stepQ = HKStatisticsQuery.init(quantityType: type!, quantitySamplePredicate: pre, options: .cumulativeSum) { (query, statistics, err) in

            if err != nil{
                DispatchQueue.main.async {
                    complication([], err)
                }
            }else{
                let count = statistics?.sumQuantity()?.doubleValue(for: HKUnit.calorie())
                DispatchQueue.main.async {
                    complication([count], nil)
                }
            }
        }
        self.healthStore.execute(stepQ)
    }
    
    func getStepsFor(_ pre: NSPredicate, complication: @escaping(_ success:[Any?], _ error:Error?)->Void) -> Void {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)
        let stepQ = HKStatisticsQuery.init(quantityType: type!, quantitySamplePredicate: pre, options: .cumulativeSum) { (query, statistics, err) in
            
            if err != nil{
                DispatchQueue.main.async {
                    complication([], err)
                }
            }else{
                let count = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    complication([count], nil)
                }
            }
        }
        self.healthStore.execute(stepQ)

    }

    func getStepsCollection(_ pre: NSPredicate, complication: @escaping(_ success:[Double], _ error:Error?)->Void) -> Void {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)

        let now = Date()
        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -6), to: now)!
        let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)

        let query = HKStatisticsCollectionQuery.init(quantityType: type!, quantitySamplePredicate: pre, options: HKStatisticsOptions.cumulativeSum, anchorDate: startOfSevenDaysAgo, intervalComponents: DateComponents(day:1))
        
        query.initialResultsHandler = { query, collection, err in
            if err != nil{
                DispatchQueue.main.async {
                    complication([], err)
                }
            }else{
                
                var steps: [Double] = []
                collection?.enumerateStatistics(from: startOfSevenDaysAgo, to: now, with: { (statistics, stop) in
                    
                    if let quantity = statistics.sumQuantity() {
                        let stepValue = quantity.doubleValue(for: HKUnit.count())
                        steps.append(stepValue)
                    }
                })
                
                DispatchQueue.main.async {
                    complication(steps, nil)
                }
            }
        }
        
        self.healthStore.execute(query)
        
    }

    
    func getDistanceFor(_ pre: NSPredicate, complication: @escaping(_ success:[Any?], _ error:Error?)->Void) -> Void {
        
        let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)

        let stepQ = HKStatisticsQuery.init(quantityType: type!, quantitySamplePredicate: pre, options: .cumulativeSum) { (query, statistics, err) in
            
            if err != nil{
                DispatchQueue.main.async {
                    complication([], err)
                }
            }else{
                let count = statistics?.sumQuantity()?.doubleValue(for: HKUnit.meter())
                DispatchQueue.main.async {
                    complication([count], nil)
                }
            }
        }
        self.healthStore.execute(stepQ)
    }
    
    func getWalkTimeFor(_ pre: NSPredicate, complication: @escaping(_ success:[Any?], _ error:Error?)->Void) -> Void {
        
        let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)

        let stepQ = HKStatisticsQuery.init(quantityType: type!, quantitySamplePredicate: pre, options: .cumulativeSum) { (query, statistics, err) in
            
            if err != nil{
                DispatchQueue.main.async {
                    complication([], err)
                }
            }else{
                let count = statistics?.sumQuantity()?.doubleValue(for: HKUnit.meter())
                DispatchQueue.main.async {
                    complication([count], nil)
                }
            }
        }
        self.healthStore.execute(stepQ)
    }
    
    func predicateForToday() -> NSPredicate {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let pre = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictStartDate)
        return pre
    }
    
    func predicateForThisWeek() -> NSPredicate {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let pre = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictStartDate)
        return pre
    }
    
    func predicateForThisMonth() -> NSPredicate {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let pre = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictStartDate)
        return pre
    }
    func predicateForLastWeek() -> NSPredicate {
        let now = Date()
        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -8), to: now)!
        let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
        let pre = HKQuery.predicateForSamples(withStart: startOfSevenDaysAgo, end: now, options: HKQueryOptions.strictStartDate)
        return pre
    }
    
    func predicateForLastMonth() -> NSPredicate {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let pre = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: HKQueryOptions.strictStartDate)
        return pre
    }
    
    
}
