//
//  QueryInfo.swift
//  Bugira
//
//  Created by Sagun Sharma on 30/03/17.
//  Copyright © 2017 Sagun Sharma. All rights reserved.
//

import Foundation

class QueryInfo{
    
    var jqlRawQuery : String! = "assignee=currentuser() and ((type = defect and status != closed) or (type!=defect and resolution is EMPTY))"

    var groupByField: String! = "priority"
   
    
   }
