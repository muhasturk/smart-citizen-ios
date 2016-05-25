/**
 * Copyright (c) 2016 Mustafa Hastürk
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

final class User: NSObject, NSCoding {
  
  var id: Int = 0
  var fullName: String = ""
  var email: String = ""
  var password: String = "" // hash this value
  var roleId = 10
  var roleName = "Normal"
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
    self.id = aDecoder.decodeObjectForKey("id") as! Int
    self.fullName = aDecoder.decodeObjectForKey("fullName") as! String
    self.email = aDecoder.decodeObjectForKey("email") as! String
    self.password = aDecoder.decodeObjectForKey("password") as! String
    self.roleId = aDecoder.decodeObjectForKey("roleId") as! Int
    self.roleName = aDecoder.decodeObjectForKey("roleName") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.id, forKey: "id")
    aCoder.encodeObject(self.fullName, forKey: "fullName")
    aCoder.encodeObject(self.email, forKey: "email")
    aCoder.encodeObject(self.password, forKey: "password")
    aCoder.encodeObject(self.roleId, forKey: "roleId")
    aCoder.encodeObject(self.roleName, forKey: "roleName")
  }
  
}