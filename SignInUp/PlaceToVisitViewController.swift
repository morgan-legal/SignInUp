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
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var fromDateTextField: UITextField!
    
    var isFromDate:Bool!
    let dateFormatter = NSDateFormatter()
    var toDate: NSDate!
    var fromDate: NSDate!

    var places = [String: String]() // Dictionary -> KEY: Place Name, VALUE: Place ID
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createPlaceToVisitNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextField()
        handleTextFieldInterfaces()
        
        //self.view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "tap:") )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // MARK: NavigationBar Buttons
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonPressed(sender: UIBarButtonItem) {

        getGMSPlaceFromPlaceId( self.places[self.searchPlaceTextField.text!]! ) {
            place in
            
            let newPlaceToVisit =
                PlaceToVisit (
                    userId: (currentUser()?.id)!,
                    city: place.name,
                    country: getCountryFromFormattedAddress(place),
                    coordinate: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude),
                    fromDate: self.fromDate,
                    toDate: self.toDate)
            
            placesToVisit.append( newPlaceToVisit )
            savePlaceToVisit ( newPlaceToVisit )
            NSNotificationCenter.defaultCenter().postNotificationName("didDismissVC", object: nil)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)        // Display map view controller
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let googleMapVC = storyboard.instantiateViewControllerWithIdentifier("GoogleMaps")
        //self.presentViewController(googleMapVC, animated: true, completion: nil)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if self.fromDateTextField.isFirstResponder() {
            self.fromDateTextField.resignFirstResponder()
        }
        else if self.toDateTextField.isFirstResponder() {
            self.toDateTextField.resignFirstResponder()
        }
        else {
           // self.searchPlaceTextField.resignFirstResponder()
        }
    }
    
    // MARK: DatePickers

    @IBAction func datePickerField(sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        print(sender)
        if sender == self.fromDateTextField {
            isFromDate = true
        }
        else {
            isFromDate = false
        }
        datePicker.addTarget(self, action: "handleDatePickers:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleDatePickers(sender: UIDatePicker) {
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
   /* override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.searchPlaceTextField.resignFirstResponder()
        self.fromDateTextField.resignFirstResponder()
        self.toDateTextField.resignFirstResponder()
    }*/
    
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
            getAutoCompleteTextFromQuery( text ) {
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
}
