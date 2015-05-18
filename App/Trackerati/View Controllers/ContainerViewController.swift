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

class ContainerViewController : UIViewController, MainViewControllerDelegate, SideMenuViewControllerDelegate
{
    private let minimumSlideoutOffset: CGFloat = 50.0
    private let maxXToBeginPanGesture: CGFloat = 30.0
    private var currentMenuState = MenuState.NotShowing
    private var currentShowingPage = SideMenuSelection.Home
    
    private var centerNavigationController: UINavigationController!
    private var centerViewController: MainViewController!
    private var sideMenuViewController: SideMenuViewController!
    
    private weak var edgePanGesture: UIPanGestureRecognizer!
    private weak var tapToReturnGesture: UITapGestureRecognizer!
    
    private weak var snapshotView: UIView?
    private var hideStatusBar = false
    
    init(centerViewController: MainViewController, sideMenuViewController: SideMenuViewController)
    {
        super.init(nibName: nil, bundle: nil)
        self.centerViewController = centerViewController
        self.centerViewController.delegate = self
        self.sideMenuViewController = sideMenuViewController
        self.sideMenuViewController.delegate = self
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
    
    private func setupGestures()
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
    
    private func animateToSideMenu(animateIn: Bool)
    {
        let targetTransform: CGAffineTransform
        if animateIn {
            let newXPosition = centerViewController.view.frame.size.width - minimumSlideoutOffset
            targetTransform = CGAffineTransformMakeTranslation(newXPosition, 0.0)
        }
        else {
            targetTransform = CGAffineTransformIdentity
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .CurveEaseInOut, animations: {
                self.centerNavigationController.view.transform = targetTransform
            
            }, completion: { finished in
                self.tapToReturnGesture.enabled = animateIn
                self.currentMenuState = animateIn ? .Showing : .NotShowing
        })
    }
    
    private func displaySnapshotView()
    {
        snapshotView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)
        centerNavigationController.view.addSubview(snapshotView!)
        hideStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func removeSnapshotView()
    {
        snapshotView?.removeFromSuperview()
        self.hideStatusBar = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: Gesture Recognizer Selectors
    
    @objc
    private func translateTopView(edgePanGesture: UIPanGestureRecognizer)
    {
        switch edgePanGesture.state
        {
        case .Began:
            if centerNavigationController.view.frame.origin.x == 0.0 { // make sure to only display snapshot when trying to display side menu
                displaySnapshotView()
            }
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
            let distanceNeededToAnimateFromLeft = UIScreen.mainScreen().bounds.size.width / 4.0
            let distanceNeededToAnimateFromRight =  distanceNeededToAnimateFromLeft * 3.0
            if centerNavigationController.view.frame.origin.x < distanceNeededToAnimateFromLeft || (centerNavigationController.view.frame.origin.x < distanceNeededToAnimateFromRight && currentMenuState == .Showing) {
                animateToSideMenu(false)
                removeSnapshotView()
            }
            else {
                animateToSideMenu(true)
            }
        default:
            removeSnapshotView()
            break
        }
    }
    
    @objc
    private func returnToMainScreen(tapGesture: UITapGestureRecognizer)
    {
        if self.currentMenuState == .Showing {
            animateToSideMenu(false)
            removeSnapshotView()
        }
    }
    
    // MARK: MainViewController Delegate
    
    func didPressMenuButton(button: UIBarButtonItem) {
        let sideMenuNotShowing = currentMenuState == .NotShowing
        if sideMenuNotShowing {
            displaySnapshotView()
            animateToSideMenu(sideMenuNotShowing)
        }
        else {
            animateToSideMenu(sideMenuNotShowing)
            removeSnapshotView()
        }
    }
    
    // MARK: SideMenuViewController Delegate
    
    func didMakePageSelection(selection: SideMenuSelection) {
        if currentShowingPage != selection {
            centerNavigationController.popViewControllerAnimated(false)
            
            var targetViewController: MainViewController?
            switch selection
            {
            case .Home:
                targetViewController = HomeViewController()
                
            case .History:
                break
                
            case .Settings:
                targetViewController = SettingsViewController()
                
            case .LogOut:
                // TODO: Sign person out
                break
            }
            
            if let target = targetViewController {
                if target.title == nil {
                    target.title = selection.rawValue
                }
                target.delegate = self
                centerNavigationController.pushViewController(target, animated: false)
                centerViewController = target
                
                currentShowingPage = selection
            }
        }
        
        animateToSideMenu(false)
        removeSnapshotView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return hideStatusBar
    }
    
}
