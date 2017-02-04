//
//  CJInterpolation.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 16/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

protocol CJInterpolation: CJAlgorithm {
    associatedtype Input
    associatedtype Output
    
    func interpolate(at input: Input) -> Output
}

extension CJInterpolation {
    
    func estimateValue(at input: Self.Input) -> Self.Output {
        return self.interpolate(at: input)
    }
}
