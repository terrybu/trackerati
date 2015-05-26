//
//  HistoryTableViewCell.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/21/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

protocol HistoryTableViewCellDelegate: class {
    func didPressDeleteButton(cell: HistoryTableViewCell)
    func didPressEditButton(cell: HistoryTableViewCell)
}

enum ActionMenuState
{
    case ShowingMenu
    case NotShowingMenu
}

enum PanDirection
{
    case Left
    case Right
}

class HistoryTableViewCell : UITableViewCell, UIGestureRecognizerDelegate
{
    private let kDeleteButtonTitle = "Delete"
    private let kEditButtonTitle = "Edit"
    private let kClientLabelPrefix = "Client: "
    private let kProjectLabelPrefix = "Project: "
    private let kHoursLabelPrefix = "Hours: "
    
    private let kShowActionButtonsVelocityThreshold: CGFloat = 300.0
    private var lastTranslationValue: CGFloat = 0.0
    
    class var cellHeight: CGFloat {
        return 95.0
    }
    
    weak var delegate: HistoryTableViewCellDelegate?
    
    private weak var deleteButton: UIButton!
    private weak var editButton: UIButton!
    private weak var infoContainerView: UIView!
    private weak var clientLabel: UILabel!
    private weak var projectLabel: UILabel!
    private weak var hoursLabel: UILabel!
    private weak var panGesture: UIPanGestureRecognizer!
    
