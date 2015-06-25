//
//  ProjectsViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/20/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class ProjectsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kViewControllerTitle = "Projects"
    private let kCellReuseIdentifier = "cell"
    private let kCheckMarkImageName = "CheckMark"
    
    private weak var projectsTableView: UITableView!
    
    private var clientProjects: [Client] = []
    
    init(projects: [Client]?)
    {
        super.init(nibName: nil, bundle: nil)
        self.title = kViewControllerTitle
        self.navigationItem.prompt = "Tap on project name to pin/unpin"
        
        if let projectArray = projects {
            clientProjects = projectArray
        }
        else {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.labelText = "Hang Tight!"
            hud.detailsLabelText = "Getting our awesome projects!"
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "projectsFinishedDownloading:", name: kAllProjectsDownloadedNotificationName, object: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()

        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        var backHomeButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "closeViewController")
        navigationItem.leftBarButtonItem = backHomeButton;
        
        var plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "openNewProjectViewController")
        navigationItem.rightBarButtonItem = plusButton;
        
        setNavUIToHackeratiColors()
        setupTableView()
    }
    
    
    
    private func setupTableView()
    {
        let projectsTableView = UITableView(frame: view.frame, style: .Plain)
        projectsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        projectsTableView.delegate = self
        projectsTableView.dataSource = self
        view.addSubview(projectsTableView)
        self.projectsTableView = projectsTableView
    }
    
    @objc
    private func projectsFinishedDownloading(notification: NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let downloadedProjects = userInfo[kNotificationDownloadedInfoKey] as? [Client] {
                clientProjects = downloadedProjects
                
                MBProgressHUD.hideAllHUDsForView(view, animated: true)
                projectsTableView.reloadData()
            }
        }
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            if selectedCell.accessoryView == nil {
                
                selectedCell.accessoryView = UIImageView(image: UIImage(named: kCheckMarkImageName))
                let project = projectForIndexPath(indexPath)
                
                let indexOfPinnedProject = clientPinned(atIndexPath: indexPath)
                if indexOfPinnedProject != -1 {
                    FirebaseManager.sharedManager.clientsByPinnedProj![indexOfPinnedProject].projects.append(project)
                }
                else {
                    let newPinnedClient = Client(companyName: clientProjects[indexPath.section].companyName, projects: [project])
                    FirebaseManager.sharedManager.clientsByPinnedProj!.append(newPinnedClient)
                }
                
                hud.labelText = "Saving to Pinned Projects"
                FirebaseManager.sharedManager.pinCurrentUserToProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion:{
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.0, customDoneText: "Completed!", completion: nil)
                })
            }
            else {
                //Removing Pin Logic
                selectedCell.accessoryView = nil
                
                //check where the client is in our pinned Projects Array
                
                let indexOfClientThatHasProjectToRemove = clientPinned(atIndexPath: indexPath)
                var client = FirebaseManager.sharedManager.clientsByPinnedProj![indexOfClientThatHasProjectToRemove]
                var pinnedProjects = FirebaseManager.sharedManager.clientsByPinnedProj!
                
                var arrayOfProjectNames = (client.projects as AnyObject).valueForKeyPath("name") as! [String]
                if client.projects.count == 1 {
                    FirebaseManager.sharedManager.clientsByPinnedProj!.removeAtIndex(indexOfClientThatHasProjectToRemove) //remove the whole client object
                }
                else if client.projects.count > 1 {
                    var indexOfProjectToRemoveInTheClientsProjects = find(arrayOfProjectNames, selectedCell.textLabel!.text!)
                    client.projects.removeAtIndex(indexOfProjectToRemoveInTheClientsProjects!) //remove just the project from the client object's projects array
                }
                
                hud.labelText = "Removing Pinned Project"
                FirebaseManager.sharedManager.removeCurrentUserFromProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion: {
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.0, customDoneText: "Completed!", completion: nil)
                })
            }
        }
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return clientProjects[section].companyName
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        view.tintColor = UIColor(rgba: "#2D2D2D")
        header.textLabel.textColor = UIColor.whiteColor()
        header.textLabel.font = UIFont.boldSystemFontOfSize(25)
        //        header.textLabel.frame = header.frame
        //        header.textLabel.textAlignment = NSTextAlignment.Center
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return clientProjects.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientProjects[section].projects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let projectName = projectNameForIndexPath(indexPath)
        cell.textLabel?.text = projectName
        cell.selectionStyle = .None
        cell.accessoryView = nil
        
        for client in FirebaseManager.sharedManager.clientsByPinnedProj!
        {
            if contains(client.projects, projectForIndexPath(indexPath)) {
                cell.accessoryView = UIImageView(image: UIImage(named: kCheckMarkImageName))
            }
        }
        
        return cell
    }
    
    // MARK: Nav Button Selectors
    
    @objc
    private func openNewProjectViewController() {
        let newProjectVC = NewProjectViewController()
        let navCtrl = UINavigationController(rootViewController: newProjectVC)
        newProjectVC.onDismiss = {
            self.clientProjects = FirebaseManager.sharedManager.allClientProjects!
            self.projectsTableView.reloadData()
        }
        presentViewController(navCtrl, animated: true, completion: nil);
    }
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Private
    
    private func clientPinned(atIndexPath indexPath:NSIndexPath) -> Int
    {
        var i = 0
        for client in FirebaseManager.sharedManager.clientsByPinnedProj! {
            if client.companyName == clientProjects[indexPath.section].companyName {
                return i
            }
            i++
        }
        
        return -1
    }
    
    private func projectForIndexPath(indexPath: NSIndexPath) -> Project
    {
        return clientProjects[indexPath.section].projects[indexPath.row]
    }
    
    private func projectNameForIndexPath(indexPath: NSIndexPath) -> String
    {
        return clientProjects[indexPath.section].projects[indexPath.row].name
    }
    
    
}