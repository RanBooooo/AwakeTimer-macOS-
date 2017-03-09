//
//  AppDelegate.swift
//  AwakeTimer
//
//  Created by Ranboo on 2017/3/9.
//  Copyright © 2017年 Ranboo. All rights reserved.
//

import Cocoa
import IOKit.pwr_mgt

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        createStatusItem()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        removeSystemTimer()
        removeStatusItem()
    }
    
    // MARK: Model
    var myTimer: MyTimer?{
        didSet{
            if oldValue != nil{
                removeSystemTimer()
            }
            if let timer = myTimer{
                if timer.endTime > Date(){
                    creatNoSleepAssertion("user's order")
                    setSystemTimer(timer.endTime.timeIntervalSince(Date()))
                }else {
                    print("指令错误")
                }
            }else{
                removeSystemTimer()
            }
        }
    }
    
    var systemTimer: Timer?
    
    private func setSystemTimer(_ time: TimeInterval){
        print("setSystemTimer")
        systemTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(releaseNoSleepAssertion), userInfo: nil, repeats: false)
    }
    
    private func removeSystemTimer(){
        releaseNoSleepAssertion()
        print("removeSystemTimer")
        systemTimer?.invalidate()
    }
   
    var isWorking: Bool{
        if let timer = myTimer, timer.endTime > Date() {
            return true
        }
        return false
    }

    
    // MARK: prevent idle sleep
    
    var assertionID: IOPMAssertionID?
    
    private func creatNoSleepAssertion(_ reason: String){
        let reasonForActivity: CFString = reason as CFString
        assertionID = IOPMAssertionID(10)
        let success: IOReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, UInt32(255), reasonForActivity, &assertionID!)
        if success == kIOReturnSuccess{
            //  now system wont sleep
            print("prevent sleep assertion create success")
        }
    }
    
    @objc private func releaseNoSleepAssertion(){
        
        if let id = assertionID {
            print("releaseNoSleepAssertion")
            IOPMAssertionRelease(id)
            assertionID = nil
            //The system will be able to sleep again.
        }
    }
    
//    var observer: Any?
//    
//    private func receiveWillSleepNotification(){
//        NSWorkspace.shared().notificationCenter.addObserver(forName: Notification.Name.NSWorkspaceWillSleep, object: nil, queue: OperationQueue.main){
//            [weak weakSelf = self] _ in
//            print(Date().description+"receiveWillSleepNotification")
//            if let id = weakSelf?.assertionID {
//                if (weakSelf?.isWorking)! {
//                    IOPMAssertionRetain(id)
//                    print("prevent sleep once")
//                }else{
//                    IOPMAssertionRelease(id)
//                }
//            }
//        }
//    }
//    
//    private func stopReceive(){
//        if let ob = observer{
//            NSWorkspace.shared().notificationCenter.removeObserver(ob)
//        }
//    }
    
    
    // MARK: UI StatusBar
    
    var statusItem: NSStatusItem?
    
    @IBOutlet weak var statusBarMenu: NSMenu! { didSet { statusBarMenu.delegate = self } }
    @IBOutlet weak var timerStatusMenuItem: NSMenuItem!
    @IBOutlet weak var setTimerMenuItem: NSMenuItem!
    @IBOutlet weak var cancelMenuItem: NSMenuItem!

    var windowController: NSWindowController?
    
    private func openWindow(_ sender: Any?){
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateController(withIdentifier: "default") as? ViewController{
            let newWindow = NSWindow(contentViewController: vc)
            newWindow.makeKeyAndOrderFront(sender)
            windowController = NSWindowController(window: newWindow)
        }else{
            print("creat window fail")
        }
    }
    
    @IBAction func setTimerClick(_ sender: NSMenuItem) {
        if isWorking{
            openWindow(sender)
            let vc = windowController?.contentViewController as! ViewController
            vc.howLongText.intValue = Int32(myTimer!.remainingMinutes())
        }else{
            openWindow(sender)
        }
    }
    
    @IBAction func cancelClick(_ sender: NSMenuItem) {
        if isWorking{
            myTimer = nil
        }else{
            NSApplication.shared().terminate(sender)
        }
    }
    
    func createStatusItem() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem?.menu = statusBarMenu
        let button = statusItem?.button
        button?.title = NSLocalizedString("AwakeTimer", comment: "title of icon in the top right status bar")
        
    }
    
    func removeStatusItem(){
        if let si = statusItem{
            NSStatusBar.system().removeStatusItem(si)
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        if isWorking{
            var mins = myTimer!.remainingMinutes()
            var hours = 0
            if (mins>60){
                hours = Int(mins/60)
                mins %= 60
            }
            var statusText = ""
            if hours>=1{
                statusText = MenuText.remaing+String(hours)+MenuText.hour+String(mins)+MenuText.minute
            }
            else{
                statusText = MenuText.remaing+String(mins)+MenuText.minute
            }
            timerStatusMenuItem.title = statusText
            setTimerMenuItem.title = MenuText.change
            cancelMenuItem.title = MenuText.cancel
            
        }else{
            timerStatusMenuItem.title = MenuText.unassigned
            setTimerMenuItem.title = MenuText.assign
            cancelMenuItem.title = MenuText.exist
        }
    }
    
    struct MenuText {
        static let unassigned = NSLocalizedString("notset", comment: "")
        static let remaing = NSLocalizedString("remain", comment: "")
        static let hour = NSLocalizedString("hour", comment: "")
        static let minute = NSLocalizedString("mintue", comment: "")
        static let change = NSLocalizedString("modify", comment: "")
        static let assign = NSLocalizedString("set", comment: "")
        static let cancel = NSLocalizedString("cancel", comment: "")
        static let exist = NSLocalizedString("exist", comment: "")
    }
}
