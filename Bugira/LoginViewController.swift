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
    var eventMonitor: EventMonitor?
    let keychain = KeychainSwift()
    var myuser = String()
    var mypass = String()
    var session:URLSession? = nil
    var firstlogin = true
    var queryChange = QueryChange()
    var tempDict = [String : Int]()
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var loginbutton: NSButton!
    @IBOutlet weak var logo: NSImageView!
    
    @IBOutlet weak var loadprogress: NSProgressIndicator!
    override func viewDidLoad() {
        self.loadprogress.isHidden = true
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
        self.loadprogress.isHidden = false
        self.loadprogress.startAnimation(self)
        login()
        
        _ = Timer.scheduledTimer(timeInterval: Double(number*100), target: self, selector: #selector(loginwithcredentials), userInfo: nil, repeats: true)
        
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
        self.loadprogress.isHidden = false
        self.loadprogress.startAnimation(self)
        login()
        _ = Timer.scheduledTimer(timeInterval: Double(number*100), target: self, selector: #selector(loginwithcredentials), userInfo: nil, repeats: true)
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
        let user = keychain.get("bugirausername")
        let pass = keychain.get("bugirapassword")
        
        if(myuser == user) && (mypass == pass){
            
        }
        else{
            if(myuser != user) || (mypass != pass){
                keychain.delete("bugirausername")
                keychain.delete("bugirapassword")
                keychain.set(myuser, forKey: "bugirausername")
                keychain.set(mypass, forKey: "bugirapassword")
            }
        }
        
        executeQuery()
    }
    
    func loginwithcredentials(){
        let config = URLSessionConfiguration.default
        let user = keychain.get("bugirausername")
        let pass = keychain.get("bugirapassword")
        let loginString = NSString(format: "%@:%@", user!, pass!)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        if(session == nil)
        {
            session = URLSession(configuration: config)
            
        }
        
        executeQuery()
        
    }
    func executeQuery() {
        var jqlRawQuery = String()
        var groupBy = String()
        if(self.appDelegate?.info != nil){
            jqlRawQuery = (self.appDelegate?.info.jqlRawQuery)!
            groupBy = (self.appDelegate?.info.groupByField)!
        }
        let newQuery = "https://deepthought.guavus.com:9443/jira/rest/api/2/search?jql=\(jqlRawQuery)&startAt=0&maxResults=5000&fields=\(groupBy)&validateQuery=true"
        
        let rawquery :  String = newQuery.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        guard let requestURL = NSURL(string: rawquery) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = NSURLRequest(url: requestURL as URL)
        
        let task = session?.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            var httpResponse:HTTPURLResponse? = nil
            if(response != nil)
            {
                httpResponse = response as? HTTPURLResponse
            }
            else
            {
                self.appDelegate?.statusItem.title = "!"
            }
            
            let statusCode = httpResponse?.statusCode
            
            if (statusCode == 401){
                let alert = NSAlert()
                alert.messageText = "Please enter your correct credentials!"
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "CANCEL")
                alert.runModal()
            }
            
            if (statusCode == 404)
            {
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
                    self.keychain.set(self.myuser, forKey: "bugirausername")
                    self.keychain.set(self.mypass, forKey: "bugirapassword")
                    self.firstlogin = false
                }
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any]
                    
                    if let issues = json?["issues"] as? [[String: AnyObject]]
                    {
                        for issue in issues
                        {
                            if let fields = issue["fields"] as?  AnyObject
                            {
                                
                                if let groupByFieldObject = fields[groupBy] as? AnyObject
                                {
                                    if let name = groupByFieldObject["name"] as? String
                                    {
                                        self.tempDict[name] =  1 + (self.tempDict[name] ?? 0)
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
                
                // @TODO: You need to add comments.
                if(self.tempDict.isEmpty == true){
                    self.appDelegate?.statusItem.title = "0"
                }
                
                let toBeSortedArray = self.tempDict
                self.appDelegate?.statusItem.menu?.removeAllItems()
                var totalCount = 0
                let newmen = self.appDelegate?.statusItem.menu
                for (key,value) in Array(toBeSortedArray).sorted( by: {$0.key < $1.key}){
                    newmen?.addItem(withTitle: "\(key)  \(value)", action: #selector(self.appDelegate?.menuClick), keyEquivalent: "")
                    totalCount += value
                }
                
                newmen?.addItem(NSMenuItem.separator())
                newmen?.addItem(NSMenuItem(title: "Change Query ?", action: #selector(self.appDelegate?.newshow), keyEquivalent : ""))
                
                self.appDelegate?.statusItem.title = totalCount.description
                
                self.loadprogress.stopAnimation(self)
                
                self.appDelegate?.pop.close()
                self.tempDict.removeAll()
                
            }
        }
        
        task?.resume()
        
    }
}
