//
//  Op.swift
//  DLVM
//
//  Created by Richard Wei on 12/25/16.
//
//

public enum ComparisonOp {
    case lessThan, lessThanOrEqualTo
    case greaterThan, greaterThanOrEqualTo
    case equalTo, notEqualTo
}

public enum BooleanOp {
    case and, or, xor
}

public enum ArithmeticOp {
    case add, subtract, multiply, divide, min, max
    case truncateDivide, floorDivide, modulo, power, mean
}

public enum ElementwiseOp {
    case sigmoid, tanh
    case log, exp, neg, sign, square, sqrt, round, rsqrt, ceil, floor
    case tan, cos, sin, acos, asin, atan
    case lgamma, digamma, erf, erfc, rint
}

public enum IntegrationOp {
    case softmax, logSoftmax, argmax, argmin
}

public enum UnaryOp {
    case elementwise(ElementwiseOp)
    case integration(IntegrationOp)
}

public enum AssociativeOp {
    case boolean(BooleanOp)
    case arithmetic(ArithmeticOp)
}

public enum BinaryOp {
    case associative(AssociativeOp)
    case comparison(ComparisonOp)
}

public enum OpKind {
    case unary(UnaryOp)        /// Monomorphic
    case binary(BinaryOp)      /// Monomorphic
    case matMul                /// Matrix multiplication
    case scan(AssociativeOp)   /// Scan
    case reduce(AssociativeOp) /// Reduce
    case concat                /// Concatenation
}

public extension OpKind {

    var argumentCount: Int {
        switch self {
        case .unary: return 1
        case .binary: return 2
        case .matMul: return 2
        case .reduce: return 1
        case .scan: return 1
        case .concat: return Int.max
        }
    }

    func resultShape(forArguments args: [TensorShape]) -> TensorShape? {
        guard !args.isEmpty else { return nil }
        switch self {
        case .concat:
            return args.dropFirst().reduce(args[0], { acc, x in acc?.concatenating(with: x) })
        case .unary where args.count == 1:
            return args[0]
        case .binary where args.count == 2:
            return args[0].mutuallyBroadcasted(with: args[1])
        case .scan, .reduce:
            return args[0]
        case .matMul:
            return args[0].matrixMultiplied(with: args[1])
        default:
            return nil
        }
    }

}
