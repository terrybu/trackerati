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

class MainViewController: UIViewController {
    
    weak var delegate: MainViewControllerDelegate?
    
    override func loadView()
    {
        super.loadView()
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()
        
        if let menuImage = UIImage(named: "MenuButton") {
            let menuButton = UIButton(frame: CGRect(origin: CGPointZero, size: menuImage.size))
            menuButton.showsTouchWhenHighlighted = false
            menuButton.setBackgroundImage(UIImage(named: "MenuButton"), forState: .Normal)
            menuButton.addTarget(self, action: "displayMenu:", forControlEvents: .TouchUpInside)
            let customBarButtonItem = UIBarButtonItem(customView: menuButton)
            navigationItem.leftBarButtonItem = customBarButtonItem
        }
    }
    
    // MARK: Button Selectors
    
    func displayMenu(button: UIBarButtonItem)
    {
        delegate?.didPressMenuButton(button)
    }
}

