//
//  SideMenuViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

class SideMenuViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    private let headerViewHeight: CGFloat = 50.0
    
    private weak var menuTableView: UITableView!
    private let menuItems: Array<String>
    
    init(items: Array<String>)
    {
        menuItems = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.lightGrayColor()
        
        let headerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: headerViewHeight)))
        headerView.backgroundColor = UIColor.whiteColor()
        view.addSubview(headerView)
        
        let menuTableViewFrame = CGRect(x: 0.0, y: headerViewHeight, width: view.frame.size.width, height: view.frame.size.height - headerViewHeight)
        let menuTableView = UITableView(frame: menuTableViewFrame, style: .Plain)
        menuTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(menuTableView)
        self.menuTableView = menuTableView
    }
    
    // MARK: UITableView Delegate
    
    // MARK: UITableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let titleLabel = UILabel(frame: cell.contentView.frame)
        titleLabel.text = menuItems[indexPath.row]
        cell.contentView.addSubview(titleLabel)
        return cell
    }
    
}
