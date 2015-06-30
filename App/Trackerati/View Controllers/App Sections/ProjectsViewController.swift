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
    var onDismiss: (() -> ())?
    
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
        var trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "editTableView")

        navigationItem.rightBarButtonItems = [plusButton, trashButton]
        
        setNavUIToHackeratiColors()
        setupTableView()
    }
    
    
    // MARK: Private methods
    
    @objc
    private func editTableView()
    {
        projectsTableView.setEditing(!projectsTableView.editing, animated: true)
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
//                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.0, customDoneText: "Completed!", completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserJustPinnedOrUnpinnedNotificationName, object: nil)
                    hud.hide(true)
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
//                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.0, customDoneText: "Completed!", completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserJustPinnedOrUnpinnedNotificationName, object: nil)
                    hud.hide(true)
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
    
    // MARK: Project/Client Deletion Logic
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            showWarningBeforeConfirmingDeletion(indexPath)
        }
    }
    
    func showWarningBeforeConfirmingDeletion(indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete this project from the database? This will affect all other users using Trackerati", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (action) -> Void in
            self.deleteProjectFromFirebaseAndViewAtIndexPath(indexPath)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    private func deleteProjectFromFirebaseAndViewAtIndexPath(indexPath: NSIndexPath) {
        var projectToDelete = projectForIndexPath(indexPath)
        var indexOfClientWithProjectToDelete = indexPath.section
        var clientWithProjectToDelete: Client? = self.clientProjects[indexOfClientWithProjectToDelete]
        
        
        
        FirebaseManager.sharedManager.deleteProject(clientWithProjectToDelete!.companyName, projectName: projectToDelete.name, completion: { (error) -> Void in
            
            if let client = clientWithProjectToDelete {
                //deleting locally from firebase singleton instance
                FirebaseManager.sharedManager.allClientProjects![indexOfClientWithProjectToDelete].projects.removeAtIndex(indexPath.row)
                if (FirebaseManager.sharedManager.allClientProjects![indexOfClientWithProjectToDelete].projects.isEmpty) {
                    FirebaseManager.sharedManager.allClientProjects!.removeAtIndex(indexPath.section)
                }
                
                //deleting locally from this vc
                //client.projects.removeAtIndex(indexPath.row)
                if client.projects.isEmpty {
                    self.clientProjects.removeAtIndex(indexOfClientWithProjectToDelete)
                    self.projectsTableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                else {
                    self.projectsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        })
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
        self.dismissViewControllerAnimated(true, completion: {
            self.onDismiss!()
        })
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
    
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}