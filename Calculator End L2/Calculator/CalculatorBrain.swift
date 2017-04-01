//
//  CalculatorBrain.swift
//  Calculator
//
//    Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import Foundation

func changeSign (operand: Double) -> Double {
    return -operand
}

func multiply (op1: Double, op2: Double) -> Double {
    return op1 * op2
}

struct CalculatorBrain {
    
    private var accumulator :Double?
    private var _description = " "
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation == nil ? false : true
        }
    }
    
    var description : (Double?, String) {
        get {
            return (accumulator, _description)
        }
    }
    
    private enum Operation {
        case constant (output: Double, description: String)
        case unaryOperation (output: (Double) -> Double, description: (Double)->String)
        case binaryOperation ((Double, Double) -> Double)
        case equals
    }
    
    private var operations : Dictionary <String,Operation> = [
            "π": Operation.constant (output: Double.pi, description: "\(Double.pi)"),
            "e": Operation.constant (output: M_E, description: "\(Double.pi)"),
            "√": Operation.unaryOperation (output: {sqrt($0)}, description: {"√\($0)"}),
            "cos": Operation.unaryOperation (output: {cos($0)}, description: {"cos(\($0))"}),
            "±": Operation.unaryOperation (output: {-$0}, description: {"-\($0)"}),
            "×": Operation.binaryOperation ({$0 * $1}),
            "÷": Operation.binaryOperation ({$0 / $1}),
            "+": Operation.binaryOperation ({$0 + $1}),
            "-": Operation.binaryOperation ({$0 - $1}),
            "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                _description = value.description
                accumulator = value.output
            case .unaryOperation (let function):
                if accumulator != nil {
                    _description = function.description (accumulator!)
                    accumulator = function.output (accumulator!)
                }
            case .binaryOperation (let function):
                if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation (function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func  performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
        accumulator =  pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        func perform (with secondOperand: Double) -> Double {
            return function (firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand (_ operand: Double){
        accumulator = operand
    }
    
    var result: Double? {
        get {
            print("description > \(_description)")
            return accumulator
        }
    }
}
