//
//  LoginViewController.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSCore
import BluemixAppID
import BMSCore
import BMSAnalytics

class LoginViewController: UIViewController {

    @IBOutlet var containerView1: UIView!
    @IBOutlet var faceBookView: UIView!
    @IBOutlet var googleView: UIView!
    
    @IBOutlet var activitycontroller: UIActivityIndicatorView!
    @IBOutlet var containerView2: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let notificationName = Notification.Name("sendFeedBack1")
    var AccessToken :AccessToken? = nil
    var IdentityToken:IdentityToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitycontroller.isHidden = true

        // Do any additional setup after loading the view.
        self.containerView2.layer.borderWidth = 2.0;
        self.containerView2.layer.borderColor = UIColor(colorLiteralRed: 128.0/255.0, green: 203.0/255.0, blue: 196.0/255.0, alpha: 1.0).cgColor
        self.containerView2.layer.cornerRadius = 12.0;
        
        self.faceBookView.layer.cornerRadius = 9.0
        self.googleView.layer.cornerRadius = 9.0
        self.faceBookView.layer.borderColor = UIColor.white.cgColor
        self.googleView.layer.borderColor = UIColor.white.cgColor
        self.faceBookView.layer.borderWidth = 2.0
        self.googleView.layer.borderWidth = 2.0
        
        self.view.isUserInteractionEnabled = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sendFeedBack1"), object: nil);

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.loadMain), name: NSNotification.Name(rawValue: "sendFeedBack1"), object: nil)


    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func googleSignin(_ sender: Any) {
        
        self.activitycontroller.isHidden = false
        //Invoking AppID login
        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                let myDict = [ "AccessToken": accessToken, "IdentityToken":identityToken] as [String : Any]

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendFeedBack1"), object: myDict)

            }
            public func onAuthorizationCanceled() {
                print("cancel")
            }
            
            public func onAuthorizationFailure(error: AuthorizationError) {
                print(error)
            }
        }
        AppID.sharedInstance.loginWidget?.launch(delegate: delegate(view: self))
    }
    
     func loadMain(notification: NSNotification){
        
        self.view.isUserInteractionEnabled = false;
        let dict = notification.object as! [String : Any]
        appDelegate.appToken = dict["AccessToken"] as? AccessToken
        appDelegate.idToken = dict["IdentityToken"] as? IdentityToken
        
        // Set a title and message
        if let displayName = appDelegate.idToken?.name {
            appDelegate.userName = displayName;
            UserDefaults.standard.setValue(displayName, forKey: "userName");
            UserDefaults.standard.synchronize()
        }
        performSegue(withIdentifier: "unwind1", sender: self)
    }
    
    @IBAction func faceBookSignin(_ sender: Any) {
        //Invoking AppID login
        self.activitycontroller.isHidden = false

        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                let myDict = [ "AccessToken": accessToken, "IdentityToken":identityToken] as [String : Any]
                
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendFeedBack1"), object: myDict)

            }
            public func onAuthorizationCanceled() {
                print("cancel")
            }
            
            public func onAuthorizationFailure(error: AuthorizationError) {
                print(error)
            }
        }
        AppID.sharedInstance.loginWidget?.launch(delegate: delegate(view: self))
    }
    

}
