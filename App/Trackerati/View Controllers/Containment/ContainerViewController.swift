//
//  ContainerViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

enum MenuState
{
    case NotShowing
    case Showing
}

class ContainerViewController : UIViewController, LoginScreenDelegate, MainViewControllerDelegate, SideMenuViewControllerDelegate
{
    private let loadingDetails = ["Fetching some goodies", "Looking through file cabinets", "Getting your awesome work!"]
    private let maxXToBeginPanGesture: CGFloat = 30.0
    private var currentMenuState = MenuState.NotShowing
    private var currentShowingPage = SideMenuSelection.Home
    
    private(set) var centerNavigationController: UINavigationController!
    private var centerViewController: MainViewController!
    private var sideMenuViewController: SideMenuViewController!
    
    private weak var edgePanGesture: UIPanGestureRecognizer!
    private weak var tapToReturnGesture: UITapGestureRecognizer!
    
    private weak var loginScreen: LoginScreen?
    private weak var snapshotView: UIView?
    private var hideStatusBar = false
    
    private var grayMask: UIView?
    
    init(centerViewController: MainViewController, sideMenuViewController: SideMenuViewController)
    {
        super.init(nibName: nil, bundle: nil)
        self.centerViewController = centerViewController
        self.centerViewController.delegate = self
        self.sideMenuViewController = sideMenuViewController
        self.sideMenuViewController.delegate = self
        setupNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView()
    {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        view.insertSubview(sideMenuViewController.view, atIndex: 0)
        addChildViewController(sideMenuViewController)
        sideMenuViewController.didMoveToParentViewController(self)
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerViewController.setNavUIToHackeratiColors()
        
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        setupGestures()
        displayLoginScreen()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let authorized = GoogleLoginManager.sharedManager.authorized
        loginScreen?.setLoginButtonEnabled(authorized)
        
        if !authorized {
            if !GoogleLoginManager.sharedManager.attemptPreAuthorizationLogin() {
                loginScreen?.setLoginButtonEnabled(true)
            }
            else {
                displayLoadingHUD(true)
            }
        }
    }
    
    // MARK: Private
    
    private func setupNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetLoginScreenInterface:", name: kUserDidFailAuthorizationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupInterfaceForLoggedInUser:", name: kUserDidAuthorizeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeLoginScreen", name: kAllDataDownloadedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getFirebaseData", name: kUserAuthenticatedFirebaseSuccessfullyNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetLoginScreenInterface:", name: kUserAuthenticatedFirebaseUnsuccessfullyNotificationName, object: nil)
    }
    
    private func setupGestures()
    {
        let edgePanGesture = UIPanGestureRecognizer(target: self, action: "translateTopView:")
        edgePanGesture.maximumNumberOfTouches = 1
        centerNavigationController.view.addGestureRecognizer(edgePanGesture)
        self.edgePanGesture = edgePanGesture
        
        let tapToReturnGesture = UITapGestureRecognizer(target: self, action: "returnToMainScreen:")
        tapToReturnGesture.numberOfTapsRequired = 1
        tapToReturnGesture.numberOfTouchesRequired = 1
        tapToReturnGesture.enabled = false
        centerNavigationController.view.addGestureRecognizer(tapToReturnGesture)
        self.tapToReturnGesture = tapToReturnGesture
    }
    
