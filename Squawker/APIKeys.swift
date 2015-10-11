//
//  APIKeys.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/3/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import Foundation

func valueForAPIKey(key: String) -> String {
    let filepath = NSBundle.mainBundle().pathForResource("APIKeys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filepath!)
    
    let value: String = plist?.objectForKey(key) as! String
    return value
}
