//
//  UserHeaderView.swift
//  Trackerati
//
//  Created by Clayton Rieck on 5/18/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

import Foundation
import UIKit

class UserHeaderView : UIView
{
    private weak var profilePictureImageView: UIImageView!
    private weak var profileNameLabel: UILabel!
    private weak var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        
        setupImageView()
        setupNameLabel()
        setupActivityIndicator()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applyProfileInfo:", name: kUserProfilePictureDidFinishDownloading, object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNameLabel()
    {
        let profileNameLabel = UILabel(frame: CGRectZero)
        profileNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        profileNameLabel.textColor = UIColor.blackColor()
        profileNameLabel.numberOfLines = 0
        profileNameLabel.lineBreakMode = .ByTruncatingTail
        profileNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(profileNameLabel)
        self.profileNameLabel = profileNameLabel
        
        let constraints = [
            NSLayoutConstraint(item: profileNameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileNameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: self.profilePictureImageView.frame.size.width),
            NSLayoutConstraint(item: profileNameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileNameLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileNameLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        ]
        self.addConstraints(constraints)
    }
    
    private func setupImageView()
    {
        let profilePictureImageView = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSize(width: frame.size.height, height: frame.size.height)))
        profilePictureImageView.contentMode = .ScaleAspectFit
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = 10.0
        profilePictureImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(profilePictureImageView)
        self.profilePictureImageView = profilePictureImageView
        
        let constraints = [
            NSLayoutConstraint(item: profilePictureImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profilePictureImageView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0)
        ]
        self.addConstraints(constraints)
    }
    
    func setupActivityIndicator()
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.center = CGPoint(x: self.center.x - kMinimumSlideoutOffset, y: self.center.y)
        addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        activityIndicator.startAnimating()
    }
    
    @objc
    private func applyProfileInfo(notification: NSNotification)
    {
        profileNameLabel.text = GoogleLoginManager.sharedManager.profileName
        
        if let profilePicture = GoogleLoginManager.sharedManager.profilePicture {
            profilePictureImageView.image = profilePicture
        }
        
        activityIndicator?.removeFromSuperview()
        activityIndicator?.stopAnimating()
    }
    
}
