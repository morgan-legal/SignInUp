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
    
    var placeVisited: Pin!
    
    @IBOutlet weak var placeVisitedTextField: UITextField!

    //Dates 
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    var isFromDate:Bool!
    
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        createPlaceVisitedNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // placeVisitedLabel.text = placeVisited.city + ", " + placeVisited.country
       // print(placeVisited.coordinates.longitude)
      //  print(placeVisited.coordinates.latitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        savePin(placeVisited)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        /*// Display map view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let googleMapVC = storyboard.instantiateViewControllerWithIdentifier("GoogleMaps")
        self.presentViewController(googleMapVC, animated: true, completion: nil)*/
    }
    
    // MARK: DatePicker TextFields
    
    @IBAction func datePickerField(sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        if sender == self.toDateTextField {
            isFromDate = true
        }
        else {
            isFromDate = false
        }
        
        datePicker.addTarget(self, action: "handlePlaceVisitedDatePickers:", forControlEvents: UIControlEvents.ValueChanged)
    }
    func handlePlaceVisitedDatePickers(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        if isFromDate == true {
            toDateTextField.text = dateFormatter.stringFromDate(sender.date)
        }
        else{
            fromDateTextField.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    // When user click oustide the UITextField
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.fromDateTextField.resignFirstResponder()
        self.toDateTextField.resignFirstResponder()
    }
    
    // MARK: IBActions
    
    @IBAction func addPicturesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func deletePicturesButtonPressed(sender: UIButton) {
    }
    
}
