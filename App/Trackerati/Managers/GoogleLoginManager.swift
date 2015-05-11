//
//  GoogleLoginManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation

class GoogleLoginManager : NSObject, GPPSignInDelegate
{
    private let googlePlusIdentifier = "478294020811-80olfgevlg8q14vo74lmmiu3nu7q75m5.apps.googleusercontent.com"
    private let googlePlusScopeKeyProfile = "profile"
    
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
            self.signout()
            self.login()
        }
            
//            return
        
//        reachabilityManager.startMonitoring()
    }
    
    func signout()
    {
        GPPSignIn.sharedInstance().signOut()
    }
    
    // MARK: Google Plus Sign In Delegate
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        println("authenticated")
        if error == nil {
            // TODO: Signed in! Do something
            AFNetworkReachabilityManager.sharedManager().stopMonitoring()
            
            let email = GPPSignIn.sharedInstance().userEmail
            println(email)
        }
        else {
            // TODO: Handle correctly
            println(error.localizedDescription)
        }
    }
    
}
