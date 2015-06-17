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
    var onDismiss: (() -> ())?
    
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
        self.navigationItem.prompt = "Input both fields and press Save to add new project"
        
        setNavUIToHackeratiColors()
        
        setUpMPGTextFields()
        setUpNavButtons()
        parseDataForMPGTextFields(clientsArray!)
    }
    
    //MARK: Set-Up postload
    
    private func setUpMPGTextFields() {
        clientMPGTextField.mDelegate = self
        clientMPGTextField.addTarget(self, action: "clientTextFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        projectMPGTextField.mDelegate = self
        projectMPGTextField.addTarget(self, action: "projectTextFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)


        clientMPGTextField.enabled = false
        projectMPGTextField.enabled = false
    }
    
    func clientTextFieldDidChange() {
        if (!self.clientMPGTextField.text.isEmpty && !self.projectMPGTextField.text.isEmpty) {
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func projectTextFieldDidChange() {
        if (!self.clientMPGTextField.text.isEmpty && !self.projectMPGTextField.text.isEmpty) {
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
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
        saveButton.enabled = false
    }
    
    //MARK: MPGTextFieldDelegate Methods
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        if (textfield.isEqual(self.projectMPGTextField)) {
            return projectDataForMPG
        }
        return clientDataForMPG
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String, AnyObject>) {
        println(data)
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return false
    }
    
    
    //MARK: Navbutton Actions
    
    @objc
    private func closeViewController()
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.onDismiss!()
        })
    }
    
    @objc
    private func saveNewProject()
    {
        if (self.clientMPGTextField.text.isEmpty || self.projectMPGTextField.text.isEmpty) {
            let alertController = UIAlertController(title: "Empty Input", message:
                "Either Client Name or Project Name cannot be empty", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Saving New Project"
        
        FirebaseManager.sharedManager.saveNewProject(self.clientMPGTextField.text, projectString: self.projectMPGTextField.text, completion: { (error, duplicateFound) -> Void in
            if (error != nil || duplicateFound) {
                var alertController : UIAlertController?
                if (error != nil) {
                    println(error)
                    alertController = UIAlertController(title: "Error", message:
                        "There was an error while trying to save new project to database, please try again later", preferredStyle: UIAlertControllerStyle.Alert)
                }
                else if (duplicateFound) {
                    alertController = UIAlertController(title: "Same project name exists", message:
                        "You cannot add this project name under this client because it already exists in current database", preferredStyle: UIAlertControllerStyle.Alert)
                }
                alertController!.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController!, animated: true, completion: nil)
                hud.hide(true)
            }
            else {
                MBProgressHUD.showCompletionHUD(onView: self.view, duration: 1.5, completion: {
                    self.closeViewController()
                })
            }
        })
    }
    
    
    
}
