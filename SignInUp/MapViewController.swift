//
//  MapViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationItem.titleView = UIImageView(image: UIImage(named: "nav-header"))
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "profile-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToProfile:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToProfile(button: UIBarButtonItem){
        
        let profileVC = self.storyboard!.instantiateViewControllerWithIdentifier("Profile")
        let navController = UINavigationController(rootViewController: profileVC) 
        self.presentViewController(navController, animated:true, completion: nil)
    }
}
