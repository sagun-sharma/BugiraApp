//
//  QueryChange.swift
//  Bugira
//
//  Created by Sagun Sharma on 31/03/17.
//  Copyright © 2017 Sagun Sharma. All rights reserved.
//

import Cocoa

class QueryChange: NSViewController {
    var appDelegate = NSApplication.shared().delegate as? AppDelegate
    var someDict = [String : Int]()
    var session:URLSession? = nil
    let keychain = KeychainSwift()
    let number = 1
    var temptimer:Timer? = Timer()
    
    let info = QueryInfo()
    @IBOutlet weak var searchbar: NSTextField!
    @IBOutlet weak var loadprogress: NSProgressIndicator!
    @IBOutlet weak var orderbycombo: NSComboBox!
    @IBOutlet weak var backbutton: NSButton!
    @IBOutlet weak var enterbutton: NSButton!
    
    @IBOutlet var myview: NSView!
    
    /***********************************************************
     
     ************************************************************/
    override func viewDidLoad() {
        
        self.loadprogress.isHidden = true
        self.searchbar.placeholderString = "Query"
        
        self.orderbycombo.removeAllItems()
        self.orderbycombo.addItems(withObjectValues: ["priority","project","assignee","reporter"])
        
        super.viewDidLoad()
        
        // Do view setup here.
    }
    
    @IBAction func enter(_ sender: Any) {
        
        self.loadprogress.isHidden = false
        self.loadprogress.startAnimation(self)
        
        let searchquery = searchbar.stringValue
        
        if(searchquery.isEmpty){
            
        }
        newquery()
    }
    
    @IBAction func goback(_ sender: Any) {
        
        self.appDelegate?.pop.close()
    }
    
    func newquery(){
        //let config = URLSessionConfiguration.default
      self.appDelegate?.info.jqlRawQuery  = searchbar.stringValue
        self.appDelegate?.info.groupByField = orderbycombo.stringValue
        appDelegate?.viewcontroller.loginwithcredentials()
        
        /* let  user = keychain.get("bugirausername")
         let  pass = keychain.get("bugirapassword")
         
         let loginString = NSString(format: "%@:%@", user!, pass!)
         let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
         let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
         let authString = "Basic \(base64LoginString)"
         config.httpAdditionalHeaders = ["Authorization" : authString]
         
         if(session == nil)
         {
         session = URLSession(configuration: config)
         
         }
         appDelegate?.viewcontroller.executeQuery()
         */
    }
    
}
