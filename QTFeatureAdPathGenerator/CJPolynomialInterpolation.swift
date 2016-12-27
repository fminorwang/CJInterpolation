//
//  CJPolynomialInterpolation.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 27/12/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

class CJPolynomialInterpolation: CJInterpolation {
    typealias T = Double
    
    var fixedPoints: [CJInterpolationPoint<T>]?
    
    private var _coefficients: [T]?
    
    func solve() {
        guard let _fixedPoints = self.fixedPoints else {
            return
        }
        
        _coefficients = []
        for i in 0..<self.pointCount {
            let _yi = _fixedPoints[i].value
            let _xi = _fixedPoints[i].input
            var _coef = _yi;
            for j in 0..<self.pointCount {
                if i == j {
                    continue
                }
                let _xj = _fixedPoints[j].input
                _coef = _coef / ( _xi - _xj )
            }
            _coefficients?.append(_coef)
        }
    }
    
    // f(x) =  sum( yi * pi(x - xj ) / pi ( xi - xj ) where j != i ) i = 0...n
    func interpolate(at input: T) -> T {
        guard let _fixedPoints = fixedPoints else {
            return 0.0
        }
        guard let _coefficients = _coefficients else {
            return 0.0
        }
        
        var _result = 0.0
        for i in 0..<self.pointCount {
            var _tempResult = _coefficients[i]
            for j in 0..<self.pointCount {
                if i == j {
                    continue
                }
                let _x = _fixedPoints[j].input
                _tempResult *= ( input - _x )
            }
            _result += _tempResult
        }
        return _result
    }
}
