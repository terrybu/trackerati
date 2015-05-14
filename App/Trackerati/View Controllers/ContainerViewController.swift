//
//  ContainerViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

enum MenuState
{
    case NotShowing
    case Showing
}

class ContainerViewController : UIViewController, MainViewControllerDelegate
{
    private let minimumSlideoutOffset: CGFloat = 60.0
    private var currentMenuState = MenuState.NotShowing
    
    private var centerNavigationController: UINavigationController!
    private var centerViewController: MainViewController!
    private var sideMenuViewController: SideMenuViewController!
    private weak var edgePanGesture: UIScreenEdgePanGestureRecognizer!
    
    init(centerViewController: MainViewController, sideMenuViewController: SideMenuViewController)
    {
        super.init(nibName: nil, bundle: nil)
        self.centerViewController = centerViewController
        self.centerViewController.delegate = self
        self.sideMenuViewController = sideMenuViewController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        view.insertSubview(sideMenuViewController.view, atIndex: 0)
        addChildViewController(sideMenuViewController)
        sideMenuViewController.didMoveToParentViewController(self)
        
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "translateTopView:")
        edgePanGesture.edges = .Left
        edgePanGesture.maximumNumberOfTouches = 1
        self.centerNavigationController.view.addGestureRecognizer(edgePanGesture)
        self.edgePanGesture = edgePanGesture
    }
    
    func animateToSideMenu(#animateIn: Bool)
    {
        let targetTransform: CGAffineTransform
        if animateIn {
            let newXPosition = centerViewController.view.frame.size.width - minimumSlideoutOffset
            targetTransform = CGAffineTransformMakeTranslation(newXPosition, 0.0)
        }
        else {
            targetTransform = CGAffineTransformIdentity
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.centerNavigationController.view.transform = targetTransform
        }, completion: { finished in
            if animateIn == true {
                self.currentMenuState = .Showing
            }
            else {
                self.currentMenuState = .NotShowing
            }
        })
    }
    
    func translateTopView(edgePanGesture: UIScreenEdgePanGestureRecognizer)
    {
        println("called")
        switch edgePanGesture.state
        {
        case .Changed:
            let newXPosition = edgePanGesture.locationInView(view).x
            let translation = CGAffineTransformMakeTranslation(newXPosition, 0.0)
            centerNavigationController.view.transform = translation
            
        case .Ended:
            if centerNavigationController.view.frame.origin.x < UIScreen.mainScreen().bounds.size.width / 2.0 {
                animateToSideMenu(animateIn: false)
            }
            else {
                animateToSideMenu(animateIn: true)
            }
        default:
            break
        }
    }
    
    // MARK: MainViewController Delegate
    
    func didPressMenuButton(button: UIBarButtonItem) {
        animateToSideMenu(animateIn: currentMenuState == .NotShowing)
    }
    
}
