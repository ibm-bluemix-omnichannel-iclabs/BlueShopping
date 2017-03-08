//
//  FeedbackViewController.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSCore
import OpenWhisk

class FeedbackViewController: UIViewController,FloatRatingViewDelegate, UIGestureRecognizerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var reviewTextView: UITextView!
    @IBOutlet var floatRatingView: FloatRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = true
        self.floatRatingView.floatRatings = false
        self.floatRatingView.floatRatings = false
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.tap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackViewController.keyboardDidShow(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                //isKeyboardActive = false
                UIView.animate(withDuration: duration,
                                           delay: TimeInterval(0),
                                           options: animationCurve,
                                           animations: {
                                            // move scroll view height to 0.0
                                            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)

                },
                                           completion: { _ in
                })
            } else {
                //isKeyboardActive = true
                
                var userInfo = notification.userInfo!
                var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                
                
                UIView.animate(withDuration: duration,
                                           delay: TimeInterval(0),
                                           options: animationCurve,
                                           animations: { 
                                            // move scroll view height to    endFrame?.size.height ?? 0.0 
                                            self.view.frame = CGRect(x: 0, y:  -(keyboardFrame.size.height), width: self.view.frame.size.width, height: self.view.frame.size.height)

                },
                                           completion: { _ in
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
    }
    

    func tap() {
        self.view.endEditing(true)
    }

    @IBAction func clearReview(_ sender: Any) {
        self.floatRatingView.rating = 0
        self.reviewTextView.text = ""
        
    }
    @IBAction func popBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendReview(_ sender: Any) {
        
        
        var devId = String()
        let authManager  = BMSClient.sharedInstance.authorizationManager
        devId = authManager.deviceIdentity.ID!;
        
        let textValue = reviewTextView.text;
        let nameValue = appDelegate.userName;
        let productNumber = randomString(length: 5)

        let whiskKey = appDelegate.whiskKey
        let whiskPass = appDelegate.whiskPass
        let credentialsConfiguration = WhiskCredentials(accessKey: whiskKey, accessToken: whiskPass)
        let whisk = Whisk(credentials: credentialsConfiguration)
        
        let db = appDelegate.cloudantName
        let userName = appDelegate.cloudantUserName
        let password = appDelegate.cloudantPassword
        let hostName = appDelegate.cloudantHostName
        
        var params = Dictionary<String, Any>()
        params["username"] = userName
        params["host"] = hostName
        params["password"] = password
        params["dbname"] = db
        let randomId = randomString(length: 2);
        let doc = ["_id": randomId, "deviceIds":"\(devId)", "message":"\(textValue!)", "name":"\(nameValue)", "productNumber": "\(productNumber)"]
        params["doc"] = doc
        
        do {
            
            try whisk.invokeAction(name: "write", package: "cloudant", namespace: "whisk.system", parameters: params as AnyObject?, hasResult: false, callback: {(reply, error) -> Void in
                if let error = error {
                    //do something
                    print("Error invoking action \(error.localizedDescription)")
                } else {
                    print("Action invoked! \( reply)")
                    self.alertview();
                }
            })
        } catch {
            print("Error \(error)")
        }
        
        
      /*  var devId = String()
        let authManager  = BMSClient.sharedInstance.authorizationManager
        devId = authManager.deviceIdentity.ID!
        
        let textValue = reviewTextView.text;
        // var idNumber = idText.text;
        let nameValue = appDelegate.userName;
        
        let dict:NSMutableDictionary = NSMutableDictionary()
        
        var devIdArray = [String]()
        devIdArray.append(devId);
        
        dict.setValue(devIdArray, forKey: "deviceIds")
        dict.setValue(textValue, forKey:"message")
        dict.setValue(nameValue, forKey: "name")
        
        
        let randomId = randomString(length: 2);
        let db = appDelegate.CloudantName
        let userName = appDelegate.cloudantUserName
        
        
        
        
        
        let authData = appDelegate.cloudantPermission
        
        // here "jsonData" is the dictionary encoded in JSON data
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        let data = authData.data(using: String.Encoding.utf8);
        let base64 = data!.base64EncodedData(options: [])
        var url = String();
        url = "http://\(userName).cloudant.com/\(db)/\(randomId)";
        
        var request = URLRequest(url: URL(string: url)!);
        request.httpMethod = "PUT"
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData;
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            // self.alertview();
        }
        task.resume()*/
        
    }
    func randomString(length: Int) -> String {
        let randomString:NSMutableString = NSMutableString(capacity: length)
        
        let letters:NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var i: Int = 0
        
        while i < length {
            
            let randomIndex:Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }
        
        return String(randomString)
    }
    func alertview(){
        
        let alertViewController = NYAlertViewController()
        
        // Set a title and message
        alertViewController.title = "THank you"
        alertViewController.message = "Thanks for your valuable Feed back"
        
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
        
        alertViewController.titleFont = UIFont(name: "AvenirNext-Bold", size: 19.0)
        alertViewController.messageFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        
        // Add alert actions
        let cancelAction = NYAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
            
                self.navigationController?.popViewController(animated: true)

        }

        alertViewController.addAction(cancelAction)
        
        
        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }
}
