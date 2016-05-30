//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/9/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var history: UILabel!
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var tochka: UIButton!{
        didSet {
            tochka.setTitle(decimalSeparator, forState: UIControlState.Normal)
        }
    }
    
    private var userIsInTheMiddleOfTyping = false
    let decimalSeparator = formatter.decimalSeparator ?? "."
    
    @IBOutlet weak var stack0: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var stack4: UIStackView!
    @IBOutlet weak var stack5: UIStackView!
    @IBOutlet weak var stack6: UIStackView!
    
    @IBOutlet weak var sin_1: UIButton!
    @IBOutlet weak var cos_1: UIButton!
    @IBOutlet weak var tan_1: UIButton!
    @IBOutlet weak var x_2: UIButton!
    @IBOutlet weak var plusMinusButton: UIButton!
    
    @IBOutlet weak var rand: UIButton!
    
    private lazy var buttonBlank:UIButton = {
        let button = UIButton(frame: CGRectMake(100, 400, 100, 50))
        button.backgroundColor = UIColor.blackColor()
        button.setTitle("", forState: UIControlState.Normal)
        return button
    }()

       
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            //----- Уничтожаем лидирующие нули -----------------
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  decimalSeparator) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //--------------------------------------------------

            if (digit != decimalSeparator) || (textCurrentlyInDisplay.rangeOfString(decimalSeparator) == nil) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double? {
        get {
            if let text = display.text,
                value = formatter.numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.stringFromNumber(value)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue{
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
    }
    
    @IBAction func clearAll(sender: UIButton) {
        brain.clearVariables()
        brain.clear()
        displayValue = nil
    }
    @IBAction func backspace(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping  = false
                displayValue = brain.result
            }
        } else {
            brain.undoLast()
            displayValue = brain.result
        }
    }
    
    @IBAction func plusMinus(sender: UIButton) {
        if userIsInTheMiddleOfTyping  {
            if (display.text!.rangeOfString("-") != nil) {
                display.text = String((display.text!).characters.dropFirst())
            } else {
                display.text = "-" + display.text!
            }
        } else {
            performOperation(sender)
        }
    }
    
    
    @IBAction func setM(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        if let value = displayValue {
            brain.setVariable(symbol, value: value)
            displayValue = brain.result
        }
    }
    

    @IBAction func pushM(sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        displayValue = brain.result
         }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection,
                     withTransitionCoordinator coordinator:UIViewControllerTransitionCoordinator) {
        
        super.willTransitionToTraitCollection(newCollection,
                                              withTransitionCoordinator: coordinator)
        configureView(newCollection.verticalSizeClass,buttonBlank:buttonBlank)
    }
    
    private func configureView(verticalSizeClass: UIUserInterfaceSizeClass, buttonBlank:UIButton) {
        if (verticalSizeClass == .Compact)  {
            stack2.addArrangedSubview(plusMinusButton)
            stack3.addArrangedSubview(sin_1)
            stack4.addArrangedSubview(cos_1)
            stack5.addArrangedSubview(tan_1)
            stack6.addArrangedSubview(x_2)
            stack0.addArrangedSubview(buttonBlank)
            stack1.hidden = true
        } else {
            stack1.hidden = false
            stack1.addArrangedSubview(plusMinusButton)
            stack1.addArrangedSubview(sin_1)
            stack1.addArrangedSubview(cos_1)
            stack1.addArrangedSubview(tan_1)
            stack1.addArrangedSubview(x_2)
            stack0.removeArrangedSubview(buttonBlank)
        }
    }
}

