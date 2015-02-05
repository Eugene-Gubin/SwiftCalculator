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
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        history.text = brain.history()
    }
    
    @IBAction func operate(sender: UIButton) {
        if (userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        history.text = brain.history()
    }
    
    @IBAction func clean(sender: AnyObject) {
        brain.clear()
        displayValue = brain.evaluate() ?? 0
        history.text = brain.history()
    }
    
    var displayValue: Double {
        get {
            return formatter.numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = formatter.stringFromNumber(NSNumber(double: newValue))
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

