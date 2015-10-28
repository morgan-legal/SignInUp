//
//  GoogleMapViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/28/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit


class GoogleMapViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationItem.titleView = UIImageView(image: UIImage(named: "profile-header"))
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "map-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToMap:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
    }
    
    override func loadView() {
        let camera = GMSCameraPosition.cameraWithLatitude(1.285, longitude: 103.848, zoom: 12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.mapType = kGMSTypeNormal
        self.view = mapView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}
