//
//  SignUpViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var accountInfoView: UIView!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        accountInfoView.layer.cornerRadius = 5
        createAccountButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountButtonPressed(sender: UIButton)
    {
        
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        let firstName = self.firstnameTextField.text
        let lastName = self.lastnameTextField.text
        
        
        if isValidEmail(email!) == false
        {
            self.showAlert("Invalid", message: "Your email address is not valid")
        }
        else if password!.characters.count < 8
        {
            self.showAlert("Invalid", message: "Your password is too short. You need at least 8 characters.")
        }
        else if firstName!.characters.count == 0
        {
            self.showAlert("Invalid", message: "Please enter your first name.")
        }
        else if lastName!.characters.count == 0
        {
            self.showAlert("Invalid", message: "Please enter your last name.")
        }
        else
        {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let user = PFUser()
            
            user.username = email
            user.email = email
            user.password = password
            user["firstName"] = firstName
            user["lastName"] = lastName
            
            // Sign up the user asynchronously
            user.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if error != nil
                {
                    self.showAlert("Error", message: "\(error)")
                }
                else
                {
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(title: "Email address verification",
                        message: "We have sent you an email that contains a link - you must click this link before you can continue.",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    alertController.addAction(UIAlertAction(title: "Ok",
                        style: UIAlertActionStyle.Default,
                        handler: { alertController in self.processSignOut()})
                    )
                    // Display alert
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }

    
    // MARK: Helper functions

    func processSignOut()
    {
        // Sign out
        PFUser.logOut()
        
        // Display main view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("LogIn")
        self.presentViewController(mainVC, animated: true, completion: nil)
    }
    
    func isValidEmail( testStr: String ) -> Bool
    {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
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
