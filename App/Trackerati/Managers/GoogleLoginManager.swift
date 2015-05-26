//
//  GoogleLoginManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

let kUserDidAuthorizeNotification = "userDidAuthorizeNotification"
let kUserDidFailAuthorizationNotification = "userDidFailAuthorizationNotification"
let kUserProfilePictureDidFinishDownloadingNotification = "userProfilePictureDidFinishDownloading"

class GoogleLoginManager : NSObject, GPPSignInDelegate, UIAlertViewDelegate
{
    private let googleSignInManager = GPPSignIn.sharedInstance()
    private var googlePlusIdentifier = "";
    private let kGooglePlusScopeKeyProfile = "profile"
    private let kHackeratiEmailDomain = "thehackerati.com"
    private let kMaxNumberOfLoginAttempts = 50
    
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
    
    private(set) var currentUser: User!
    private(set) var authorized: Bool = false
    
    // MARK: Public
    
    /**
    Configures the manager for Google Plus sign in given an API key
    
    :param: key API key from the Google Developer Portal
    */
    func configureWithAPIKey(key: String)
    {
        googlePlusIdentifier = key
        
        googleSignInManager.shouldFetchGoogleUserEmail = true
        googleSignInManager.shouldFetchGooglePlusUser = true
        googleSignInManager.clientID = googlePlusIdentifier
        googleSignInManager.scopes = [kGooglePlusScopeKeyProfile]
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
            if numberOfAttempts <= kMaxNumberOfLoginAttempts {
                logout()
                login()
            }
            else {
                displayAlertViewWithTitle("No Internet Connection", description: "Please make sure you have a strong internet connection and try again", buttonTitle: "OK", otherButtonTitle: nil)
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
    
    /**
    Silently attempt to log user back in if they've already authorized their account with the app
    
    :returns: Bool indicating whether or not the user already authorized
    */
    func attemptPreAuthorizationLogin() -> Bool
    {
        if googleSignInManager.clientID != "" {
            return googleSignInManager.trySilentAuthentication()
        }
        return false
    }
    
    // MARK: Private
    
    private func createUserFromProfile()
    {
        let email = googleSignInManager.userEmail
        let profileName = googleSignInManager.googlePlusUser.displayName
        
        dispatch_async(dispatch_queue_create("profileImageDownloadQueue", nil), {
            
            if let imageURL = NSURL(string: self.googleSignInManager.googlePlusUser.image.url) {
                
                if let imageData = NSData(contentsOfURL: imageURL) {
                    
                    let profilePicture = UIImage(data: imageData)
                    dispatch_async(dispatch_get_main_queue(), {
                        let profilePicture = profilePicture
                        self.currentUser = User(email: email, profilePicture: profilePicture, displayName: profileName)
                        NSNotificationCenter.defaultCenter().postNotificationName(kUserProfilePictureDidFinishDownloadingNotification, object: nil)
                    })
                    
                }
            }
        })
    }
    
    // MARK: Google Plus Sign In Delegate
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if error == nil {
            AFNetworkReachabilityManager.sharedManager().stopMonitoring()
            
            let email = googleSignInManager.userEmail
            if !(email as NSString).containsString(kHackeratiEmailDomain) {
                
                displayAlertViewWithTitle("Invalid Email Address", description: "Please use a Hackerati email address", buttonTitle: "No Thanks", otherButtonTitle: "Try Again")
            }
            else {
                authorized = true
                
                if TrackeratiUserDefaults.standardDefaults.currentUser() != email { // add user to userdefaults
                    TrackeratiUserDefaults.standardDefaults.setCurrentUser(email)
                }
                
                createUserFromProfile()
                NSNotificationCenter.defaultCenter().postNotificationName(kUserDidAuthorizeNotification, object: currentUser)
            }
        }
        else {
            
            displayAlertViewWithTitle("Whoops. Something went wrong", description: error.localizedDescription, buttonTitle: "OK", otherButtonTitle: nil)
        }
    }
    
    private func displayAlertViewWithTitle(title:String, description: String, buttonTitle: String, otherButtonTitle: String?)
    {
        let alertView: UIAlertView
        if let otherButton = otherButtonTitle {
            alertView = UIAlertView(title: title, message: description, delegate: self, cancelButtonTitle: buttonTitle, otherButtonTitles: otherButton)
        }
        else {
            alertView = UIAlertView(title: title, message: description, delegate: self, cancelButtonTitle: buttonTitle)
        }
        
        alertView.show()
    }
    
    // MARK: UIAlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            logout()
            NSNotificationCenter.defaultCenter().postNotificationName(kUserDidFailAuthorizationNotification, object: nil)
        case 1:
            logout()
            login()
        default:
            break
        }
    }
    
}
