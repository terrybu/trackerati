//
//  HomeViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import UIKit

class HomeViewController : MainViewController
{
    init()
    {
        super.init(nibName: nil, bundle: nil)
        title = "Trackerati"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.redColor()
        
        let addProjectButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "displayProjects")
        navigationItem.rightBarButtonItem = addProjectButton
    }
    
    func displayProjects()
    {
        let projectsViewController = ProjectsViewController(projects: FirebaseManager.sharedManager.allClientProjects)
        let navController = UINavigationController(rootViewController: projectsViewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
}
