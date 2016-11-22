//
//  AppDelegate.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 16/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//        let _interpolation = CJSplineInterpolation()
//        let _result = _interpolation.solveTridiagonalMetrix(a: [0.0, 1.0, 2.0],
//                                                            b: [10.0, 10.0, 10.0],
//                                                            c: [1.0, 2.0, 0.0],
//                                                            r: [2.0, 2.0, 2.0])
//        
//        NSLog("(%f, %f, %f)", _result[0], _result[1], _result[2])
        
        let _interpolation = CJSplineInterpolation()
        
        _interpolation.fixedPoints = [
            CJInterpolationPoint(input: 0.0, value: 2.0),
            CJInterpolationPoint(input: 1.0, value: 1.0),
            CJInterpolationPoint(input: 2.0, value: 3.0),
            CJInterpolationPoint(input: 3.0, value: 4.0),
            CJInterpolationPoint(input: 4.0, value: 4.5),
            CJInterpolationPoint(input: 5.0, value: 3.0)
        ]
        
        _interpolation.solve()
        for i in stride(from: 0.0, to: 5.0, by:0.1 ) {
            let _y = _interpolation.interpolate(at: i)
            NSLog("(%f, %f)", i, _y)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

