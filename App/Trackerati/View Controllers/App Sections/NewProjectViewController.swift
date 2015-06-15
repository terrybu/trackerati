//
//  NewProjectViewController.swift
//  Trackerati
//
//  Created by Terry Bu on 6/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class NewProjectViewController: UIViewController, MPGTextFieldDelegate {
    var clientData = [Dictionary<String, AnyObject>]()
    var projectData = [Dictionary<String, AnyObject>]()
    @IBOutlet weak var clientMPGTextField: MPGTextField_Swift!
    @IBOutlet weak var projectTextField: MPGTextField_Swift!
    
    init()
    {
        super.init(nibName: "NewProjectViewController", bundle: nil)
        self.title = "Add New Project"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        clientData = [
            ["DisplayText": "Hackerati", "Type": 0],
            ["DisplayText": "BAM-X", "Type": 0]
        ]
        projectData = [
            ["DisplayText": "Operations", "Type": 1],
            ["DisplayText": "Marketing", "Type": 1]
        ]
        clientMPGTextField.mDelegate = self
        projectTextField.mDelegate = self
    }
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        if (textfield.isEqual(self.projectTextField)) {
            return projectData
        }
        return clientData
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String, AnyObject>) {
        println("Dictionary received = \(data)")
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    
}
