//
//  HomeViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

class HomeViewController : MainViewController, LoginScreenDelegate
{
    private weak var loginScreen: LoginScreen?
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        title = "Trackerati"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.redColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupInterfaceForLoggedInUser:", name: kUserDidAuthorizeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !GoogleLoginManager.sharedManager.authorized {
            if !GoogleLoginManager.sharedManager.attemptPreAuthorizationLogin() {
                var loginScreen = LoginScreen(delegate: self)
                self.presentViewController(loginScreen, animated: false, completion: nil)
                self.loginScreen = loginScreen
            }
        }
    }
    
    func setupInterfaceForLoggedInUser(notification: NSNotification)
    {
        self.loginScreen?.dismissViewControllerAnimated(false, completion: nil)
        
        if let user = notification.object as? User {
            println(user.email)
        }
    }
    
    // MARK: LoginScreen Delegate
    
    func didPressLoginButton()
    {
        GoogleLoginManager.sharedManager.login()
    }
}
