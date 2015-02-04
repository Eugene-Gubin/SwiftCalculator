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

    var userIsInTheMiddleOfTypingANumber: Bool = false
    let brain = CalculatorBrain()
    let formatter = NSNumberFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if (userIsInTheMiddleOfTypingANumber) {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func appendDot(sender: UIButton) {
        let text = display.text!
        let separator = formatter.decimalSeparator ?? "."
        
        if (text.rangeOfString(separator) != nil) {
            return
        }
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = text + separator
        } else {
            display.text = "0" + separator
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

