//
//  CJLinearRegressionFitting.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 03/02/2017.
//  Copyright © 2017 fminor. All rights reserved.
//

import Foundation

// b = (X(T)X)-1 X(T)y

//class CJLinearRegressionFitting: CJFitting {
//    
//}

// y = b0 + b1 * x
class CJSimpleLinearRegressionFitting: CJFitting {
    typealias Input = Double
    typealias Output = Double
    
    var fixedPoints: [CJAlgorithmData<Double, Double>]?
    
    fileprivate var _b0: Double = 0.0
    fileprivate var _b1: Double = 0.0
    
    func solve() {
        guard let _fixedPoints = self.fixedPoints else {
            return
        }
        
        let _m = _fixedPoints.count
        var _X = CJMatrix(rowCount: _m, columnCount: 2)
        for i in 0..<_m {
            _X[i][0] = 1.0
            _X[i][1] = _fixedPoints[i].x
        }
        
        var _Y = CJMatrix(rowCount: _m, columnCount: 1)
        for i in 0..<_m {
            _Y[i][0] = _fixedPoints[i].y
        }
        
        var _XT = _X
        _XT.transpose()
        
        do {
            let _beta = try ( _XT * _X ).invertible() * _XT * _Y
            _b0 = _beta[0][0]
            _b1 = _beta[1][0]
        } catch {
            
        }
    }
    
    func estimateValue(at input: Double) -> Double {
        return _b0 + _b1 * input
    }
}
