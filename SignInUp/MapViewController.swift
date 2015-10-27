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

    var isVisited: Bool!
    var pins: [Pin] = []
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "profile-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToProfile:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
        getAllPins({
            pins in
            self.pins = pins
            self.displayAllPins()
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
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
        self.isVisited = true
        createAlertForPin("Add Green Pin", message: "Where did you go?")
    }
    
    @IBAction func addRedPinButtonPressed(sender: UIButton)
    {
        self.isVisited = false
        createAlertForPin("Add Red Pin", message: "Where do you want to go?")
    }
    
    // MARK: - Create an alert asking the city where we wish to put a green or red pin
    
    func createAlertForPin(title: String, message: String){
        var alertTextField: UITextField?
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Add", style: .Default)
            {   (alert: UIAlertAction!) -> Void in
                
                self.createSearchForPlace(alertTextField!.text!)
 
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.addTextFieldWithConfigurationHandler
            {  (textField: UITextField!) -> Void in
                textField.placeholder = "Name of the city"
                alertTextField = textField
        }
        
        presentViewController( alertController, animated: true, completion:nil )
    }

    // MARK: - Search for the place entered by the user / place the pin on it if found and save to parse
    
    func createSearchForPlace(cityName: String)
    {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = cityName
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil
            {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = cityName
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let coordinates = PFGeoPoint(latitude: pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)
            
            let country = self.getCountryNameFromCoordinates(pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)
            savePin( Pin(userId: (currentUser()?.id)!, isVisited: self.isVisited, city: cityName, country: country, coordinates: coordinates) )
            
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.addAnnotation(pointAnnotation)
        }
    }
    
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func displayAllPins() {
        for pin in pins
        {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = pin.city + ", " + pin.country
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
            
            self.isVisited = pin.isVisited
            self.mapView.addAnnotation(pointAnnotation)
        }

    }
    
    // MARK: - MapView Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        let currentPin: [Pin]
        currentPin = pins.filter({return $0.city == annotation.title!!})
 
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            if currentPin.isEmpty == false {
                if currentPin[0].isVisited == true {
                    pinView!.pinTintColor = UIColor.greenColor()
                }
                else {
                    pinView!.pinTintColor = UIColor.redColor()
                }
            }
            else
            {
                if self.isVisited == true {
                    pinView!.pinTintColor = UIColor.greenColor()
                }
                else {
                    pinView!.pinTintColor = UIColor.redColor()
                }
            }
            
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func getCountryNameFromCoordinates(latitude: Double, longitude: Double) -> String {
        // Add below code to get address for touch coordinates.
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        var country: String = ""
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]

            print(placeMark.country)
            
            country = placeMark.country!
        })
        
        return country

    }
}
