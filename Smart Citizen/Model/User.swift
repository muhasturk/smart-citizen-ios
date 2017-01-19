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
    self.id = aDecoder.decodeInteger(forKey: "id")
    self.fullName = aDecoder.decodeObject(forKey: "fullName") as! String
    self.email = aDecoder.decodeObject(forKey: "email") as! String
    self.password = aDecoder.decodeObject(forKey: "password") as! String
    self.roleId = aDecoder.decodeInteger(forKey: "roleId")
    self.roleName = aDecoder.decodeObject(forKey: "roleName") as! String
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.id, forKey: "id")
    aCoder.encode(self.fullName, forKey: "fullName")
    aCoder.encode(self.email, forKey: "email")
    aCoder.encode(self.password, forKey: "password")
    aCoder.encode(self.roleId, forKey: "roleId")
    aCoder.encode(self.roleName, forKey: "roleName")
  }
  
}
