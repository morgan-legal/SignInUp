//
//  ProfileViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePictureImage: UIImageView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationItem.titleView = UIImageView(image: UIImage(named: "profile-header"))
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToMap:")
        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.emailLabel.text = currentUser()?.email
        self.firstNameLabel.text = currentUser()?.firstName
        self.lastNameLabel.text = currentUser()?.lastName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func goToMap(button: UIBarButtonItem) {
        let mapVC = self.storyboard!.instantiateViewControllerWithIdentifier("Map")
        let navController = UINavigationController(rootViewController: mapVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(navController, animated:true, completion: nil)
    }

    @IBAction func logOutButtonPressed(sender: UIButton)
    {
        
        // Send a request to log out a user
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let homeVC:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
            let navController = UINavigationController(rootViewController: homeVC)
            self.presentViewController(navController, animated: true, completion: nil)
        })
        
    }
}
