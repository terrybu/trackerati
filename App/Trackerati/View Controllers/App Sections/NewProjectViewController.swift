//
//  NewProjectViewController.swift
//  Trackerati
//
//  Created by Terry Bu on 6/11/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class NewProjectViewController: UIViewController {
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        self.title = "Add New Project or Client"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()

    }
    
    
}
