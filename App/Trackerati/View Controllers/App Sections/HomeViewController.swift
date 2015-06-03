//
//  HomeViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HomeViewController : MainViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    
    private weak var pinnedProjectsTableView: UITableView!
    private var pinnedProjects: [Client] {
        get {
            return FirebaseManager.sharedManager.pinnedProjects!
        }
    }

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
        
        let addProjectButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "displayProjects")
        navigationItem.rightBarButtonItem = addProjectButton
        
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        pinnedProjectsTableView.reloadData()
    }
    
    private func setupTableView()
    {
        let pinnedProjectsTableView = UITableView(frame: view.frame, style: .Plain)
        pinnedProjectsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        pinnedProjectsTableView.delegate = self
        pinnedProjectsTableView.dataSource = self
        pinnedProjectsTableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(pinnedProjectsTableView)
        self.pinnedProjectsTableView = pinnedProjectsTableView
    }
    
    // MARK: UIBarButtonItem Selectors
    
    @objc
    private func displayProjects()
    {
        let projectsViewController = ProjectsViewController(projects: FirebaseManager.sharedManager.allClientProjects)
        let navController = UINavigationController(rootViewController: projectsViewController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    @objc
    private func dismissNewForm()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let companyName = pinnedProjects[indexPath.section].companyName
        let projectName = pinnedProjects[indexPath.section].projects[indexPath.row].name
        let newRecord = Record(client: companyName, project: projectName)
        let newForm = RecordFormViewController(record: newRecord, saveOnly: true)
        newForm.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissNewForm")
        newForm.title = "New Record"
        let newFormNavController = UINavigationController(rootViewController: newForm)
        presentViewController(newFormNavController, animated: true, completion: nil)
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pinnedProjects[section].companyName
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return pinnedProjects.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pinnedProjects[section].projects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = pinnedProjects[indexPath.section].projects[indexPath.row].name
        return cell
    }
    
}
