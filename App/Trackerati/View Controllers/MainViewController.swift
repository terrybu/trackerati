//
//  ViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: class
{
    func didPressMenuButton(button: UIBarButtonItem)
}

class MainViewController: UIViewController, LoginScreenDelegate {
    
    weak var delegate: MainViewControllerDelegate?
    private weak var loginScreen: LoginScreen?
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        title = "Trackerati"
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView()
    {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "MenuButton"), style: .Plain, target: self, action: "displayMenu:")
        navigationItem.leftBarButtonItem = menuButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupInterfaceForLoggedInUser:", name: kUserDidAuthorizeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !GoogleLoginManager.sharedManager.attemptPreAuthorizationLogin() {
            var loginScreen = LoginScreen(delegate: self)
            self.presentViewController(loginScreen, animated: false, completion: nil)
            self.loginScreen = loginScreen
        }
    }
    
    func setupInterfaceForLoggedInUser(notification: NSNotification)
    {
        self.loginScreen?.dismissViewControllerAnimated(false, completion: nil)
        
        if let user = notification.object as? User {
            println(user.email)
        }
    }
    
    func displayMenu(button: UIBarButtonItem)
    {
        delegate?.didPressMenuButton(button)
    }
    
    // MARK: LoginScreen Delegate
    
    func didPressLoginButton()
    {
        GoogleLoginManager.sharedManager.login()
    }
    
}

