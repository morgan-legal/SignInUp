//
//  GoogleMapViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/28/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit
import CoreLocation

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var googleMapView: GMSMapView!
    var placesClient: GMSPlacesClient?
    
    let locationManager = CLLocationManager()
    var didFindMyLocation = false

    @IBOutlet weak var mapView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createMapNavigationBar()
        reloadMarkers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDismissViewController:", name: "didDismissVC", object: nil)
        
        getPlacesToVisit({
            placesToVisit in
            for placeToVisit in placesToVisit{
                self.addPlaceToVisitMarker(placeToVisit)
            }
        })
        getPlacesVisited({
            placesVisited in
            for placeVisited in placesVisited {
                self.addPlaceVisitedMarker(placeVisited)
            }
        })

        // User Location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }

    override func viewDidLayoutSubviews() {
        
        let camera = GMSCameraPosition.cameraWithLatitude(1.285, longitude: 103.848, zoom: 2)
        googleMapView = GMSMapView.mapWithFrame(self.mapView.bounds, camera: camera)

        // Map type Normal. Regular display of the map
        googleMapView.mapType = kGMSTypeNormal
        // Enable user location
        // The myLocation attribute of the mapView may be null
        if let mylocation = googleMapView.myLocation {
            print("User's location: %@", mylocation)
        } else {
            print("User's location is unknown")
        }
        self.googleMapView.delegate = self
        placesClient = GMSPlacesClient()
        
        self.mapView.addSubview(self.googleMapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didDismissViewController(notification: NSNotification) {
        reloadMarkers()
    }
    
    func reloadMarkers() {
        // remove all markers
        if self.googleMapView != nil {
            self.googleMapView.clear()
        }
        
        for placeVisited in placesVisited {
            self.addPlaceVisitedMarker(placeVisited)
        }
        for placeToVisit in placesToVisit{
            self.addPlaceToVisitMarker(placeToVisit)
        }
    }
    
    // MARK: Helper functions
    
    func createMapNavigationBar() {
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x326094)
        self.navigationController?.navigationBar.topItem?.title = "Blink"
        
        var placeVisitedImage = UIImage(named: "placeVisited-Small")
        placeVisitedImage = placeVisitedImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let leftBarButtonItem = UIBarButtonItem(image: placeVisitedImage, style: UIBarButtonItemStyle.Plain, target: self, action: "placeVisitedButtonPressed:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
 
        var placeToVisitImage = UIImage(named: "placeToVisit-Small")
        placeToVisitImage = placeToVisitImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let rightBarButtonItem = UIBarButtonItem(image: placeToVisitImage, style: UIBarButtonItemStyle.Plain, target: self, action: "placeToVisitButtonPressed:")
        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
    }

    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: IBActions - Adding green and red pins
    
    func placeVisitedButtonPressed(sender: UIButton){
        let placeVisitedVC = self.storyboard!.instantiateViewControllerWithIdentifier("placeVisitedNavSegue")
        //let navController = UINavigationController(rootViewController: placeToVisitVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(placeVisitedVC, animated:true, completion: nil)
    }
    
    func placeToVisitButtonPressed(sender: UIButton){
        let placeToVisitVC = self.storyboard!.instantiateViewControllerWithIdentifier("placeToVisitNavSegue")
        //let navController = UINavigationController(rootViewController: placeToVisitVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(placeToVisitVC, animated:true, completion: nil)
    }

    // MARK: Location Manager Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first {
            self.googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 1, bearing: 0, viewingAngle: 0)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            self.googleMapView.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    // MARK: Navigation between VCs
    
   /* func goToProfile(button: UIBarButtonItem) {
        let profileVC = self.storyboard!.instantiateViewControllerWithIdentifier("Profile")
        let navController = UINavigationController(rootViewController: profileVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(navController, animated:true, completion: nil)
    }*/
    
    // MARK: Add Markers to the Map
    
    func addPlaceVisitedMarker( placeVisited: PlaceVisited ) {
        let marker = GMSMarker(position: placeVisited.coordinate)
        marker.title = placeVisited.city + ", " + placeVisited.country
        marker.icon = GMSMarker.markerImageWithColor( UIColor.greenColor() )
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }
    
    func addPlaceToVisitMarker( placeToVisit: PlaceToVisit ) {
        let marker = GMSMarker(position: placeToVisit.coordinate)
        marker.title = placeToVisit.city + ", " + placeToVisit.country
        marker.icon = GMSMarker.markerImageWithColor( UIColor.redColor() )
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }

}
