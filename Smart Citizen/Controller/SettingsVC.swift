//
//  SettingsVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import LTMorphingLabel

class SettingsVC: UIViewController {

    @IBOutlet weak var versionLabel: LTMorphingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.setVersionLabelDynamically()
    }
    
    // MARK: - Version Label
    func setVersionLabelDynamically() -> Void {
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
            dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                if let version = dict["CFBundleShortVersionString"] {
                    versionLabel.text = "Version: \(version as! String)"
                }
                else {
                    print("CFBundleShortVersionString is missing on info.plist!")
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
