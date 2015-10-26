//
//  ViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navBar:UINavigationBar! =  self.navigationController?.navigationBar
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!
        ]
        
        navBar.titleTextAttributes = attributes
        
        createAccountButton.layer.cornerRadius = 5
        logInButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

