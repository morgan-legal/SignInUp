//
//  PlaceToVisitViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 12/7/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class PlaceToVisitViewController: UIViewController {

    @IBOutlet weak var searchPlaceTextField: AutoCompleteTextField!
    let placesClient = GMSPlacesClient()
    let filter = GMSAutocompleteFilter()
    var placesIDs: [String] = []
    var searchResults: [GMSAutocompletePrediction] = []
    var locations = [String]()
    
    var placeToVisit: Pin!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*let leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "addButtonPressed:")
        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)*/
        configureTextField()
        handleTextFieldInterfaces()
        createPlaceToVisitNavigationBar()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filter.type = GMSPlacesAutocompleteTypeFilter.City
        
        configureTextField()
        handleTextFieldInterfaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Helper function
    
    func createPlaceToVisitNavigationBar() {
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x326094)
        self.navigationController?.navigationBar.topItem?.title = "Place To Visit"
        
        let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed:")
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "addButtonPressed:")
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
    
    // MARK: Actions
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        //self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonPressed(sender: UIBarButtonItem) {
       // savePin(placeVisited)
        
        // Display map view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let googleMapVC = storyboard.instantiateViewControllerWithIdentifier("GoogleMaps")
        self.presentViewController(googleMapVC, animated: true, completion: nil)
    }
    
    // MARK: AutoCompleteTextFields
    
    private func configureTextField(){
        searchPlaceTextField.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        searchPlaceTextField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        searchPlaceTextField.autoCompleteCellHeight = 40.0
        searchPlaceTextField.maximumAutoCompleteCount = 10
        searchPlaceTextField.hidesWhenSelected = true
        searchPlaceTextField.hidesWhenEmpty = true
        searchPlaceTextField.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        searchPlaceTextField.autoCompleteAttributes = attributes
    }
    
    private func handleTextFieldInterfaces(){
        searchPlaceTextField.onTextChange =
        { [weak self] text in
            self!.autoCompleteTextFromQuery( text ) {
                results in
                var places = [String]()
                for result in results {
                    places.append(result.attributedFullText.string)
                }
                self!.searchPlaceTextField.autoCompleteStrings = places
            }
        }
        
        searchPlaceTextField.onSelect =
        { [weak self] text, indexpath in
            self?.searchPlaceTextField.text = text
        }
    }
    

    func autoCompleteTextFromQuery (searchText: String, callback: ([GMSAutocompletePrediction]) -> ()) {
        if searchText != "" {
            self.placesClient.autocompleteQuery( searchText, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
                
                if let error = error {
                    print("Autocomplete error \(error)")
                }
                
                let searchResults = (results as? [GMSAutocompletePrediction])!
                
                for result in (results as? [GMSAutocompletePrediction])! {
                    self.placesIDs.append(result.placeID)
                }
                
                callback( searchResults )
            })
        }
    }
}
