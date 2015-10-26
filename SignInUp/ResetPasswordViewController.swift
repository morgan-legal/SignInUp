//
//  ResetPasswordViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetPasswordButtonPressed(sender: UIButton)
    {
        // convert the email string to lower case
        let emailToLowerCase = self.emailTextField.text?.lowercaseString
        
        // remove any whitespaces before and after the email address
        let emailClean = emailToLowerCase!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        PFUser.requestPasswordResetForEmailInBackground( emailClean ) {
            (success, error) -> Void in
            
            if error == nil
            {
                self.showAlert("Success", message: "Check your emails!")
            }
            else
            {
                self.showAlert("Error", message: "Cannot complete request")
            }
        
        }
    }

    // MARK: Helper functions
    func showAlert (title: String, message: String)
    {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        // add the button "Ok" to the alert
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        // Display alert
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
