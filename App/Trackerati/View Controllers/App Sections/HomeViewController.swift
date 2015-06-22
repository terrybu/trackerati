//
//  HomeViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import AVFoundation

enum FloatingButtonCellIndex: Int {
    case FirstButtonFromBottom = 0, SecondButtonFromBottom, ThirdButtonFromBottom, PinNewprojectButton
}

class HomeViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, floatMenuDelegate
{
    var tapSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tap-professional", ofType: "aif")!)
    var dingSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ding", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    var floatingActionButton: VCFloatingActionButton?
    var tuplesForFloatingDefaultsLabelsArray: [(String, Record)]?
    
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
        audioPlayer = AVAudioPlayer(contentsOfURL: dingSound, error: nil)
        audioPlayer.prepareToPlay()
        
        self.navigationItem.prompt = "Tap pinned project or use plus button to record hours"
        setNavUIToHackeratiColors()
        
        setupTableView()
        setupFloatingActionButtonWithPinImage()
        refreshFloatingDefaultsLabelsFromUserRecords()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRecordsRedownloaded", name: kUserInfoDownloadedNotificationName, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        pinnedProjectsTableView.reloadData()
        refreshFloatingDefaultsLabelsFromUserRecords()
    }
    
    @objc
    private func userRecordsRedownloaded() {
        refreshFloatingDefaultsLabelsFromUserRecords()
    }

    private func setupFloatingActionButtonWithPinImage() {
        let floatFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width-44-22, UIScreen.mainScreen().bounds.size.height-44-22, 40, 44)
        floatingActionButton = VCFloatingActionButton(frame: floatFrame, normalImage: UIImage(named: "plus"), andPressedImage: UIImage(named:"cross"), withScrollview: pinnedProjectsTableView)
        
        floatingActionButton!.imageArray = ["floatingBluePlusCircle", "floatingBluePlusCircle", "floatingBluePlusCircle", "floatingPinCircle" ]
        
        floatingActionButton!.delegate = self
        floatingActionButton!.hideWhileScrolling = true
        self.view.addSubview(floatingActionButton!)
    }
    
    private func refreshFloatingDefaultsLabelsFromUserRecords() {
        tuplesForFloatingDefaultsLabelsArray = FirebaseManager.sharedManager.returnThreeLatestUniqueClientProjectsFromUserRecords()
        floatingActionButton!.labelArray = [
            tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.FirstButtonFromBottom.rawValue].0,
            tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.SecondButtonFromBottom.rawValue].0,
            tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.ThirdButtonFromBottom.rawValue].0,
            "Pin or Remove Projects"
        ]
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
        
        //TODO: Standardize black arrow or plus button for cell click?
        //Do we want to standardize as plus button like Android? instead of Apple stock DisclosureIndicator > arrow?
//        var plusButton: UIButton  = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
//        plusButton.tag = indexPath.row
//        plusButton.addTarget(self, action: "presentNewRecordFormVC:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    // MARK: Floating Action Button Delegate
    
    func didSelectMenuOptionAtIndex(row: Int) {
        if (row == FloatingButtonCellIndex.PinNewprojectButton.rawValue) {
            displayProjects()
//            audioPlayer = AVAudioPlayer(contentsOfURL: tapSound, error: nil)
            //Not sure if I like this particular sound - couldn't find a good sound for it
        }
        else {
            self.audioPlayer = AVAudioPlayer(contentsOfURL: self.dingSound, error: nil)
            self.audioPlayer.play()
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            let displayName = tuplesForFloatingDefaultsLabelsArray![row].0
            hud.labelText = "Logging \(displayName)"
            
            FirebaseManager.sharedManager.saveSelectedDefaultRecord(tuplesForFloatingDefaultsLabelsArray![row].1, completion: { (error) -> Void in
                if (error == nil) {
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2, customDoneText: "\(displayName) logged!", completion: nil)
                }
            })
        }
//        audioPlayer.play()
    }

    
    
}
