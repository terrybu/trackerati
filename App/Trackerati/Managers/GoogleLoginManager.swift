//
//  GoogleLoginManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class GoogleLoginManager : NSObject, GPPSignInDelegate, UIAlertViewDelegate
{
    private let googleSignInManager = GPPSignIn.sharedInstance()
    private var googlePlusIdentifier = "";
    private let googlePlusScopeKeyProfile = "profile"
    private let hackeratiEmailDomain = "thehackerati.com"
    private let maxNumberOfLoginAttempts = 50
    
    private var numberOfAttempts = 0
    
    class var sharedManager : GoogleLoginManager {
    
        struct Static {
            static var instance : GoogleLoginManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GoogleLoginManager()
        }
        
        return Static.instance!
    }
    
    // MARK: Public
    
    /**
    Configures the manager for Google Plus sign in given an API key
    
    :param: key API key from the Google Developer Portal
    */
    func configureWithAPIKey(key: String)
    {
        googlePlusIdentifier = key
        
        googleSignInManager.shouldFetchGoogleUserEmail = true
        googleSignInManager.clientID = googlePlusIdentifier
        googleSignInManager.scopes = [googlePlusScopeKeyProfile]
        googleSignInManager.delegate = self
    }
    
    /**
    Attempt to log the user in given previous configuration
    */
    func login()
    {
        assert(googlePlusIdentifier != "", "API Key can not be empty. Configure the manager with 'configureWithAPIKey:")
        
        switch AFNetworkReachabilityManager.sharedManager().networkReachabilityStatus {
        case .ReachableViaWiFi, .ReachableViaWWAN:
            if !googleSignInManager.trySilentAuthentication() {
                googleSignInManager.authenticate()
            }
        case .NotReachable, .Unknown:
            numberOfAttempts += 1
            if numberOfAttempts <= maxNumberOfLoginAttempts {
                self.logout()
                self.login()
            }
            else {
                let badConnectionAlertView = UIAlertView(title: "No Internet Connection", message: "Please make sure you have a strong internet connection and try again", delegate: self, cancelButtonTitle: "OK")
                badConnectionAlertView.show()
            }
        }
    }
    
    /**
    Logs user out of app
    */
    func logout()
    {
        googleSignInManager.signOut()
        TrackeratiUserDefaults.standardDefaults.logOutUser()
    }
    
    // MARK: Google Plus Sign In Delegate
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error == nil {
            AFNetworkReachabilityManager.sharedManager().stopMonitoring()
            
            let email = googleSignInManager.userEmail
            if !(email as NSString).containsString(hackeratiEmailDomain) {
                
                let invalidEmailAlertView = UIAlertView(title: "Invalid Email Address", message: "Please use a Hackerati email address", delegate: self, cancelButtonTitle: "No thanks", otherButtonTitles: "Try Again")
                invalidEmailAlertView.show()
            }
            else {
                // TODO: Whatever you do when valid email and signed in successfully.
                if TrackeratiUserDefaults.standardDefaults.currentUser() != email { // add user to userdefaults
                    TrackeratiUserDefaults.standardDefaults.setCurrentUser(email)
                }
                
                // TODO: Send User model and configure the UI accordingly in the receiving VC
                let userModel = User(email: email)
                NSNotificationCenter.defaultCenter().postNotificationName(userDidAuthorizeNotification, object: userModel)
            }
        }
        else {
            // TODO: Handle when get error
            println(error.localizedDescription)
            self.logout()
        }
    }
    
    /**
    Silently attempt to log user back in if they've already authorized their account with the app
    */
    func attemptPreAuthorizationLogin()
    {
        if googleSignInManager.clientID != "" {
            googleSignInManager.trySilentAuthentication()
        }
        // TODO: Force them to sign in
    }
    
    // MARK: UIAlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.logout()
        case 1:
            self.logout()
            self.login()
        default:
            break
        }
    }
    
}
