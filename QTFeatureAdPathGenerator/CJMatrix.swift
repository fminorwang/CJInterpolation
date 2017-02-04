//
//  CJMatrix.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 04/02/2017.
//  Copyright © 2017 fminor. All rights reserved.
//

import Foundation

enum CJMatrixError: Error {
    case matrixNotInvertible
}

public struct CJMatrix {
    
    var values = [[Double]]()
    
    init(values: [[Double]]) {
        self.values = values
    }
    
    init(rowCount: Int, columnCount: Int) {
        for _ in 0..<rowCount {
            var _aRow = [Double]()
            for _ in 0..<columnCount {
                _aRow.append(0.0)
            }
            self.values.append(_aRow)
        }
    }
    
    var rowCount: Int {
        return values.count
    }
    
    var columnCount: Int {
        return values[0].count
    }
    
    subscript(row: Int, column: Int) -> Double {
        get {
            return self.values[row][column]
        }
        
        set {
            self.values[row][column] = newValue
        }
    }
    
    subscript(row: Int) -> [Double] {
        get {
            return self.values[row]
        }
        
        set {
            self.values[row] = newValue
        }
    }
}

extension CJMatrix: Equatable {
    
    public static func ==(lhs: CJMatrix, rhs: CJMatrix) -> Bool {
        assert(lhs.rowCount == rhs.rowCount && lhs.columnCount == rhs.columnCount, "matrix are not the same size!")
        
        for i in 0..<lhs.rowCount {
            for j in 0..<lhs.columnCount {
                if lhs[i][j] != rhs[i][j] {
                    return false
                }
            }
        }
        return true
    }
}

// MARK: 矩阵运算
extension CJMatrix {
    
    /// 矩阵加法
    public static func +(lhs: CJMatrix, rhs: CJMatrix) -> CJMatrix {
        assert(lhs.rowCount == rhs.rowCount && lhs.columnCount == rhs.columnCount, "matrix are not the same size!")
        
        var _result = CJMatrix(rowCount: lhs.rowCount, columnCount: lhs.columnCount)
        for i in 0..<lhs.rowCount {
            for j in 0..<lhs.columnCount {
                _result[i][j] = lhs[i][j] + rhs[i][j]
            }
        }
        return _result
    }
    
//    public static func +=(lhs: CJMatrix, rhs: CJMatrix) {
//        lhs = lhs + rhs
//    }
    
    /// 矩阵减法
    public static func -(lhs: CJMatrix, rhs: CJMatrix) -> CJMatrix {
        assert(lhs.rowCount == rhs.rowCount && lhs.columnCount == rhs.columnCount, "matrix are not the same size!")
        
        var _result = CJMatrix(rowCount: lhs.rowCount, columnCount: lhs.columnCount)
        for i in 0..<lhs.rowCount {
            for j in 0..<lhs.columnCount {
                _result[i][j] = lhs[i][j] - rhs[i][j]
            }
        }
        return _result
    }
    
//    public static func -=(lhs: CJMatrix, rhs: CJMatrix) {
//        lhs = lhs - rhs
//    }
    
    /// 矩阵乘法
    public static func *(lhs: CJMatrix, rhs: CJMatrix) -> CJMatrix {
        assert(lhs.columnCount == rhs.rowCount, "matrix are not multipliable")
        
        var _result = CJMatrix(rowCount: lhs.rowCount, columnCount: rhs.columnCount)
        for i in 0..<lhs.rowCount {
            for j in 0..<rhs.columnCount {
                var _value = 0.0;
                for k in 0..<lhs.columnCount {
                    _value += lhs[i][k] * rhs[k][j]
                }
                _result[i][j] = _value
            }
        }
        return _result
    }
    
    /// 矩阵转置
    public mutating func transpose() {
        
        var _newMatrix = CJMatrix(rowCount: self.columnCount, columnCount: self.rowCount)
        
        for i in 0..<self.rowCount {
            for j in 0..<self.columnCount {
                _newMatrix[j][i] = self.values[i][j]
            }
        }
        self.values = _newMatrix.values
    }
    
    /// 行列式
    public func det() -> Double {
        assert(self.rowCount == self.columnCount, "only matrix has the same rows and columns can compute det.")
        
        let _dimension = self.rowCount
        if _dimension == 0 {
            assertionFailure("dimension of the matrix is zero.")
        }
        
        if _dimension == 1 {
            return self.values[0][0]
        }
        
        var _result = 0.0
        for i in 0..<_dimension {
            let _remained = self.remainedMatrix(row: 0, column: i)
            let _sign = i % 2 == 0 ? 1 : -1
            _result += Double(_sign) * self.values[0][i] * _remained.det()
        }
        return _result
    }
    
    public func invertible() throws -> CJMatrix {
        if self.det() == 0.0 {
            throw CJMatrixError.matrixNotInvertible
        }
        return 1.0 / self.det() * self.adjugate()
    }
}

public func det(_ matrix: CJMatrix) -> Double {
    return matrix.det()
}

/// 数域运算
extension CJMatrix {
    public static func *(lhs: Double, rhs: CJMatrix) -> CJMatrix {
        var _result = CJMatrix(rowCount: rhs.rowCount, columnCount: rhs.columnCount)
        for i in 0..<rhs.rowCount {
            for j in 0..<rhs.columnCount {
                _result[i][j] = rhs[i][j] * lhs
            }
        }
        return _result
    }
}

extension CJMatrix {
    public func remainedMatrix(row: Int, column: Int) -> CJMatrix {
        assert(self.rowCount > 1 && self.columnCount > 1)
        
        var _result = CJMatrix(rowCount: self.rowCount - 1, columnCount: self.columnCount - 1)
        
        var _rowUpdate = 0
        var _columnUpdate = 0
        
        for i in 0..<self.rowCount {
            
            _columnUpdate = 0
            if i == row {
                _rowUpdate = -1
                continue
            }
            
            for j in 0..<self.columnCount {
                if j == column {
                    _columnUpdate = -1
                    continue
                }
                _result[i + _rowUpdate][j + _columnUpdate] = self[i][j]
            }
        }
        
        return _result
    }
    
    public func adjugate() -> CJMatrix {
        var _adjugateMatrix = CJMatrix(rowCount: self.columnCount, columnCount: self.rowCount)
        
        for i in 0..<self.rowCount {
            for j in 0..<self.columnCount {
                let _sign = ( i + j ) % 2 == 0 ? 1.0 : -1.0
                _adjugateMatrix[j][i] = self.remainedMatrix(row: i, column: j).det() * _sign
            }
        }
        return _adjugateMatrix
    }
}
