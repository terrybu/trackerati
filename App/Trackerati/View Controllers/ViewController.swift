//
//  ViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        
        // Set up UI here
        var signinButton = UIButton(frame: CGRect(x: 100.0, y: 250.0, width: 100.0, height: 40.0))
        signinButton.center = view.center
        signinButton.setTitle("Sign In", forState: .Normal)
        signinButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        signinButton.addTarget(self, action: "signIn", forControlEvents: .TouchUpInside)
        view.addSubview(signinButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func signIn()
    {
        GoogleLoginManager.sharedManager.login()
    }
}

