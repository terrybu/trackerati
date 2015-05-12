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
    private let googlePlusIdentifier = "478294020811-80olfgevlg8q14vo74lmmiu3nu7q75m5.apps.googleusercontent.com"
    private let googlePlusScopeKeyProfile = "profile"
    private let hackeratiEmailDomain = "thehackerati.com"
    
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
    
    func login()
    {
        let googleSignInManager = GPPSignIn.sharedInstance()
        googleSignInManager.shouldFetchGoogleUserEmail = true
        googleSignInManager.clientID = googlePlusIdentifier
        googleSignInManager.scopes = [googlePlusScopeKeyProfile]
        googleSignInManager.delegate = self

        switch AFNetworkReachabilityManager.sharedManager().networkReachabilityStatus {
        case .ReachableViaWiFi, .ReachableViaWWAN:
            if !googleSignInManager.trySilentAuthentication() {
                googleSignInManager.authenticate()
            }
        case .NotReachable, .Unknown:
            self.logout()
            self.login()
        }
    }
    
    func logout()
    {
        GPPSignIn.sharedInstance().signOut()
        TrackeratiUserDefaults.standardDefaults.logOutUser()
    }
    
    // MARK: Google Plus Sign In Delegate
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error == nil {
            // TODO: Signed in! Do something
            AFNetworkReachabilityManager.sharedManager().stopMonitoring()
            
            let email = GPPSignIn.sharedInstance().userEmail
            if !(email as NSString).containsString(hackeratiEmailDomain) {
                
                let invalidEmailAlertView = UIAlertView(title: "Invalid Email Address", message: "Please use a Hackerati email address", delegate: self, cancelButtonTitle: "No thanks", otherButtonTitles: "Try Again")
                invalidEmailAlertView.show()
            }
            else {
                // TODO: Whatever you do when valid email and signed in successfully.
                if TrackeratiUserDefaults.standardDefaults.currentUser() != email { // add user to userdefaults
                    TrackeratiUserDefaults.standardDefaults.setCurrentUser(email)
                }
            }
        }
        else {
            // TODO: Handle when get error
            println(error.localizedDescription)
            self.logout()
        }
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
