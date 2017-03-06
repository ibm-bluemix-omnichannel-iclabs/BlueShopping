//
//  AppDelegate.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSCore
import BMSPush
import BluemixAppID
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //CONFIGURATION Values
    
    //cloudant
    var cloudantName:String = "Cloudant DB name"
    var cloudantUserName:String = "Cloudant Username"
    var cloudantPassword:String = "Cloudant password"
    var cloudantHostName:String = "Your cloudant host name"
    
    //Whisk
    var whiskKey:String = "OpenWhisk Key"
    var whiskPass:String = "OpenWhisk password"
    
    //Push Service
    var pushAppGUID:String = "push Service app GUID"
    var pushAppClientSecret:String = "push Service client secret"
    var pushAppRegion:String = "Push/AppID service region"
    
    //APPID
    let appIdTenantId = "your APPID tenant Id"
    
    let notificationName = Notification.Name("sendFeedBack")
    var userName:String = UserDefaults.standard.value(forKey: "userName") != nil ?  UserDefaults.standard.value(forKey: "userName") as! String : "User"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Initialize core
        let bmsclient = BMSClient.sharedInstance
        bmsclient.initialize(bluemixRegion: pushAppRegion)
        
        //Initialize APPID
        let appid = AppID.sharedInstance
        appid.initialize(tenantId: appIdTenantId, bluemixRegion: pushAppRegion)
        let appIdAuthorizationManager = AppIDAuthorizationManager(appid:appid)
        bmsclient.authorizationManager = appIdAuthorizationManager
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options :[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return AppID.sharedInstance.application(application, open: url, options: options)
    }
    
    
    func registerForPush () {
        
        BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: pushAppGUID, clientSecret:pushAppClientSecret)
        
    }
    
    func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        let push =  BMSPushClient.sharedInstance
        
        push.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during device registration : \(response)")
                
                print( "status code during device registration : \(statusCode)")
                
            }
            else{
                print( "Error during device registration \(error) ")
            }
        }
    }
    //Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        self.showAlert(title: "Registering for notifications", message: error.localizedDescription )
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        let payLoad = ((((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as! String)
        
        self.showAlert(title: "Recieved Push notifications", message: payLoad)
        NotificationCenter.default.post(name: notificationName, object: nil)
        
    }
    
    
    func showAlert (title:String , message:String){
        
        // create the alert
        let alert = UIAlertController.init(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.window!.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    
}

