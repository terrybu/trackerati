//
//  FirebaseManager.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/12/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import Argo

class FirebaseManager : NSObject
{
    private let kProjectsKey = "Projects"
    private let kHackeratiEmailDomain = "thehackeraticom"
    
    private var firebaseDB = Firebase()
    private var allClients = [Client]()
    private var userClients = [Client]()
    
    class var sharedManager : FirebaseManager {
    
        struct Static {
            static var instance : FirebaseManager?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FirebaseManager()
        }
        
        return Static.instance!
    }
    
    func configureWithDatabaseURL(url: String)
    {
        assert(url != "", "Must be a valid URL")
        firebaseDB = Firebase(url: url)
    }
    
    func getAllProjects()
    {
        dispatch_async(dispatch_queue_create("requestProjectsQueue", nil), {
            self.firebaseDB.observeSingleEventOfType(.Value, withBlock: { snapshot in
                self.allClients = self.createClientArrayFromJSON(snapshot.value, sorted: true)
                
            })
        })
    }
    
    // MARK: Private
    
    private func createClientArrayFromJSON(json: AnyObject, sorted: Bool) -> [Client]
    {
        let dataDictionary = json as! NSDictionary
        let projects = dataDictionary.objectForKey(self.kProjectsKey) as! NSDictionary
        var clients = [Client]()
        
        for key in projects.allKeys {
            let clientName = key as! String
            let clientProjects = (projects.objectForKey(key) as! NSDictionary).allKeys as! [String]
            let newClient = Client(companyName: clientName, projectNames: clientProjects)
            clients.append(newClient)
        }
        
        if sorted {
            clients.sort({ $0.companyName.uppercaseString < $1.companyName.uppercaseString })
        }
        
        return clients
    }
    
    private func getLoggedInUserClients() -> [Client]
    {
        
        return []
    }
    
}
