//
//  GoogleMapViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/28/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit


class GoogleMapViewController: UIViewController, GMSMapViewDelegate {
    
    var placesToVisit: [Pin] = []
    var placesVisited: [Pin] = []
    var googleMapView: GMSMapView!
    var placesClient: GMSPlacesClient?
    
    @IBOutlet weak var mapView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "map-button"), style: UIBarButtonItemStyle.Plain, target: self, action: "goToMap:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
        fetchPlacesToVisit({
            placesVisited in
            self.placesVisited = placesVisited
            for place in placesVisited{
                self.displayMarkerFromLocationCoordinates(place)
            }
        })
        
        fetchPlacesVisited({
            placesToVisit in
            self.placesToVisit = placesToVisit
            for place in placesToVisit{
                self.displayMarkerFromLocationCoordinates(place)
            }

        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func searchTextFieldChanged(sender: UITextField) {
    
        
        //let visibleRegion = self.googleMapView.projection.visibleRegion()
        //let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        //let filter = GMSAutocompleteFilter()
        var res:[GMSAutocompletePrediction] = []
        
        //filter.type = GMSPlacesAutocompleteTypeFilter.City
        placesClient?.autocompleteQuery(self.searchTextField.text!, bounds: nil, filter: nil, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            res = (results as? [GMSAutocompletePrediction])!
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        })
        
        print(res)
    
    }


    override func viewDidLayoutSubviews() {
        
        let camera = GMSCameraPosition.cameraWithLatitude(1.285, longitude: 103.848, zoom: 2)
        googleMapView = GMSMapView.mapWithFrame(self.mapView.bounds, camera: camera)

        // Map type Normal. Regular display of the map
        googleMapView.mapType = kGMSTypeNormal
        // Enable user location
        // The myLocation attribute of the mapView may be null
        if let mylocation = googleMapView.myLocation {
            NSLog("User's location: %@", mylocation)
        } else {
            NSLog("User's location is unknown")
        }
        self.googleMapView.delegate = self
        placesClient = GMSPlacesClient()
        //self.mapView.addSubview(self.googleMapView)
        self.mapView.addSubview(self.googleMapView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPlaceVisitedButtonPressed(sender: UIButton) {
        //createAlertForPin("Add Green Pin", message: "Where did you go?")
       // self.performSegueWithIdentifier("toAddPlaceVisitedStep1Segue", sender: self)
    }
    
    @IBAction func addPlaceToVisitButtonPressed(sender: UIButton) {
        //createAlertForPin("Add Red Pin", message: "Where do you want to go?")
        
        //self.placeAutocomplete(self.searchTextField.text!)
    }
    
    
    func goToMap(button: UIBarButtonItem) {
        let mapVC = self.storyboard!.instantiateViewControllerWithIdentifier("Map")
        let navController = UINavigationController(rootViewController: mapVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(navController, animated:true, completion: nil)
    }
    
    // MARK: - Add Markers to the Map
    
    func displayMarkerFromLocationCoordinates( location: Pin ) {
        var markerColor = UIColor()
        let position = CLLocationCoordinate2DMake(location.coordinates.latitude, location.coordinates.longitude)
        let marker = GMSMarker(position: position)
        marker.title = location.city
        
        if location.isVisited == true {
            markerColor = UIColor.greenColor()
        }
        else {
            markerColor = UIColor.redColor()
        }
        marker.icon = GMSMarker.markerImageWithColor(markerColor)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = googleMapView
    }
    
    
    func createAlertForPin(title: String, message: String){
        var alertTextField: UITextField?
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default)
            {   (alert: UIAlertAction!) -> Void in
                
                self.placeAutocomplete(alertTextField!.text!)
                
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
    
    func placeAutocomplete( searchCity: String) {
        //let visibleRegion = self.googleMapView.projection.visibleRegion()
        //let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        let filter = GMSAutocompleteFilter()
        var res:[GMSAutocompletePrediction] = []
        
        filter.type = GMSPlacesAutocompleteTypeFilter.City
        placesClient?.autocompleteQuery(searchCity, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            res = (results as? [GMSAutocompletePrediction])!
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    print(result.attributedFullText)
                    //print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        })
        
       // print(placesClient?.description)
    }
    
   func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
   /*      //let visibleRegion = self.googleMapView.projection.visibleRegion()
        //let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        //let filter = GMSAutocompleteFilter()
        var res:[GMSAutocompletePrediction] = []
        
        //filter.type = GMSPlacesAutocompleteTypeFilter.City
        placesClient?.autocompleteQuery("Paris", bounds: nil, filter: nil, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            res = (results as? [GMSAutocompletePrediction])!
            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        })
        
        print(res)*/
    }
}
