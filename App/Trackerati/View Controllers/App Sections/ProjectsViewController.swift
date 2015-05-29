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
        // TODO: Pin selected project
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
        cell.textLabel?.text = projectNameForIndexPath(indexPath)
        cell.selectionStyle = .None
        return cell
    }
    
    // MARK: Private
    
    private func projectNameForIndexPath(indexPath: NSIndexPath) -> String
    {
        return clientProjects[indexPath.section].projects[indexPath.row].name
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}