    var currentState = ActionMenuState.NotShowingMenu
    var currentPanDirection = PanDirection.Left
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        setupActionButtons()
        setupInfoContainerView()
        setupClientLabel()
        setupProjectsLabel()
        setupHoursLabel()
        setupPanGesture()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActionButtons()
    {
        let deleteButton = UIButton(frame: CGRectZero)
        deleteButton.setTitle(kDeleteButtonTitle, forState: .Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleteButton.backgroundColor = UIColor(red:0.9, green:0.3, blue:0.26, alpha:1)
        deleteButton.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
        deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let editButton = UIButton(frame: CGRectZero)
        editButton.setTitle(kEditButtonTitle, forState: .Normal)
        editButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        editButton.backgroundColor = UIColor(red:0.23, green:0.6, blue:0.85, alpha:1)
        editButton.addTarget(self, action: "editButtonPressed:", forControlEvents: .TouchUpInside)
        editButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let deleteButtonContraints = [
            NSLayoutConstraint(item: deleteButton, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: deleteButton, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: deleteButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: deleteButton, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.25, constant: 0.0)
        ]
        
        let editButtonContraints = [
            NSLayoutConstraint(item: editButton, attribute: .Trailing, relatedBy: .Equal, toItem: deleteButton, attribute: .Leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: editButton, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: editButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: editButton, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 0.25, constant: 0.0)
        ]
        
        contentView.addSubview(deleteButton)
        contentView.addConstraints(deleteButtonContraints)
        
        contentView.addSubview(editButton)
        contentView.addConstraints(editButtonContraints)
        
        self.deleteButton = deleteButton
        self.editButton = editButton
    }
    
    private func setupInfoContainerView()
    {
        let infoContainerView = UIView(frame: CGRectZero)
        infoContainerView.backgroundColor = UIColor.whiteColor()
        infoContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let infoContainerViewConstraints = [
            NSLayoutConstraint(item: infoContainerView, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoContainerView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoContainerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: infoContainerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        ]
        contentView.addSubview(infoContainerView)
        contentView.addConstraints(infoContainerViewConstraints)
        self.infoContainerView = infoContainerView
    }
    
    private func setupClientLabel()
    {
        let clientLabel = UILabel(frame: CGRectZero)
        clientLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let clientLabelConstraints = [
            NSLayoutConstraint(item: clientLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Top, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: clientLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Bottom, multiplier: 0.33, constant: 0.0)
        ]
        infoContainerView.addSubview(clientLabel)
        infoContainerView.addConstraints(clientLabelConstraints)
        self.clientLabel = clientLabel
    }
    
    private func setupProjectsLabel()
    {
        let projectLabel = UILabel(frame: CGRectZero)
        projectLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let projectLabelConstraints = [
            NSLayoutConstraint(item: projectLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Top, relatedBy: .Equal, toItem: self.clientLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: projectLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Bottom, multiplier: 0.66, constant: 0.0)
        ]
        infoContainerView.addSubview(projectLabel)
        infoContainerView.addConstraints(projectLabelConstraints)
        self.projectLabel = projectLabel
    }
    
    private func setupHoursLabel()
    {
        let hoursLabel = UILabel(frame: CGRectZero)
        hoursLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let hoursLabelConstraints = [
            NSLayoutConstraint(item: hoursLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Top, relatedBy: .Equal, toItem: self.projectLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hoursLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.infoContainerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        ]
        infoContainerView.addSubview(hoursLabel)
        infoContainerView.addConstraints(hoursLabelConstraints)
        self.hoursLabel = hoursLabel
    }
    
    private func setupPanGesture()
    {
        let panGesture = UIPanGestureRecognizer(target: self, action: "panInfoView:")
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        infoContainerView.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
    }
    
    // MARK: Gesture Recognizer Selectors
    
    @objc
    private func panInfoView(gesture: UIPanGestureRecognizer)
    {
        switch gesture.state
        {
        case .Began:
            if currentState == .ShowingMenu {
                gesture.enabled = false
                gesture.enabled = true
            }
            
        case .Changed:
            let translation = gesture.translationInView(contentView)
            
            // Cancel gesture if trying to pan right while the menu is not showing
            if translation.x > 0.0 && currentState == .NotShowingMenu {
                panGesture.enabled = false
                panGesture.enabled = true
            }
            else {
                currentPanDirection = translation.x < lastTranslationValue ? .Left : .Right
                
                let translationStopperFactor: CGFloat
                let amountToTranslate = translation.x - infoContainerView.transform.tx
                
                if abs(infoContainerView.transform.tx) > contentView.frame.size.width / 2.0 {
                    translationStopperFactor = 0.01
                }
                else {
                    translationStopperFactor = 1.0
                }
                
                let resultingXTranslation = infoContainerView.transform.tx + (amountToTranslate * translationStopperFactor)
                infoContainerView.transform = CGAffineTransformMakeTranslation(resultingXTranslation, 0.0)
            }
            
            lastTranslationValue = translation.x
            
        case .Ended, .Cancelled:
            let velocity = gesture.velocityInView(contentView)
            let draggedFarEnoughToShowMenu = (infoContainerView.transform.tx < 0.0 && abs(infoContainerView.transform.tx) > contentView.frame.size.width / 4.0) && currentState == .NotShowingMenu
            let velocityHighEnoughToShowMenu = (velocity.x > kShowActionButtonsVelocityThreshold && currentState == .NotShowingMenu) && currentPanDirection == .Left
            let targetTransform: CGAffineTransform
            
            if draggedFarEnoughToShowMenu || velocityHighEnoughToShowMenu {
                targetTransform = CGAffineTransformMakeTranslation(-contentView.frame.size.width / 2.0, 0.0)
            }
            else {
                targetTransform = CGAffineTransformIdentity
            }

            animateCellWithTransform(targetTransform, completion: { finished in
                self.currentState = self.currentState == .NotShowingMenu ? .ShowingMenu : .NotShowingMenu
            })
            
        case .Possible, .Failed:
            break
        }
    }
    
    // MARK: Action Button Selectors
    
    @objc
    private func deleteButtonPressed(button: UIButton)
    {
        animateCellWithTransform(CGAffineTransformIdentity, completion: { finished in
            delegate?.didPressDeleteButton(self)
        })
    }
    
    @objc
    private func editButtonPressed(button: UIButton)
    {
        animateCellWithTransform(CGAffineTransformIdentity, completion: { finished in
            delegate?.didPressEditButton(self)
        })
    }
    
    // MARK: Private
    
    private func animateCellWithTransform(transform: CGAffineTransform, completion:((finished: Bool) -> ())?)
    {
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: .CurveEaseOut,
            animations:
            {
                self.infoContainerView.transform = transform
            },
            completion: completion)
    }
    // MARK: Public
    
    /**
    Sets sets the information from the Record object onto the cell
    
    :param: record A user Record
    */
    func setValuesForRecord(record: Record)
    {
        clientLabel.text = kClientLabelPrefix + record.client
        projectLabel.text = kProjectLabelPrefix + record.project
        hoursLabel.text = kHoursLabelPrefix + record.hours
    }
    
    // MARK: UIGestureRecognizer Delegate
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}
