//
//  ProjectsViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/20/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class ProjectsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, floatMenuDelegate
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
        view = UIView(frame: UIScreen.mainScreen().bounds)
    
        setupTableView()
        
        let floatFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width-44-22, UIScreen.mainScreen().bounds.size.height-44-22, 40, 44)
        var floatingButton = VCFloatingActionButton(frame: floatFrame, normalImage: UIImage(named: "plus"), andPressedImage: UIImage(named:"plus"), withScrollview: projectsTableView)
        floatingButton.delegate = self;
        floatingButton.hideWhileScrolling = true;
        self.view.addSubview(floatingButton);
        
        var backHomeButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "closeViewController");
        navigationItem.leftBarButtonItem = backHomeButton;
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
                    FirebaseManager.sharedManager.pinnedProjects![indexOfPinnedProject].projects.append(project)
                }
                else {
                    let newPinnedClient = Client(companyName: clientProjects[indexPath.section].companyName, projects: [project])
                    FirebaseManager.sharedManager.pinnedProjects!.append(newPinnedClient)
                }
                
                hud.labelText = "Saving to Pinned Projects"
                FirebaseManager.sharedManager.pinCurrentUserToProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion:{
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2.0, completion: nil)
                })
            }
            else {
                selectedCell.accessoryView = nil
                
                let indexOfPinnedProject = clientPinned(atIndexPath: indexPath)
                FirebaseManager.sharedManager.pinnedProjects!.removeAtIndex(indexOfPinnedProject)
                
                hud.labelText = "Removing Pinned Project"
                FirebaseManager.sharedManager.removeCurrentUserFromProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion: {
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2.0, completion: nil)
                })
            }
        }
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return clientProjects[section].companyName
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
        
        for client in FirebaseManager.sharedManager.pinnedProjects!
        {
            if contains(client.projects, projectForIndexPath(indexPath)) {
                cell.accessoryView = UIImageView(image: UIImage(named: kCheckMarkImageName))
            }
        }
        
        return cell
    }
    
    // MARK: FloatButton Delegate
    
    func floatingButtonWasPressed() {
        let newProjectVC = NewProjectViewController()
        let navCtrl = UINavigationController(rootViewController: newProjectVC)
        newProjectVC.onDismiss = {
            self.clientProjects = FirebaseManager.sharedManager.allClientProjects!
            self.projectsTableView.reloadData()
        }
        presentViewController(navCtrl, animated: true, completion: nil);
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Private
    
    private func clientPinned(atIndexPath indexPath:NSIndexPath) -> Int
    {
        var i = 0
        for client in FirebaseManager.sharedManager.pinnedProjects! {
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