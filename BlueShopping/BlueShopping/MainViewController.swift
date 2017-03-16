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

    @IBOutlet var hiddenView: UIView!
    var done:Bool = true;
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let notificationName = Notification.Name("sendFeedBack")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
     
        
        if (appDelegate.idToken == nil){
            
            performSegue(withIdentifier: "loginVCSS", sender: self)
            
        }else{
            
            if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                
                NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.alertview), name: notificationName, object: nil)
                appDelegate.registerForPush()
            }else if(done){
                done = false
                alertview();
            }
        }
        
    }
    
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        // Pull any data from the view controller which initiated the unwind segue.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.navigationItem.hidesBackButton = true
        
        if (appDelegate.idToken != nil){
            self.hiddenView.isHidden = true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alertview(){
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Hello \(appDelegate.userName)", message: "How's your recent purchase , please let us know?", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        let acceptAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.performSegue(withIdentifier: "ShowFeedBack", sender: self)
        }
        actionSheetController.addAction(acceptAction)
        actionSheetController.addAction(cancelAction)

        self.present(actionSheetController, animated: true, completion: nil)
    }
}

