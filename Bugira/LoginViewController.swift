//
//  LoginViewController.swift
//  Bugira
//
//  Created by Sagun Sharma on 27/02/17.
//  Copyright © 2017 Sagun Sharma. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    let number = 1
    var appDelegate = NSApplication.shared().delegate as? AppDelegate
    let npopover = NSPopover()
    var eventMonitor: EventMonitor?
    let keychain = KeychainSwift()
    var oldCriticalCount = 0
    var oldMajorCount = 0
    var oldMinorCount = 0
    var myuser = String()
    var mypass = String()
    var session:URLSession? = nil
    var firstlogin = true
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var loginbutton: NSButton!
    @IBOutlet weak var logo: NSImageView!
    
    override func viewDidLoad() {
        self.username.placeholderString = "Username"
        self.password.placeholderString = "Password"
        let logoimage = NSImage(named : "logo")
        logo.image = logoimage
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func savelogin(_ sender: Any) {
        let localUserName = username.stringValue
        let localPassword = password.stringValue
        if(localUserName.isEmpty)||(localPassword.isEmpty){
            let alert = NSAlert()
            alert.messageText = "Please enter your username and password!"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "CANCEL")
            alert.runModal()
        }
        login()
          _ =  Timer.scheduledTimer(timeInterval: Double(number*900), target: self, selector: #selector(loginwithcredentials), userInfo: nil, repeats: true)
    }
    
       
    @IBAction func enterlogin(_ sender: Any) {
        let localUserName = username.stringValue
        let localPassword = password.stringValue
        if(localUserName.isEmpty)||(localPassword.isEmpty){
            let alert = NSAlert()
            alert.messageText = "Please enter your username and password!"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "CANCEL")
            alert.runModal()
        }
        login()
        _ =  Timer.scheduledTimer(timeInterval: Double(number*900), target: self, selector: #selector(loginwithcredentials), userInfo: nil, repeats: true)

    }
    func login(){
        let config = URLSessionConfiguration.default
        let localUserName = username.stringValue
        let localPassword = password.stringValue
        myuser = localUserName
        mypass = localPassword
        let loginString = NSString(format: "%@:%@", localUserName, localPassword)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        if(session == nil)
        {
            session = URLSession(configuration: config)
        
        }
        let user = keychain.get("abcusername")
        let pass = keychain.get("abcpassword")
        
        if(myuser == user) && (mypass == pass){
           
        }
        else{
            if(myuser != user) || (mypass != pass){
                keychain.delete("abcusername")
                keychain.delete("abcpassword")
                 keychain.set(myuser, forKey: "abcusername")
                 keychain.set(mypass, forKey: "abcpassword")
            }
        }

        sendNotification()
        }
    
    func loginwithcredentials(){
        let config = URLSessionConfiguration.default
        let user = keychain.get("abcusername")
        let pass = keychain.get("abcpassword")
        let loginString = NSString(format: "%@:%@", user!, pass!)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        if(session == nil)
        {
            session = URLSession(configuration: config)
        
        }
    sendNotification()
    
}
    func sendNotification() {
        var newCriticalCount = 0
        var newMajorCount = 0
        var newMinorCount = 0
        let todoEndpoint: String = "".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        guard let requestURL = NSURL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(url: requestURL as URL)
        
        let task = session?.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            var httpResponse:HTTPURLResponse? = nil
            if(response != nil){
           
            httpResponse = response as! HTTPURLResponse
                
            }
            else{
               self.appDelegate?.statusItem.title = "!"
            }
            let statusCode = httpResponse?.statusCode
            
            if (statusCode == 401){
                let alert = NSAlert()
                alert.messageText = "Please enter your correct credentials!"
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "CANCEL")
                alert.runModal()
               // NSApplication.shared().beginSheet(alert.window, modalFor: , modalDelegate: Any?, didEnd: Selector?, contextInfo: UnsafeMutableRawPointer!)
             
            }
        
            if (statusCode == 404){
                let alert = NSAlert()
                alert.messageText = "URL Not found!"
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "CANCEL")
                alert.runModal()
                return
            
            }
            if (statusCode == 200){
                self.appDelegate?.popover.close()
                if(self.firstlogin == true){
                self.keychain.set(self.myuser, forKey: "abcusername")
                self.keychain.set(self.mypass, forKey: "abcpassword")
                    self.firstlogin = false
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any]
                    
                    if let issues = json?["issues"] as? [[String: AnyObject]]
                    {
                        
                        for issue in issues
                        {
                            
                            if let fields = issue["fields"] as? AnyObject
                            {
                                
                                if let prio = fields["priority"] as? AnyObject
                                {
                                    if let id = prio["id"] as? String
                                    {
                                        
                                        if id.isEqual("2")
                                        {
                                            newCriticalCount = newCriticalCount + 1
                                        }
                                        if id.isEqual("3"){
                                            newMajorCount = newMajorCount + 1
                                        }
                                        if id.isEqual("4"){
                                            newMinorCount = newMinorCount+1
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                catch
                {
                    print("error serializing JSON: \(error)")
                }
                let newCriticalCountText = newCriticalCount.description
                let newMajorCountText = newMajorCount.description
                let newMinorCountText = newMinorCount.description
                
                let newTotalCount = newCriticalCount + newMajorCount + newMinorCount
                let newTotalCountText = newTotalCount.description
                if(self.oldCriticalCount == newCriticalCount) && (self.oldMajorCount == newMajorCount) && (self.oldMinorCount == newMinorCount){
                    
                }
                  else
                {
                    //this is a case where old defects assigned are changed when new defects come
                    //So now we need to remove older menu items containing old issues values and replace with the new ones
                    //assigns new menu
                  
                    // Create a banner notification for new defects count
                    let notification: NSUserNotification = NSUserNotification()
                    notification.title = "Your pending Issues :"
                    notification.subtitle = " Critical = \(newCriticalCountText)"  + " Major = \(newMajorCountText)"  +  " Minor = \(newMinorCountText)"
                    
                    notification.soundName = NSUserNotificationDefaultSoundName
                    notification.deliveryDate = NSDate(timeIntervalSinceNow: Double(self.number)) as Date
                    let notificationCenter = NSUserNotificationCenter.default
                    
                    notificationCenter.deliver(notification)
                }
                self.oldCriticalCount = newCriticalCount
                self.oldMajorCount = newMajorCount
                self.oldMinorCount = newMinorCount
                
                self.appDelegate?.statusItem.menu?.removeAllItems()
                let newmen = self.appDelegate?.statusItem.menu
                newmen?.addItem(NSMenuItem(title: "Critical  \(newCriticalCountText)", action: #selector(self.appDelegate?.test), keyEquivalent : "newCriticalCountText"))
                newmen?.addItem(NSMenuItem(title: "Major    \(newMajorCountText)", action: #selector(self.appDelegate?.test1), keyEquivalent : "newMajorCountText"))
                newmen?.addItem(NSMenuItem(title: "Minor    \(newMinorCountText)", action: #selector(self.appDelegate?.test2), keyEquivalent : "newMinorCountText"))
                newmen?.addItem(NSMenuItem(title: "Change query   ?? ", action: #selector(self.appDelegate?.test3), keyEquivalent : "!!!!!"))
                self.appDelegate?.statusItem.title = newTotalCountText
            }
        }
        
        task?.resume()
       
    }
    
}