    private func animateToSideMenu(animateIn: Bool)
    {
        let targetTransform: CGAffineTransform
        let newXPosition = centerViewController.view.frame.size.width - kMinimumSlideoutOffset

        if animateIn {
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
    
    private func grayMaskAnimation() {
        self.grayMask = UIView(frame:self.centerNavigationController.view.frame)
        self.grayMask?.backgroundColor = UIColor.clearColor()
        self.centerNavigationController.view.addSubview(self.grayMask!)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        self.grayMask!.backgroundColor = UIColor.grayColor()
        self.grayMask!.alpha = 0.80
        UIView.commitAnimations()
    }
    
    private func displayLoadingHUD(display: Bool)
    {
        if display {
            if !( MBProgressHUD.allHUDsForView(view).count > 0 ) {
                let loadingHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
                loadingHUD.labelText = "Hang tight!"
                loadingHUD.detailsLabelText = randomLoadingDetail()
            }
        }
        else {
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
    private func displayLoginScreen()
    {
        tapToReturnGesture.enabled =  false
        edgePanGesture.enabled = false
        
        let loginScreen = LoginScreen(delegate: self)
        centerNavigationController.pushViewController(loginScreen, animated: false)
        centerNavigationController.setNavigationBarHidden(true, animated: false)
        self.loginScreen = loginScreen
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
    
    private func randomLoadingDetail() -> String
    {
        return loadingDetails[Int(arc4random_uniform(UInt32(loadingDetails.count)))]
    }
    
    // MARK: NSNotificationCenter Selectors
    
    @objc
    private func resetLoginScreenInterface(notification: NSNotification)
    {
        loginScreen?.setLoginButtonEnabled(true)
        displayLoadingHUD(false)
    }
    
    @objc
    private func setupInterfaceForLoggedInUser(notification: NSNotification)
    {
        loginScreen?.setLoginButtonEnabled(false)
        displayLoadingHUD(true)
        FirebaseManager.sharedManager.authenticateWithToken(GoogleLoginManager.sharedManager.authToken)
    }
    
    @objc
    private func getFirebaseData()
    {
        FirebaseManager.sharedManager.getAllDataOfType(.Projects, completion: nil);
        FirebaseManager.sharedManager.getAllDataOfType(.User, completion: nil);
    }
    
    @objc
    private func removeLoginScreen()
    {
        displayLoadingHUD(false)
        
        // Get rid of login screen
        // TB: without removing centerNavController and adding them back this way, there was a "ghost view" bug where it wouldn't let user select cells properly on homeVC
        centerNavigationController.removeFromParentViewController()
        centerNavigationController.view.removeFromSuperview()
        centerNavigationController = nil
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerViewController.setNavUIToHackeratiColors()
        
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        //TB: gestures are gone after you nil out the centerNavigationController, add them back
        setupGestures()
        tapToReturnGesture.enabled = true
        edgePanGesture.enabled = true
        
        //TB: seems like animateToSideMenu is necessary to get rid of the "ghost view bug" that blocked didSelectRow from homeVC, removeSnapshot is not neccesary though?
        
        animateToSideMenu(false)
        removeSnapshotView()
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
            print("began block")
        case .Changed:
            let newXPosition = edgePanGesture.locationInView(view).x
            let translation = CGAffineTransformMakeTranslation(newXPosition, 0.0)
            centerNavigationController.view.transform = translation
            print("changed block")

        case .Ended:
            let distanceNeededToAnimateFromLeft = UIScreen.mainScreen().bounds.size.width / 4.0
            let distanceNeededToAnimateFromRight =  distanceNeededToAnimateFromLeft * 3.0
            if centerNavigationController.view.frame.origin.x < distanceNeededToAnimateFromLeft || (centerNavigationController.view.frame.origin.x < distanceNeededToAnimateFromRight && currentMenuState == .Showing) {
                grayMask?.removeFromSuperview()
                animateToSideMenu(false)
                removeSnapshotView()
                print("ended 1 - side menu disappeared")
            }
            else {
                animateToSideMenu(true)
                print("ended 2 - side menu now showing fully")
            }
            print("ended block")

        default:
            removeSnapshotView()
            break
        }
    }
    
    @objc
    private func returnToMainScreen(tapGesture: UITapGestureRecognizer)
    {
        if self.currentMenuState == .Showing {
            grayMask?.removeFromSuperview()
            animateToSideMenu(false)
            removeSnapshotView()
        }
    }
    
    // MARK: LoginScreen Delegate
    
    func didPressLoginButton()
    {
        GoogleLoginManager.sharedManager.login()
    }
    
    // MARK: MainViewController Delegate
    
    func didPressMenuButton(button: UIBarButtonItem)
    {
        let sideMenuNotShowing = currentMenuState == .NotShowing
        if sideMenuNotShowing {
            displaySnapshotView()
            self.grayMaskAnimation()
            animateToSideMenu(sideMenuNotShowing)
        }
        else {
            animateToSideMenu(sideMenuNotShowing)
            removeSnapshotView()
        }
    }
    
    // MARK: SideMenuViewController Delegate
    
    func didMakePageSelection(selection: SideMenuSelection)
    {
        grayMask?.removeFromSuperview()
        if currentShowingPage != selection {
            centerNavigationController.removeFromParentViewController()
            centerNavigationController.view.removeFromSuperview()
            centerNavigationController = nil
            
            let targetViewController: MainViewController
            switch selection
            {
            case .Home:
                targetViewController = HomeViewController()
                
            case .History:
                targetViewController = HistoryViewController()
                
            case .Settings:
                targetViewController = SettingsViewController()
                
            case .LogOut:
                targetViewController = HomeViewController()
                GoogleLoginManager.sharedManager.logout()
            }
            
            if targetViewController.title == nil {
                targetViewController.title = selection.rawValue
            }
            
            targetViewController.delegate = self
            centerViewController = targetViewController
            currentShowingPage = selection
            
            centerNavigationController = UINavigationController(rootViewController: centerViewController)
            centerViewController.setNavUIToHackeratiColors()

            view.addSubview(centerNavigationController.view)
            addChildViewController(centerNavigationController)
            centerNavigationController.didMoveToParentViewController(self)
            setupGestures()
            
            if currentShowingPage == .LogOut {
                displayLoginScreen()
                currentShowingPage = .Home
            }
            
        }
        
        animateToSideMenu(false)
        removeSnapshotView()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return hideStatusBar
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
