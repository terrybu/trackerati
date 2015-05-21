//
//  HistoryTableViewCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

class HistoryTableViewCell : UITableViewCell
{
    private let kClientLabelPrefix = "Client: "
    private let kProjectLabelPrefix = "Project: "
    private let kHoursLabelPrefix = "Hours: "
    
    class var cellHeight: CGFloat {
        return 95.0
    }
    
    private weak var clientLabel: UILabel!
    private weak var projectLabel: UILabel!
    private weak var hoursLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupClientLabel()
        setupProjectsLabel()
        setupHoursLabel()
    }

    private func setupClientLabel()
    {
        let clientLabel = UILabel(frame: CGRectZero)
        clientLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let clientLabelConstraints = [
            NSLayoutConstraint(item: clientLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 0.33, constant: 0.0)
        ]
        self.contentView.addSubview(clientLabel)
        self.contentView.addConstraints(clientLabelConstraints)
        self.clientLabel = clientLabel
    }
    
    private func setupProjectsLabel()
    {
        let projectLabel = UILabel(frame: CGRectZero)
        projectLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let projectLabelConstraints = [
            NSLayoutConstraint(item: projectLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Top, relatedBy: .Equal, toItem: self.clientLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 0.66, constant: 0.0)
        ]
        self.contentView.addSubview(projectLabel)
        self.contentView.addConstraints(projectLabelConstraints)
        self.projectLabel = projectLabel
    }
    
    private func setupHoursLabel()
    {
        let hoursLabel = UILabel(frame: CGRectZero)
        hoursLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let hoursLabelConstraints = [
            NSLayoutConstraint(item: hoursLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Top, relatedBy: .Equal, toItem: self.projectLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        ]
        self.contentView.addSubview(hoursLabel)
        self.contentView.addConstraints(hoursLabelConstraints)
        self.hoursLabel = hoursLabel
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValuesForRecord(record: Record)
    {
        clientLabel.text = kClientLabelPrefix + record.client
        projectLabel.text = kProjectLabelPrefix + record.project
        hoursLabel.text = kHoursLabelPrefix + record.hours
    }
    
}
