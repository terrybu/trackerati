//
//  LogInScreen.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/13/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

protocol LoginScreenDelegate : class
{
    func didPressLoginButton()
}

class LoginScreen : UIViewController
{
    private let buttonTitle = "Log In"
    private let buttonFrame = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width - 10.0, height: 40.0)
    
    private weak var delegate: LoginScreenDelegate?
    private weak var loginButton: UIButton!

    init(delegate: LoginScreenDelegate)
    {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()
        
        self.setupLoginButton()
    }
    
    func setupLoginButton()
    {
        var loginButton = UIButton(frame: CGRectZero)
        loginButton.addTarget(self, action: "loginButtonPressed:", forControlEvents: .TouchUpInside)
        loginButton.setTitle(buttonTitle, forState: .Normal)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.backgroundColor = UIColor(red:0.2, green:0.6, blue:0.86, alpha:1)
        loginButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20.0)
        loginButton.layer.cornerRadius = 5.0
        loginButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addSubview(loginButton)
        let constraints = [NSLayoutConstraint(item: loginButton, attribute: .RightMargin, relatedBy: .Equal, toItem: view, attribute: .RightMargin, multiplier: 1.0, constant:0.0),
                           NSLayoutConstraint(item: loginButton, attribute: .LeftMargin, relatedBy: .Equal, toItem: view, attribute: .LeftMargin, multiplier: 0.92, constant: 0.0),
                           NSLayoutConstraint(item: loginButton, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 0.93, constant: 0.0)]
        view.addConstraints(constraints)
        
        self.loginButton = loginButton
    }
    
    func loginButtonPressed(button: UIButton)
    {
        if let viewDelegate = delegate {
            viewDelegate.didPressLoginButton()
        }
    }
    
}
