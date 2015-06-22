//
//  HomeViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HomeViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, floatMenuDelegate
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
        
        self.navigationItem.prompt = "Tap on project name to record your hours"
        setNavUIToHackeratiColors()

//        let addProjectButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "displayProjects")
//        navigationItem.rightBarButtonItem = addProjectButton
        
        setupTableView()
        setupFloatingActionButtonWithPinImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        pinnedProjectsTableView.reloadData()
    }

    private func setupFloatingActionButtonWithPinImage() {
        let floatFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width-44-22, UIScreen.mainScreen().bounds.size.height-44-22, 40, 44)
        var floatingButton = VCFloatingActionButton(frame: floatFrame, normalImage: UIImage(named: "plus"), andPressedImage: UIImage(named:"cross"), withScrollview: pinnedProjectsTableView)
        
        floatingButton.imageArray = ["floatingBluePlusCircle", "floatingBluePlusCircle", "floatingBluePlusCircle", "floatingPinCircle" ]
        floatingButton.labelArray = ["Hackerati-Internal", "Carforo-MVP", "BAM-X-MVP", "Pin New Project"]
        
        floatingButton.delegate = self;
        floatingButton.hideWhileScrolling = true;
        self.view.addSubview(floatingButton);
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
        presentNewRecordFormVC(indexPath)
    }
    
    func presentNewRecordFormVC(indexPath: NSIndexPath) {
        let companyName = pinnedProjects[indexPath.section].companyName
        let projectName = pinnedProjects[indexPath.section].projects[indexPath.row].name
        let newRecord = Record(client: companyName, project: projectName)
        
        let newForm = RecordFormViewController(record: newRecord, saveOnly: true)
        newForm.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissNewForm")
        newForm.title = "New Record"
        let newFormNavController = UINavigationController(rootViewController: newForm)
        
        if let containerVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? ContainerViewController
        {
            containerVC.centerNavigationController.presentViewController(newFormNavController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pinnedProjects[section].companyName
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        view.tintColor = UIColor(rgba: "#2D2D2D")
        header.textLabel.textColor = UIColor.whiteColor()
        header.textLabel.font = UIFont.boldSystemFontOfSize(25)
//        header.textLabel.frame = header.frame
//        header.textLabel.textAlignment = NSTextAlignment.Center
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
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
        //Do we want to standardize as plus button like Android?
//        var plusButton: UIButton  = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
//        plusButton.tag = indexPath.row
//        plusButton.addTarget(self, action: "presentNewRecordFormVC:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    // MARK: FloatButton Delegate
    
    func floatingButtonWasPressed() {
//        displayProjects()
    }
    
    func didSelectMenuOptionAtIndex(row: Int) {
        println("row at index \(row) was pressed")
    }
    
}
