//
//  ViewController.swift
//  AwakeTimer
//
//  Created by Ranboo on 2017/3/9.
//  Copyright © 2017年 Ranboo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var preventSleepLabel: NSTextField!
    @IBOutlet weak var confirmButton: NSButton!
    @IBOutlet weak var howLongText: NSTextField!
    
    
    @IBAction func submit(_ sender: Any) {
        let minutes = howLongText.doubleValue
        if minutes > 0, let appDelegate = NSApp.delegate as? AppDelegate
        {
            appDelegate.myTimer = MyTimer(for: minutes)
            view.window?.close()
        }else{
            howLongText.stringValue = ""
            howLongText.placeholderString = "invalid"
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        preventSleepLabel.stringValue = NSLocalizedString("prevent_sleep_label", comment: "")
        confirmButton.title = NSLocalizedString("comfirm_buttom", comment: "")
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

