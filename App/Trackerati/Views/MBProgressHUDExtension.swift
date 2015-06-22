//
//  MBProgressHUDExtension.swift
//  Trackerati
//
//  Created by Clayton Rieck on 6/2/15.
//  Copyright (c) 2015 The Hackerati. All rights reserved.
//

extension MBProgressHUD
{
    class func showCompletionHUD(onView view: UIView, duration: Double, customDoneText: String, completion:(() -> Void)?)
    {
        MBProgressHUD.hideHUDForView(view, animated: true)
        
        let completedHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        completedHUD.mode = .CustomView
        completedHUD.customView = UIImageView(image: UIImage(named: "CompletedCheckMark"))
        completedHUD.labelText = customDoneText
        let timeUntilHide = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(duration) * NSEC_PER_SEC))
        dispatch_after(timeUntilHide, dispatch_get_main_queue(), {
            MBProgressHUD.hideHUDForView(view, animated: true)
            if let closure = completion {
                closure()
            }
        })
    }
}
