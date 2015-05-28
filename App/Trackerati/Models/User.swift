//
//  User.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class User : NSObject
{
    private(set) var email: String
    private(set) var firebaseID: String
    private(set) var profilePicture: UIImage?
    private(set) var displayName: String
    
    init(email: String, profilePicture: UIImage?, displayName: String)
    {
        self.email = email
        self.profilePicture = profilePicture
        self.displayName = displayName
        
        let unwantedCharacters = NSCharacterSet(charactersInString: "@.")
        firebaseID = join("", email.componentsSeparatedByCharactersInSet(unwantedCharacters))
    }
    
}
