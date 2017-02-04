//
//  CJAlgorithm.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 22/01/2017.
//  Copyright © 2017 fminor. All rights reserved.
//

import Foundation

struct CJAlgorithmData<InputType, OutputType> {
    var x: InputType
    var y: OutputType
}

struct CJInterpolationPoint<T> {
    public var input: Double
    public var value: T
    
    init(input: Double, value: T) {
        self.input = input
        self.value = value
    }
}

protocol CJAlgorithm {
    associatedtype Input
    associatedtype Output
    
    var fixedPoints: [CJAlgorithmData<Input, Output>]? { get set }
    
    var pointCount: Int { get }
    
    func solve()
    func estimateValue(at input: Input) -> Output
}

extension CJAlgorithm {
    var pointCount: Int {
        guard let _fixedPoints = self.fixedPoints else {
            return 0
        }
        return _fixedPoints.count
    }
}
