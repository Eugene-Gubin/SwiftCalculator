//
//  ViewController.swift
//  Calculator
//
//  Created by Евгений Губин on 01.02.15.
//  Copyright (c) 2015 simbirsoft.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    let brain = CalculatorBrain()
    
    lazy var formatter: NSNumberFormatter = {
        let fmt = NSNumberFormatter()
        fmt.numberStyle = NSNumberFormatterStyle.DecimalStyle
        return fmt
    }()
    
    @IBAction func appendDigit(sender: UIButton) {
        let isDot = sender.currentTitle! == "."
        let separator = formatter.decimalSeparator ?? "."
        let digitOrDot = isDot ? separator : sender.currentTitle!
        
        let text = display.text!
        if (isDot && text.rangeOfString(separator) != nil) {
            return
        }
        
        if (userIsInTheMiddleOfTypingANumber) {
            display.text = text + digitOrDot
        } else {
            display.text = isDot ? "0" + separator : digitOrDot
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func inverseNumber(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if let _ = displayValue.asValue() {
                invertDisplay()
            }
        } else {
            compute(sender.currentTitle, withMethod: brain.performOperation)
        }
    }
    
    func invertDisplay() {
        if display.text!.hasPrefix("-") {
            display.text = dropFirst(display.text!)
        } else {
            display.text = "-" + display.text!
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        compute(displayValue.asValue(), brain.pushOperand)
    }
    
    @IBAction func backspace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            display.text = dropLast(display.text!)
            
            if countElements(display.text!) == 0 {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        } else {
            performAction(brain.undo)
        }
    }
    
    // pi
    @IBAction func pushOperand(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        
        compute(sender.currentTitle, withMethod: brain.pushOperand)
    }
    
    @IBAction func operate(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        
        compute(sender.currentTitle, withMethod: brain.performOperation)
    }
    
    @IBAction func clean(sender: AnyObject) {
        performAction(brain.clear)
    }
    
    @IBAction func putIntoMemory(sender: UIButton) {
        brain.variableValues["M"] = displayValue.asValue()
        performAction(brain.evaluate)
    }

    @IBAction func pushM(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        
        compute("M", withMethod: brain.pushOperand)
    }
    
    func performAction(action: () -> Double?) {
        action()
        displayValue = brain.evaluateAndReportErrors()
        history.text = brain.description
    }
    
    func compute<T>(operation: T?, withMethod: (T) -> Double?) {
        if let op = operation {
            withMethod(op)
            displayValue = brain.evaluateAndReportErrors()
            history.text = brain.description
        }
    }
    
    var displayValue: CalculatorBrain.Result {
        get {
            let txt = display.text!
            if let value = formatter.numberFromString(txt)?.doubleValue {
                return .Value(value)
            } else {
                return .Error(txt)
            }
        }
        set {
            switch newValue {
            case .Value(let value):
                display.text = formatter.stringFromNumber(NSNumber(double: value))
            case .Error(let msg):
                display.text = msg
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

