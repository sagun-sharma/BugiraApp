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
    let vc = LoginViewController()
    func applicationDidFinishLaunching(_ aNotification: Notification)  {
       
        let loginflag = checkLogin()
        if(loginflag==true){
          vc.loginwithcredentials()
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
        
       abort()
    }
    func togglePopover(sender: AnyObject?){
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    func test(sender : AnyObject?)
    {
        NSWorkspace.shared().open(NSURL(string: "".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)! as URL)
    }
      func test1(sender : AnyObject?)
    {
        NSWorkspace.shared().open(NSURL(string: "".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)! as URL)
    }
    
    func test2(sender : AnyObject?)
    {
        
        NSWorkspace.shared().open(NSURL(string: "".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)! as URL)
    }
    func test3(sender : AnyObject?)
    {
        if let viewcontroller = ChangeQuery(nibName : "ChangeQuery", bundle : nil  ){
            
            if let button = statusItem.button {
            pop.contentViewController = viewcontroller
            pop.show(relativeTo: button.bounds,of: button, preferredEdge: NSRectEdge.minY)
            pop.contentSize = NSSize(width: 380, height: 155)
            popover.close()
                
            }
         eventMonitor?.start()
            
            
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
    func closepop(sender: AnyObject?){
    self.pop.close()
    }
    func doNothing(sender: AnyObject?){
        
    }
    func checkLogin () -> Bool {
        if ((keychain.get("abcusername") != nil)) && ((keychain.get("abcpassword") != nil))
        {
            return true
        }
        else
        {
            return false
        }
    }
}

