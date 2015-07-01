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

class HomeViewController : MainViewController, UITableViewDelegate, UITableViewDataSource, FloatMenuDelegate
{
    var tapSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("tap-professional", ofType: "aif")!)
    var dingSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ding", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    var floatingActionButton: VCFloatingActionButton?

    
    private let kCellReuseIdentifier = "cell"
    
    private weak var pinnedProjectsTableView: UITableView!
    private var pinnedProjects: [Client] {
        get {
            return FirebaseManager.sharedManager.clientsByPinnedProj!
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
        
        self.navigationItem.prompt = "Tap pinned project or orange button to record hours"
        setNavUIToHackeratiColors()
        
        setupTableView()
        setupFloatingActionButtonWithPinImage()
        refreshFloatingDefaultsLabelsFromUserRecords()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userRecordsRedownloaded", name: kUserInfoDownloadedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userJustPinnedOrUnpinnedSomething", name: kUserJustPinnedOrUnpinnedNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userJustDeletedSomething", name: kUserJustDeletedNotificationName, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    
//        if pinnedProjectsTableView != nil {
//            pinnedProjectsTableView.reloadData()
//        }
        if floatingActionButton != nil {
            refreshFloatingDefaultsLabelsFromUserRecords()
        }
    }
    
    
    
    // MARK: SET-UP
    private func setupFloatingActionButtonWithPinImage() {
        let floatFrame = CGRectMake(UIScreen.mainScreen().bounds.size.width-44-22, UIScreen.mainScreen().bounds.size.height-44-22, 40, 44)
        floatingActionButton = VCFloatingActionButton(frame: floatFrame, normalImage: UIImage(named: "plus"), andPressedImage: UIImage(named:"cross"), withScrollview: pinnedProjectsTableView)
        
        floatingActionButton!.imageArray = ["floatingBluePlusCircle", "floatingBluePlusCircle", "floatingBluePlusCircle", "floatingPinCircle" ]
        
        floatingActionButton!.delegate = self
        floatingActionButton!.hideWhileScrolling = true
        self.view.addSubview(floatingActionButton!)
    }
    
    private func refreshFloatingDefaultsLabelsFromUserRecords() {
        FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray = FirebaseManager.sharedManager.returnThreeLatestUniqueClientProjectsFromUserRecords()
        var whatever = FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray
        floatingActionButton!.labelArray = [
            FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.FirstButtonFromBottom.rawValue].0,
            FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.SecondButtonFromBottom.rawValue].0,
            FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray![FloatingButtonCellIndex.ThirdButtonFromBottom.rawValue].0,
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
    
    
    // MARK: Private Methods

    @objc
    private func userJustDeletedSomething() {
        //if a user deleted a project, it might have been a pinned project that got deleted, so to prevent a user from seeing a pinned project in the home vc right after getting deleted, let's refresh tableview
        //reloadingData will get clientsByPinnedProject again from Firebase
        self.pinnedProjectsTableView.reloadData()
    }
    
    @objc
    private func userRecordsRedownloaded() {
        //We need to redownload records from firebase after we post our floating defaults so then we refresh the buttons
        refreshFloatingDefaultsLabelsFromUserRecords()
    }
    
    @objc
    private func userJustPinnedOrUnpinnedSomething() {
        FirebaseManager.sharedManager.clientsByPinnedProj!.sort({ $0.companyName.uppercaseString < $1.companyName.uppercaseString })
        for client:Client in self.pinnedProjects {
            client.projects.sort({ $0.name.uppercaseString < $1.name.uppercaseString })
        }
        self.pinnedProjectsTableView.reloadData()
    }
    
    @objc
    private func displayProjectsViewController()
    {
        let projectsViewController = ProjectsViewController(projects: FirebaseManager.sharedManager.allClientProjects)
        projectsViewController.onDismiss = {
            //this is for the case of user coming back to HomeVC after pinning something
            //without this, all the client names and project names will be sorted out of wack, and not alphabetical
//            FirebaseManager.sharedManager.clientsByPinnedProj!.sort({ $0.companyName.uppercaseString < $1.companyName.uppercaseString })
//            for client:Client in self.pinnedProjects {
//                client.projects.sort({ $0.name.uppercaseString < $1.name.uppercaseString })
//            }
//            self.pinnedProjectsTableView.reloadData()
        }
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
        
        let newForm = RecordFormViewController(record: newRecord, saveOnlyFormForAddingNewRecord: true)
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

        // current blue default button version
//        var plusButton: UIButton  = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
//        plusButton.userInteractionEnabled = false
//        cell.accessoryView = plusButton
        
        // android style time clock patrick
        var imageView = UIImageView(image: UIImage(named: "ic_action_add_time"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.accessoryView = imageView
        
        // black arrows
//        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    // MARK: Floating Action Button Delegate
    
    func didSelectMenuOptionAtIndex(row: Int) {
        if (row == FloatingButtonCellIndex.PinNewprojectButton.rawValue) {
            displayProjectsViewController()
//            audioPlayer = AVAudioPlayer(contentsOfURL: tapSound, error: nil)
            //Not sure if I like this particular sound - couldn't find a good sound for it
        }
        else {
            self.audioPlayer = AVAudioPlayer(contentsOfURL: self.dingSound, error: nil)
            self.audioPlayer.play()
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            let displayName = FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray![row].0
            hud.labelText = "Logging \(displayName)"
            
            FirebaseManager.sharedManager.saveSelectedDefaultRecord(FirebaseManager.sharedManager.tuplesForFloatingDefaultsLabelsArray![row].1, completion: { (error) -> Void in
                if (error == nil) {
                    MBProgressHUD.showCompletionHUD(onView: self.view, duration: 2, customDoneText: "\(displayName) logged!", completion: nil)
                }
            })
        }
//        audioPlayer.play()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
