//
//  NewProjectViewController.swift
//  Trackerati
//
//  Created by Terry Bu on 6/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class NewProjectViewController: UIViewController, MPGTextFieldDelegate {
    var sampleData = [Dictionary<String, AnyObject>]()

    @IBOutlet weak var mpgTextField: MPGTextField_Swift!
    
    init()
    {
        super.init(nibName: "NewProjectViewController", bundle: nil)
        self.title = "Add New Project or Client"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        mpgTextField.mDelegate = self
        sampleData.append(["DisplayText": "hallelujah displaytext", "DisplaySubText": "subtext"])
    }
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return sampleData
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String, AnyObject>) {
        println("Dictionary received = \(data)")
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    
}
