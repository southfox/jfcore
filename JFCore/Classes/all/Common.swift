//
//  Common.swift
//  JFCore
//
//  Created by Javier Fuchs on 5/25/16.
//  Copyright Â© 2016 fuchs. All rights reserved.
//

import Foundation
import UIKit

public class Common {

    public static var app : String = {
        guard let info = Bundle.main.infoDictionary,
            let bundleName = info["CFBundleName"] as? String else {
                return ""
        }
        return bundleName
    }()

    public class func synchronized(syncBlock:@escaping () -> Void) {
        objc_sync_enter(self)
        let concurrentQueue = DispatchQueue(label: Bundle.main.bundleIdentifier!, attributes: .concurrent)
        concurrentQueue.sync {
            syncBlock()
        }
        objc_sync_exit(self)
    }
    
    public class func randomColor(r : CGFloat? = nil, g : CGFloat? = nil, b : CGFloat? = nil) -> UIColor {
        let red = r ?? CGFloat(arc4random() % 255) / 255
        let green = g ?? CGFloat(arc4random() % 255) / 255
        let blue = b ?? CGFloat(arc4random() % 255) / 255
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
}
