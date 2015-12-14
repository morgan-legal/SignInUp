//
//  PlaceVisitedViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/29/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var pictureImageView: UIImageView!
}

class PlaceVisitedViewController: UIViewController{
    
    //var placeVisited: Pin!
    
    @IBOutlet weak var searchPlaceTextField: AutoCompleteTextField!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    var isFromDate:Bool!
    let dateFormatter = NSDateFormatter()
    var toDate: NSDate!
    var fromDate: NSDate!
    let placesClient = GMSPlacesClient()
    var places = [String: String]() // Dictionary -> KEY: Place Name, VALUE: Place ID
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        createPlaceVisitedNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Helper function
    
    func createPlaceVisitedNavigationBar() {
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x326094)
        self.navigationController?.navigationBar.topItem?.title = "Place Visited"
        
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
        updatePinPropertiesFromPlaceID( self.places[self.searchPlaceTextField.text!]! ) {
            place in
            savePin( place )
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        // Display map view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let googleMapVC = storyboard.instantiateViewControllerWithIdentifier("GoogleMaps")
        self.presentViewController(googleMapVC, animated: true, completion: nil)
    }
    
    // MARK: DatePicker TextFields
    
    @IBAction func datePickerField(sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        if sender == self.toDateTextField {
            isFromDate = false
        }
        else {
            isFromDate = true
        }
        
        datePicker.addTarget(self, action: "handlePlaceVisitedDatePickers:", forControlEvents: UIControlEvents.ValueChanged)
    }
    func handlePlaceVisitedDatePickers(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        if isFromDate == false {
            toDateTextField.text = dateFormatter.stringFromDate(sender.date)
            self.toDate = sender.date
        }
        else{
            fromDateTextField.text = dateFormatter.stringFromDate(sender.date)
            self.fromDate = sender.date
        }
    }
    
    // MARK: When user click oustide the UITextField
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.fromDateTextField.resignFirstResponder()
        self.toDateTextField.resignFirstResponder()
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
                    
                    //Initialize the dictionary
                    self!.places = [:]
                    for result in results {
                        self!.places[result.attributedFullText.string] = result.placeID
                    }
                    // assign only the keys of the dictionnary to be displayed as the autocompletestrings
                    self!.searchPlaceTextField.autoCompleteStrings = [String](self!.places.keys)
                }
        }
        
        searchPlaceTextField.onSelect =
            { [weak self] text, indexpath in
                self?.searchPlaceTextField.text = text
        }
    }
    
    func autoCompleteTextFromQuery (searchText: String, callback: ([GMSAutocompletePrediction]) -> ()) {
        if searchText != "" {
            let autoCompleteFilter = GMSAutocompleteFilter()
            autoCompleteFilter.type = GMSPlacesAutocompleteTypeFilter.City
            
            self.placesClient.autocompleteQuery( searchText, bounds: nil, filter: autoCompleteFilter, callback: { (results, error: NSError?) -> Void in
                if let error = error {
                    print("Autocomplete error \(error)")
                }
                callback( (results as? [GMSAutocompletePrediction])! )
            })
        }
    }
    
    func updatePinPropertiesFromPlaceID (placeID: String, callback: (Pin) -> ()) {
        var city: String!
        var country: String!
        var coordinates: PFGeoPoint!
        
        self.placesClient.lookUpPlaceID(placeID, callback:
            { (place, error) -> Void in
                if error != nil {
                    print("lookup place id query error: \(error!.localizedDescription)")
                    return
                }
                if let p = place {
                    var resultStringArray = p.formattedAddress.componentsSeparatedByString(", ")
                    
                    city = p.name
                    
                    if resultStringArray.count > 2 {
                        country = resultStringArray[2]
                    }
                    else {
                        country = resultStringArray[1]
                    }
                    coordinates = PFGeoPoint(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                }
                else {
                    print("No place details for \(placeID)")
                }
                callback( Pin(userId: (currentUser()?.id)!, isVisited: false, city: city, country: country, coordinates: coordinates, fromDate: self.fromDate , toDate: self.toDate ) )
        })
    }

    
    // MARK: IBActions
    
    @IBAction func addPicturesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func deletePicturesButtonPressed(sender: UIButton) {
    }
    
}
