//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//
// Идея description заимствована https://github.com/m2mtech/calculator-2016

import Foundation

class CalculatorBrain{
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    var result: Double{
        get{
            return accumulator
        }
    }
    
    var variableValues = [String:Double]() {
        didSet {
            // if we change variables, re-run our program
            program = internalProgram
        }
    }

    private var currentPrecedence = Int.max
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }

    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = formatter.stringFromNumber(accumulator) ?? ""
        internalProgram.append(operand)
    }
    
    func setOperand(variable: String) {
        accumulator = variableValues[variable] ?? 0
        descriptionAccumulator = variable
        internalProgram.append(variable)
    }

    
    private var operations : [String: Operation] = [
        "rand": Operation.NullaryOperation(drand48, "rand()"),
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }, { "±(" + $0 + ")"}),
        "√": Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"}),
        "cos": Operation.UnaryOperation(cos,{ "cos(" + $0 + ")"}),
        "sin": Operation.UnaryOperation(sin,{ "sin(" + $0 + ")"}),
        "tan": Operation.UnaryOperation(tan,{ "tan(" + $0 + ")"}),
        "sin⁻¹" : Operation.UnaryOperation(asin, { "sin⁻¹(" + $0 + ")"}),
        "cos⁻¹" : Operation.UnaryOperation(acos, { "cos⁻¹(" + $0 + ")"}),
        "tan⁻¹" : Operation.UnaryOperation(atan, { "tan⁻¹(" + $0 + ")"}),
        "ln" : Operation.UnaryOperation(log, { "ln(" + $0 + ")"}),
        "x⁻¹" : Operation.UnaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"}),
        "х²" : Operation.UnaryOperation({$0 * $0}, { "(" + $0 + ")²"}),
        "×": Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷": Operation.BinaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+": Operation.BinaryOperation(+, { $0 + " + " + $1 }, 0),
        "−": Operation.BinaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ" : Operation.BinaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        "=": Operation.Equals
        
    ]
    
    private enum Operation{
        case NullaryOperation(() -> Double,String)
        case Constant(Double)
        case UnaryOperation((Double) -> Double,(String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
        
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        if let operation = operations[symbol]{
            switch operation {
            case .NullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executeBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executeBinaryOperation()
            
            }
        }
    }
    
    private func executeBinaryOperation(){
        
        if pending != nil{
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let symbol = op as? String {
                        if operations[symbol] != nil {
                             // symbol is an operation
                            performOperation(symbol)
                        } else {
                            // symbol is an variable
                            setOperand(symbol)
                        }

                    }
                }
            }
        }
    }
    
    func undoLast() {
        guard !internalProgram.isEmpty  else { return }
        internalProgram.removeLast()
        program = internalProgram
    }
    
   func clear() {
        accumulator = 0.0
        pending = nil
        descriptionAccumulator = " "
        currentPrecedence = Int.max
        internalProgram.removeAll()
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    func getVariable(symbol: String) -> Double? {
        return variableValues[symbol]
    }
    
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
}

let formatter:NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 6
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = " "
    formatter.locale = NSLocale.currentLocale()
    return formatter

} ()
