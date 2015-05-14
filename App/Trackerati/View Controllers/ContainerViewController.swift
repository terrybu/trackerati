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
    private let minimumSlideoutOffset: CGFloat = 50.0
    private let maxXToBeginPanGesture: CGFloat = 30.0
    private var currentMenuState = MenuState.NotShowing
    
    private var centerNavigationController: UINavigationController!
    private var centerViewController: MainViewController!
    private var sideMenuViewController: SideMenuViewController!
    
    private weak var edgePanGesture: UIPanGestureRecognizer!
    private weak var tapToReturnGesture: UITapGestureRecognizer!
    
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
        
        setupGestures()
    }
    
    func setupGestures()
    {
        let edgePanGesture = UIPanGestureRecognizer(target: self, action: "translateTopView:")
        edgePanGesture.maximumNumberOfTouches = 1
        self.centerNavigationController.view.addGestureRecognizer(edgePanGesture)
        self.edgePanGesture = edgePanGesture
        
        let tapToReturnGesture = UITapGestureRecognizer(target: self, action: "returnToMainScreen:")
        tapToReturnGesture.numberOfTapsRequired = 1
        tapToReturnGesture.numberOfTouchesRequired = 1
        tapToReturnGesture.enabled = false
        self.centerNavigationController.view.addGestureRecognizer(tapToReturnGesture)
        self.tapToReturnGesture = tapToReturnGesture
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
        
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations: {
                self.centerNavigationController.view.transform = targetTransform
            
            }, completion: { finished in
                self.tapToReturnGesture.enabled = animateIn
                
                if animateIn == true {
                    self.currentMenuState = .Showing
                }
                else {
                    self.currentMenuState = .NotShowing
                }
        })
    }
    
    // MARK: Gesture Recognizer Selectors
    
    func translateTopView(edgePanGesture: UIPanGestureRecognizer)
    {
        switch edgePanGesture.state
        {
        case .Began:
            let xLocationInView = edgePanGesture.locationInView(view).x
            let maxXTouchBoundary = centerNavigationController.view.frame.origin.x + maxXToBeginPanGesture
            if xLocationInView > maxXTouchBoundary {
                // Cancels gesture
                edgePanGesture.enabled = false
                edgePanGesture.enabled = true
            }
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
    
    func returnToMainScreen(tapGesture: UITapGestureRecognizer)
    {
        if self.currentMenuState == .Showing {
            animateToSideMenu(animateIn: false)
        }
    }
    
    // MARK: MainViewController Delegate
    
    func didPressMenuButton(button: UIBarButtonItem) {
        animateToSideMenu(animateIn: currentMenuState == .NotShowing)
    }
    
}
