//
//  MapViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/22/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var coordinates: PFGeoPoint!
    
    var placesVisited: [PlaceVisited] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationItem.titleView = UIImageView(image: UIImage(named: "nav-header"))
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "profile-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToProfile:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        fetchVisitedPlaces({
            placesVisited in
            self.placesVisited = placesVisited
        })
        
        displayPlacesVisitedPins()
    
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
    
    @IBAction func addGreenPinButtonPressed(sender: UIButton)
    {
        var whereIWentTextField: UITextField?
        
        let addGreenPinAlert = UIAlertController(title: "Add Green Pin", message: "Where have you been?", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Add", style: .Default)
        {   (alert: UIAlertAction!) -> Void in
            
            self.localSearchRequest = MKLocalSearchRequest()
            self.localSearchRequest.naturalLanguageQuery = whereIWentTextField!.text
            self.localSearch = MKLocalSearch(request: self.localSearchRequest)
            self.localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil{
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = whereIWentTextField!.text
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.pinAnnotationView.pinTintColor = UIColor.greenColor()
                

                self.coordinates = PFGeoPoint(latitude: self.pointAnnotation.coordinate.latitude, longitude: self.pointAnnotation.coordinate.longitude)
                //savePlaceVisited( PlaceVisited(name: whereIWentTextField!.text!, coordinates: self.coordinates, user: currentUser()!) )
                
                self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            }
            
        }
        
        addGreenPinAlert.addAction(defaultAction)
        addGreenPinAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        addGreenPinAlert.addTextFieldWithConfigurationHandler
        {  (textField: UITextField!) -> Void in
            textField.placeholder = "Name of the city"
            whereIWentTextField = textField
        }
        
        presentViewController( addGreenPinAlert, animated: true, completion:nil )
    }
    
    @IBAction func addRedPinButtonPressed(sender: UIButton)
    {
        displayPlacesVisitedPins()
    }
    
    func displayPlacesVisitedPins()
    {
        for placeVisited in self.placesVisited
        {
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title =  placeVisited.name
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: placeVisited.coordinates.latitude, longitude: placeVisited.coordinates.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.pinAnnotationView.tintColor = UIColor.greenColor()
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    func displayPlacesToVisitPins() {
        
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
}
