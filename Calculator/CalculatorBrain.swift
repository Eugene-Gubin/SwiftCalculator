//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Eugene Gubin on 04.02.15.
//  Copyright (c) 2015 simbirsoft.com. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable {
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double, Int)
        case Variable(String)
        
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let operation, _):
                return operation
            case .BinaryOperation(let operation, _, _):
                return operation
            case .Variable(let varName):
                return varName
            }
        }
    }
    
    private var knownOps = [String:Op]()
    private var knownConsts = [String:Double]()
    
    var variableValues = [String:Double]()
    
    private var opStack = [Op]()
    
    typealias PropertyList = AnyObject
    private var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else if let constant = knownConsts[opSymbol] {
                        newOpStack.append(.Operand(constant))
                    }
                }
                opStack = newOpStack
            }
        }
    }

    init() {
        knownOps = [
            "×" : Op.BinaryOperation("×", *, 3),
            "÷" : Op.BinaryOperation("÷", { $1 / $0 }, 3),
            "+" : Op.BinaryOperation("+", +, 1),
            "−" : Op.BinaryOperation("−", { $1 - $0 }, 2),
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
            case .BinaryOperation(_, let operation, _):
                let op1Evaluation = evaluate(remainingOps)
                if let op1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let op2 = op2Evaluation.result {
                        return (operation(op1, op2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let varName):
                if let value = variableValues[varName] ?? knownConsts[varName] {
                    return (value, remainingOps)
                }
            }
        }
        
        return (nil, ops)
    }
    
    private func evaluateSymbolically(ops: [Op]) -> (result: String, remainingOps: [Op], precedence: Int) {
        let highestPrecedence = Int.max
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            
            case .Operand(let operand):
                return ("\(operand)", remainingOps, highestPrecedence);
            
            case .UnaryOperation(let opSymbol, let operation):
                let operandEvaluation = evaluateSymbolically(remainingOps)
                return (opSymbol + "(\(operandEvaluation.result))", operandEvaluation.remainingOps, highestPrecedence)
            
            case .BinaryOperation(let opSymbol, let operation, let precedence):
                let (op1, op1Rems, op1Precedence) = evaluateSymbolically(remainingOps)
                let op1Sym = (op1Precedence < precedence) ? "(\(op1))" : op1
                let (op2, op2Rems, op2Precedence) = evaluateSymbolically(op1Rems)
                let op2Sym = (op2Precedence < precedence) ? "(\(op2))" : op2
                
                return ("\(op2Sym)\(opSymbol)\(op1Sym)", op2Rems, precedence)
                
            case .Variable(let varName):
                return (varName, remainingOps, highestPrecedence);
            }
        }
        
        return ("?", ops, highestPrecedence)
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    func performOperation(operation: String) -> Double? {
        if let operation = knownOps[operation] {
            opStack.append(operation)
        }
         
        return evaluate()
    }
    
    var description: String {
        if opStack.isEmpty {
            return ""
        }
        
        var expressions = [String]()
        
        var remainings = opStack
        do {
            let (expression, stack, _) = evaluateSymbolically(remainings)
            remainings = stack
            expressions.append(expression)
        } while (!remainings.isEmpty)
        
        return ",".join(expressions.reverse())
    }
    
    func clear() -> Double? {
        opStack = [Op]()
        variableValues = [String:Double]()
        return evaluate()
    }
}