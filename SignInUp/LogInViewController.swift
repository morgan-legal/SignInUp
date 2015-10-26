//
//  LogInViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var LogInButton: UIButton!
    @IBOutlet weak var LogInView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        LogInView.layer.cornerRadius = 5
        LogInButton.layer.cornerRadius = 5
        //LogInButton.layer.borderWidth = 1
        //LogInButton.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LogInButtonPressed(sender: UIButton)
    {
        let email = self.emailTextField.text?.lowercaseString
        let password = self.passwordTextField.text
        
        // Validate the text fields
        if email!.characters.count < 5
        {
            self.showAlert("Invalid", message: "Your email is not valid.")
        }
        else if password!.characters.count < 8
        {
            self.showAlert("Invalid", message: "Your password is too short. You need at least 8 characters")
        }
        else
        {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(email!, password: password!)
            {   ( user: PFUser?, error: NSError? ) -> Void in
                
                // Stop the spinner
              spinner.stopAnimating()
                
                if user != nil
                {
                      // Check that the user has verified their email address
                    if user!["emailVerified"] as! Bool == true
                    {
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.processSignIn()
                            //self.performSegueWithIdentifier( "logInToMapSegue", sender: self )
                        }
                    }
                    else
                    {
                        // User needs to verify email address before continuing
                        let alertController = UIAlertController(
                            title: "Email address verification",
                            message: "We have sent you an email that contains a link - you must click this link before you can continue.",
                            preferredStyle: UIAlertControllerStyle.Alert
                        )
                        alertController.addAction(UIAlertAction(title: "Ok",
                            style: UIAlertActionStyle.Default,
                            handler: { alertController in self.processSignOut()})
                        )
                        // Display alert
                        self.presentViewController(
                            alertController, 
                            animated: true, 
                            completion: nil
                        )
                    }
                    
                }
                else
                {
                    self.showAlert("Error", message: "\(error)")
                }
            }
        }
    }
    
    // MARK: Helper functions
    
    func processSignOut()
    {
        // Sign out
        PFUser.logOut()
        
        // Display main view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(homeVC, animated: true, completion: nil)
    }
    
    func processSignIn()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewControllerWithIdentifier("MapNavController")
        //self.navigationController!.pushViewController(mapVC, animated: true)
        self.presentViewController(mapVC, animated: true, completion: nil)
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
