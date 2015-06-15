//
//  NewProjectViewController.swift
//  Trackerati
//
//  Created by Terry Bu on 6/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class NewProjectViewController: UIViewController, MPGTextFieldDelegate {
    var clientsArray = FirebaseManager.sharedManager.allClientProjects
    var clientDataForMPG = [Dictionary<String, AnyObject>]()
    var projectDataForMPG = [Dictionary<String, AnyObject>]()
    var uniqueProjectNamesSet = NSMutableSet()
    @IBOutlet weak var clientMPGTextField: MPGTextField_Swift!
    @IBOutlet weak var projectMPGTextField: MPGTextField_Swift!
    
    init()
    {
        super.init(nibName: "NewProjectViewController", bundle: nil)
        self.title = "Add New Project"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        setUpMPGTextFields()
        setUpNavButtons()
        parseDataForMPGTextFields(clientsArray!)
    }
    
    //MARK: Set-Up postload
    
    private func setUpMPGTextFields() {
        clientMPGTextField.mDelegate = self
        projectMPGTextField.mDelegate = self
        clientMPGTextField.enabled = false
        projectMPGTextField.enabled = false
    }
    
    private func parseDataForMPGTextFields([Client]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            for client:Client in self.clientsArray! {
                self.clientDataForMPG.append(["DisplayText" : client.companyName, "Type": 0])
                for project:Project in client.projects {
                    self.uniqueProjectNamesSet.addObject(project.name)
                }
            }
            self.uniqueProjectNamesSet.enumerateObjectsUsingBlock({ (projectName, idx) -> Void in
                self.projectDataForMPG.append(["DisplayText" : projectName, "Type": 1])
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.clientMPGTextField.enabled = true
                self.projectMPGTextField.enabled = true
            })
        })
    }
    
    private func setUpNavButtons() {
        var backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "closeViewController");
        navigationItem.leftBarButtonItem = backButton;
        
        var saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveNewProject")
        navigationItem.rightBarButtonItem = saveButton;
    }
    
    //MARK: MPGTextFieldDelegate Methods
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        if (textfield.isEqual(self.projectMPGTextField)) {
            return projectDataForMPG
        }
        return clientDataForMPG
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String, AnyObject>) {
        println("Dictionary received = \(data)")
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    //MARK: MISC
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
