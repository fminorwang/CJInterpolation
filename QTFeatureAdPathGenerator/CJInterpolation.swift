//
//  CJInterpolation.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 16/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

class CJInterpolationPoint<T>: NSObject {
    public var input: Double
    public var value: T
    
    init(input: Double, value: T) {
        self.input = input
        self.value = value
    }
}

class CJInterpolation<T>: NSObject {
    var fixedPoints: Array<CJInterpolationPoint<T>>?
    var pointCount: Int {
        get {
            return (fixedPoints?.count)!
        }
    }
    
    var functionCount: Int {
        get {
            return self.pointCount - 1
        }
    }
}
