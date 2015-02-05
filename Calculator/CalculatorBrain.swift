//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Eugene Gubin on 04.02.15.
//  Copyright (c) 2015 simbirsoft.com. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let operation, _):
                return operation
            case .BinaryOperation(let operation, _):
                return operation
            }
        }
    }
    
    private var knownOps = [String:Op]()
    private var knownConsts = [String:Double]()
    
    private var opStack = [Op]()

    init() {
        knownOps = [
            "×" : Op.BinaryOperation("×", *),
            "÷" : Op.BinaryOperation("÷", { $1 / $0 }),
            "+" : Op.BinaryOperation("+", +),
            "−" : Op.BinaryOperation("−", { $1 / $0 }),
            "√" : Op.UnaryOperation("√", sqrt),
            "sin" : Op.UnaryOperation("sin", sin),
            "cos" : Op.UnaryOperation("cos", cos),
            "⁺∕₋" : Op.UnaryOperation("⁺∕₋", -)
        ]
        
        knownConsts = [
            "π": M_PI
        ]
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps);
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let op1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let op2 = op2Evaluation.result {
                        return (operation(op1, op2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(operation: String) -> Double? {
        if let operation = knownOps[operation] {
            opStack.append(operation)
        }
        
        if let constant = knownConsts[operation] {
            opStack.append(Op.Operand(constant))
        }
        
        return evaluate()
    }
    
    func history() -> String {
        return " ".join(opStack.map { $0.description })
    }
    
    func clear() {
        opStack = [Op]()
    }
}