//
//  RecordFormViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/22/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class RecordFormViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    
    private let record: Record
    
    private weak var recordFormTableView: RecordFormTableView!
    
    init(record: Record, editing: Bool)
    {
        self.record = record
        super.init(nibName: nil, bundle: nil)
        title = record.date
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
        let recordFormTableView = RecordFormTableView(frame: view.frame)
        recordFormTableView.registerClass(RecordDetailTableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        recordFormTableView.delegate = self
        recordFormTableView.dataSource = self
        view.addSubview(recordFormTableView)
        self.recordFormTableView = recordFormTableView
    }
 
    // MARK: UITableView Datasource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return RecordKey.editableValues[section].rawValue.capitalizedString
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Record.numberOfFields
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! RecordDetailTableViewCell
        return cell
    }
    
}
