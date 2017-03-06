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
    
    @IBOutlet var containerView2: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
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



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func googleSignin(_ sender: Any) {
            
        //Invoking AppID login
        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                let mainView  = UIApplication.shared.keyWindow?.rootViewController
                let afterLoginView  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
                afterLoginView?.accessToken = accessToken
                afterLoginView?.idToken = identityToken
                DispatchQueue.main.async {
                    mainView?.present(afterLoginView!, animated: true, completion: nil)
                }
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
    
    @IBAction func faceBookSignin(_ sender: Any) {
        
        //Invoking AppID login
        class delegate : AuthorizationDelegate {
            var view:UIViewController
            
            init(view:UIViewController) {
                self.view = view
            }
            public func onAuthorizationSuccess(accessToken: AccessToken, identityToken: IdentityToken, response:Response?) {
                
                
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
