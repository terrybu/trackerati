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
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "MenuButton"), style: .Plain, target: self, action: "displayMenu:")
        navigationItem.leftBarButtonItem = menuButton
    }
    
    // MARK: Button Selectors
    
    func displayMenu(button: UIBarButtonItem)
    {
        delegate?.didPressMenuButton(button)
    }
}

