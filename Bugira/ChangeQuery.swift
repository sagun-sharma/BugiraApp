//
//  ab.swift
//  Bugira
//
//  Created by Sagun Sharma on 28/03/17.
//  Copyright © 2017 Sagun Sharma. All rights reserved.
//

import Cocoa

class ChangeQuery: NSViewController {
     var appDelegate = NSApplication.shared().delegate as? AppDelegate
    var someDict = [String : Int]()
    var session:URLSession? = nil
    let keychain = KeychainSwift()
    let number = 1
    var temptimer:Timer? = Timer()
    var search = String()
    //var search = String
    
    @IBOutlet weak var loadprogress: NSProgressIndicator!
    @IBOutlet weak var searchbar: NSTextFieldCell!
    @IBOutlet weak var orderbycombo: NSComboBoxCell!
    override func viewDidLoad() {
        self.loadprogress.isHidden = true
        self.searchbar.placeholderString = "Query"
        self.orderbycombo.removeAllItems()
        self.orderbycombo.addItems(withObjectValues: ["project","assignee","reporter"])
        
        
                super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func goback(_ sender: Any) {
        self.appDelegate?.pop.close()
    }
    @IBAction func changeQueryHandler(_ sender: Any) {
      
        self.loadprogress.isHidden = false
        self.loadprogress.startAnimation(self)

        let searchquery = searchbar.stringValue
        
        if(searchquery.isEmpty){
            
        }
        newquery()
         self.temptimer = Timer.scheduledTimer(timeInterval: Double(number*30), target: self, selector: #selector(newquery), userInfo: nil, repeats: true)
    
    }
    func newquery(){
        let config = URLSessionConfiguration.default
        let searchquery = searchbar.stringValue
        self.search = searchquery
        print(search)
        let orderbyquery = orderbycombo.stringValue
        let  user = keychain.get("abcusername")
        let  pass = keychain.get("abcpassword")
        
        let loginString = NSString(format: "%@:%@", user!, pass!)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let authString = "Basic \(base64LoginString)"
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        if(session == nil)
        {
            session = URLSession(configuration: config)
            
        }
        
        let rawQuery = "https://deepthought.guavus.com:9443/jira/rest/api/2/search?jql=\(searchquery)&startAt=0&maxResults=5000&fields=\(orderbyquery)&validateQuery=true"
        appDelegate?.vc.queryInfo.todoEndpointRawQuery = rawQuery
        appDelegate?.vc.queryInfo.groupByField = orderbyquery
        appDelegate?.vc.executeQuery()
        let todoEndpoint: String = rawQuery.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        guard let requestURL = NSURL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(url: requestURL as URL)
        let task = session?.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            var httpResponse:HTTPURLResponse? = nil
            if(response != nil){
                httpResponse = response as? HTTPURLResponse
            }
            else{
                self.appDelegate?.statusItem.title = "!"
            }
            let statusCode = httpResponse?.statusCode
            if(statusCode == 200){
                
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any]
                        
                        
                        if let issues = json?["issues"] as? [[String: AnyObject]]
                        {
                            
                            for issue in issues
                            {
                                
                                if let fields = issue["fields"] as? AnyObject
                                {
                                    
                                    if let x = fields[orderbyquery] as? AnyObject
                                    {
                                        if let name = x["name"] as? String
                                        {
                                            
                                            self.someDict[name] =  1 + (self.someDict[name] ?? 0)
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
                    self.loadprogress.isHidden = true
                    self.loadprogress.stopAnimation(self)
                    self.appDelegate?.pop.close()
                    
                    self.appDelegate?.statusItem.menu?.removeAllItems()
                    var totalCount = 0
                    let newmen = self.appDelegate?.statusItem.menu
                
                for (key,value) in self.someDict {
                        
                        
                        newmen?.addItem(NSMenuItem(title: "\(key) = \(value)", action: #selector(self.appDelegate?.menuClick), keyEquivalent : ""))
                        totalCount += value
                        
                    }
                    newmen?.addItem(NSMenuItem(title: "Change Query?", action: #selector(self.appDelegate?.newshow), keyEquivalent : ""))
                    self.someDict.removeAll()
                    self.appDelegate?.statusItem.title = totalCount.description
                
            }
        }
        
        task?.resume()
        
    }

    
}
