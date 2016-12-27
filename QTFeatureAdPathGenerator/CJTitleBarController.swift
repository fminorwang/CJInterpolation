//
//  CJTitleBarController.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 24/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

let kNotificationNameStartInterpolation = "startInterpolation"
let kNotificationNameClearInterpolation = "clearInterpolation"

class CJTitleBarController: NSTitlebarAccessoryViewController {
    
    @IBOutlet weak var interpolationButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func _actionStartInterpolation(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNameStartInterpolation), object: nil)
    }
    
    @IBAction func _actionClear(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNameClearInterpolation), object: nil)
    }
}
