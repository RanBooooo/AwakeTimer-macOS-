//
//  File.swift
//  MyCaffeinate
//
//  Created by Ranboo on 2017/3/8.
//  Copyright © 2017年 Ranboo. All rights reserved.
//

import Foundation

class MyTimer{
    
    private(set) var startTime: Date
    private(set) var endTime: Date
    private(set) var setValue: Double
   
    init(for minutes: Double){
        startTime = Date()
        let inSeconds = TimeInterval(minutes * 60)
        endTime = Date(timeInterval: inSeconds, since: startTime)
        setValue = minutes
    }
    
    func remainingMinutes() -> Int{
        var minutesLeft = Int(endTime.timeIntervalSince(Date())/60)
        if minutesLeft == 0{
            minutesLeft += 1
        }
        return minutesLeft
    }
    
}
