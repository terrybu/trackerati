//
//  UIViewControllerExtension.swift
//  Trackerati
//
//  Created by Terry Bu on 6/17/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavUIToHackeratiColors() {
        self.navigationController?.navigationBar.barTintColor = UIColor(rgba: kHackeratiBlue)
        self.navigationController?.navigationBar.translucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        //To make the navbars match Hackerati blue exactly, translucent needs to be turned off
        //however, once you turn this off, navigationbar alignment begins to screw with tableview alignment in ProjectsVC and prevent floating button from working
        //thus we had to turn on extendedLayoutIncludesOpaqueBars
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName) as [NSObject : AnyObject]
    }
    
}
