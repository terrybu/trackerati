//
//  AppDelegate.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let rootViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }
}

