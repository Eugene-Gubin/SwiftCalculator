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
    let formatter = NSNumberFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    }
    
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
            if let _ = displayValue {
                invertDisplay()
            }
        } else {
            doOperation(sender.currentTitle)
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
        displayValue = brain.pushOperand(displayValue!)
        history.text = brain.history()
    }
    
    @IBAction func backspace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            display.text = dropLast(display.text!)
            
            if countElements(display.text!) == 0 {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        doOperation(sender.currentTitle)
    }
    
    func doOperation(operation: String!) {
        if let operation = operation {
            displayValue = brain.performOperation(operation)
            if displayValue != nil {
                display.text = display.text! + "="
            }
        }
        history.text = brain.history()
    }
    
    @IBAction func clean(sender: AnyObject) {
        brain.clear()
        displayValue = brain.evaluate() ?? 0
        history.text = brain.history()
    }
    
    var displayValue: Double? {
        get {
            return formatter.numberFromString(display.text!)?.doubleValue
        }
        set {
            if let nv = newValue {
                display.text = formatter.stringFromNumber(NSNumber(double: nv))
            } else {
                display.text = "N/A"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

