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
    let info = QueryInfo()
    @IBOutlet weak var searchbar: NSTextField!
    @IBOutlet weak var loadprogress: NSProgressIndicator!
    @IBOutlet weak var orderbycombo: NSComboBox!
    @IBOutlet weak var backbutton: NSButton!
    @IBOutlet weak var enterbutton: NSButton!
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
        let search = searchbar.stringValue
        let orderby = orderbycombo.stringValue
        
        if(search.isEmpty) && (orderby.isEmpty){
            self.appDelegate?.info.jqlRawQuery  = "assignee=currentuser() and ((type = defect and status != closed) or (type!=defect and resolution is EMPTY))"
            self.appDelegate?.info.groupByField = "priority"
            appDelegate?.viewcontroller.loginwithcredentials()
        }
        else{
            newquery()
        }
    }
    
    @IBAction func goback(_ sender: Any) {
        self.appDelegate?.pop.close()
    }
    
    func newquery(){
        
        self.appDelegate?.info.jqlRawQuery  = searchbar.stringValue
        self.appDelegate?.info.groupByField = orderbycombo.stringValue
        appDelegate?.viewcontroller.loginwithcredentials()
    }
    
}
