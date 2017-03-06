//
//  ViewController.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BluemixAppID
import NotificationCenter

class MainViewController: UIViewController {

    var accessToken:AccessToken?
    var idToken:IdentityToken?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let notificationName = Notification.Name("sendFeedBack")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let displayName = idToken?.name {
            appDelegate.userName = displayName;
            UserDefaults.standard.setValue(displayName, forKey: "userName");
             UserDefaults.standard.synchronize()
        }
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            alertview();
        }else{
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.alertview), name: notificationName, object: nil)
        }
       // alertview();
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alertview(){
        
        let alertViewController = NYAlertViewController()
        
        // Set a title and message
        alertViewController.title = "Hello \(appDelegate.userName)"
        alertViewController.message = "How's your recent purchase , please let us know?"
        
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        
        alertViewController.titleFont = UIFont(name: "AvenirNext-Bold", size: 19.0)
        alertViewController.messageFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.buttonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        
        // Add alert actions
        let cancelAction = NYAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let nowAction = NYAlertAction(title: "Now", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "ShowFeedBack", sender: self)
        }
        
        alertViewController.addAction(cancelAction)
        
        alertViewController.addAction(nowAction)
        
        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }
}

