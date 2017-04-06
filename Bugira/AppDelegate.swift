//
//  AppDelegate.swift
//  Bugira
//
//  Created by Sagun Sharma on 27/02/17.
//  Copyright © 2017 Sagun Sharma. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let popover = NSPopover()
    let pop = NSPopover()
    var eventMonitor: EventMonitor?
    let menu = NSMenu()
    let keychain = KeychainSwift()
    let viewcontroller = LoginViewController()
    let cvc = QueryChange()
    let info = QueryInfo()
    func applicationDidFinishLaunching(_ aNotification: Notification)  {
        
        let loginflag = checkLogin()
        if(loginflag==true){
            viewcontroller.loginwithcredentials()
        }
        
        menu.addItem(NSMenuItem(title: "Login", action: #selector(showPopover), keyEquivalent: "L"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(applicationWillTerminate), keyEquivalent: "Q"))
        
        statusItem.menu = menu
        if let button = statusItem.button {
            button.image = NSImage(named: "bugicon")
            button.action = #selector(togglePopover)
        }
        popover.contentViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown])
        { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        eventMonitor?.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        NSApplication.shared().terminate(nil)
    }
    func togglePopover(sender: AnyObject?){
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    func newshow(sender : AnyObject?) {
    
        if let button = statusItem.button {
            
            pop.contentViewController = QueryChange(nibName : "QueryChange", bundle : nil  )
            print("hi")
            pop.show(relativeTo: button.bounds,of: button, preferredEdge: NSRectEdge.minY)
            pop.contentSize = NSSize(width: 380, height: 140)
            popover.close()
    }
    }
    
    func showPopover(sender: AnyObject?) {
        
        if let button = statusItem.button {
            
            popover.show(relativeTo: button.bounds,of: button, preferredEdge: NSRectEdge.minY)
            popover.contentSize = NSSize(width: 265, height: 175)
        }
        eventMonitor?.start()
        
    }
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
        
    }
    func menuClick(sender: NSMenuItem){
        
        let item = sender.title.components(separatedBy: "  ")
        
        let queryItem = item[0]
        var search = String()
        var groupby = String()
        search = (info.jqlRawQuery)!
        groupby = (info.groupByField)!
        if(groupby == "project"){
            let text = "\"\(queryItem)\""
            NSWorkspace.shared().open(NSURL(string: "jql= \(search) and \(groupby)=\(text)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)! as URL)
        }
        else{
            NSWorkspace.shared().open(NSURL(string: ?jql= \(search) and \(groupby)=\(queryItem)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)! as URL)
        }
    }
    func checkLogin () -> Bool {
        if ((keychain.get("bugirausername") != nil)) && ((keychain.get("bugirapassword") != nil))
        {
            return true
        }
        else
        {
            return false
        }
    }
}

