//
//  User.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 12/04/16.
//  Copyright © 2016 Mustafa Hastürk. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
  
  var id: Int = 0
  var fullName: String = ""
  var email: String = ""
  var password: String = ""
  var roleId =  1
  var roleName =  "Normal"
  var active =  true
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
    self.id = aDecoder.decodeObjectForKey("id") as! Int
    self.fullName = aDecoder.decodeObjectForKey("fullName") as! String
    self.email = aDecoder.decodeObjectForKey("email") as! String
    self.password = aDecoder.decodeObjectForKey("password") as! String
    self.roleId = aDecoder.decodeObjectForKey("roleId") as! Int
    self.roleName = aDecoder.decodeObjectForKey("roleName") as! String
    self.active = aDecoder.decodeObjectForKey("active") as! Bool
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.id, forKey: "id")
    aCoder.encodeObject(self.fullName, forKey: "fullName")
    aCoder.encodeObject(self.email, forKey: "email")
    aCoder.encodeObject(self.password, forKey: "password")
    aCoder.encodeObject(self.roleId, forKey: "roleId")
    aCoder.encodeObject(self.roleName, forKey: "roleName")
    aCoder.encodeObject(self.active, forKey: "active")
  }
  
  
}