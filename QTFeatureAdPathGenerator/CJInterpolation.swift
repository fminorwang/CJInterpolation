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

protocol CJInterpolation {
    associatedtype T
    var fixedPoints: [CJInterpolationPoint<T>]? { get set }
    
    var pointCount: Int { get }
    
    var functionCount: Int { get }
    
    func solve()
    
    func interpolate(at input: T) -> T
}

extension CJInterpolation {
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
