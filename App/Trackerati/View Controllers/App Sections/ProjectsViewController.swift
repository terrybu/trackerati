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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "closeViewController")
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
                    FirebaseManager.sharedManager.pinnedProjects![indexOfPinnedProject].projects.append(project)
                }
                else {
                    let newPinnedClient = Client(companyName: clientProjects[indexPath.section].companyName, projects: [project])
                    FirebaseManager.sharedManager.pinnedProjects!.append(newPinnedClient)
                }
                
                hud.labelText = "Saving to Pinned Projects"
                FirebaseManager.sharedManager.pinCurrentUserToProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion:{
                    self.showCompletedHUD()
                })
            }
            else {
                selectedCell.accessoryView = nil
                
                let indexOfPinnedProject = clientPinned(atIndexPath: indexPath)
                FirebaseManager.sharedManager.pinnedProjects!.removeAtIndex(indexOfPinnedProject)
                
                hud.labelText = "Removing Pinned Project"
                FirebaseManager.sharedManager.removeCurrentUserFromProject(clientProjects[indexPath.section].companyName, projectName: projectNameForIndexPath(indexPath), completion: {
                    self.showCompletedHUD()
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
    
    private func showCompletedHUD()
    {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        let completedHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        completedHUD.mode = .CustomView
        completedHUD.customView = UIImageView(image: UIImage(named: "CompletedCheckMark"))
        completedHUD.labelText = "Completed!"
        let timeUntilHide = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(2.0) * NSEC_PER_SEC))
        dispatch_after(timeUntilHide, dispatch_get_main_queue(), {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}