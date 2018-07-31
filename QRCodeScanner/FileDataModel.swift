//
//  FileDataModel.swift
//  QRCodeScanner
//
//  Created by anuj garg on 05/07/18.
//  Copyright © 2018 anuj garg. All rights reserved.
//

import UIKit

class FileDataModel: NSObject {
    var isLogin:Bool
    var isLogout:Bool
    var logintime:String
    var id:String
    var logouttime:String
    var date:String
    
    override init()
    {
        isLogin = false
        isLogout = false
        logintime = ""
        logouttime = ""
        id = ""
        date = ""
    }
}
