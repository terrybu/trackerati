//
//  SideMenuViewController.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/14/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

protocol SideMenuViewControllerDelegate: class {
    
    func didMakePageSelection(selection: SideMenuSelection)
}

enum SideMenuSelection: String {
    case Home = "Home"
    case History = "History"
    case Settings = "Settings"
    case LogOut = "Log Out"
    
    static let AllSelections = [Home, History, Settings, LogOut]
}

class SideMenuViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private let kCellReuseIdentifier = "cell"
    private let kHeaderViewHeight: CGFloat = 50.0 + UIApplication.sharedApplication().statusBarFrame.size.height
    
    private weak var menuTableView: UITableView!
    private let menuItems: [SideMenuSelection]
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    init(items: [SideMenuSelection])
    {
        menuItems = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.mainScreen().bounds)
        
//        setupMenuBackground()
        setupMenuTableView()
    }
    
    private func setupMenuTableView()
    {
        let menuTableView = UITableView(frame: view.frame, style: .Plain)
        menuTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        menuTableView.delegate = self
        menuTableView.dataSource = self
//        menuTableView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:0.7)
        menuTableView.backgroundColor = UIColor(rgba: kHackeratiBlue)
        menuTableView.separatorStyle = .None
        menuTableView.scrollEnabled = false
        menuTableView.tableHeaderView = customHeaderView()
        menuTableView.tableFooterView = UIView(frame: CGRectZero)
        view.addSubview(menuTableView)
        self.menuTableView = menuTableView
    }
    
    private func setupMenuBackground()
    {
        let backgroundImageView = UIImageView(image: UIImage(named: "Hackerati")!)
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(backgroundImageView)
        
        let constraints = [
            NSLayoutConstraint(item: backgroundImageView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundImageView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: backgroundImageView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        ]
        self.view.addConstraints(constraints)
    }
    
    // MARK: UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.didMakePageSelection(menuItems[indexPath.row])
    }
    
    // MARK: UITableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
//        setupLabelOnCell(cell, indexPath: indexPath) Why do this instead of just using cell's default text label?
        cell.textLabel!.text = menuItems[indexPath.row].rawValue
        cell.textLabel!.textColor = UIColor.whiteColor()
        var icon = UIImage(named: menuItems[indexPath.row].rawValue)
        icon?.imageWithRenderingMode(.AlwaysTemplate)
        cell.imageView!.image = icon
        cell.imageView!.tintColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: Private
    
    private func customHeaderView() -> UIView
    {
        return SideMenuUserHeaderView(frame: CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: kHeaderViewHeight)))
    }
    
    private func setupLabelOnCell(cell: UITableViewCell, indexPath: NSIndexPath)
    {
        let titleLabelFrame = CGRect(x: cell.layoutMargins.left, y: 0.0, width: cell.contentView.frame.size.width, height: cell.contentView.frame.size.height)
        let titleLabel = UILabel(frame: titleLabelFrame)
        titleLabel.text = menuItems[indexPath.row].rawValue
        titleLabel.textColor = UIColor.whiteColor()
        cell.contentView.addSubview(titleLabel)
    }
    
}
