//
//  PlaceVisitedViewController.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/29/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import UIKit
import Photos

class PictureCell: UICollectionViewCell{
    @IBOutlet weak var pictureImageView: UIImageView!
}

class PlaceVisitedViewController: UIViewController, QBImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBOutlet weak var searchPlaceTextField: AutoCompleteTextField!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    
    let imagePickerController = QBImagePickerController()
    var isFromDate:Bool!
    let dateFormatter = NSDateFormatter()
    var toDate: NSDate!
    var fromDate: NSDate!

    var places = [String: String]() // Dictionary -> KEY: Place Name, VALUE: Place ID
    let imageManager = PHImageManager()
    var imageCollection = [UIImage]()
    var imagesIds = [String]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createPlaceVisitedNavigationBar()
        self.registerForKeyboardNotifications()
   }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField()
        self.handleTextFieldInterfaces()
        
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsMultipleSelection = true
        self.imagePickerController.maximumNumberOfSelection = 6
        self.imagePickerController.showsNumberOfSelectedAssets = true
        
        self.picturesCollectionView.delegate = self
        self.picturesCollectionView.dataSource = self
        
        self.view.addGestureRecognizer( UITapGestureRecognizer(target: self, action: "tap:") )
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
    
    // MARK: NavigationBar Buttons
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func addButtonPressed(sender: UIBarButtonItem) {

        getGMSPlaceFromPlaceId( self.places[self.searchPlaceTextField.text!]! ) {
            place in
            let newPlaceVisited =
                PlaceVisited (
                userId: (currentUser()?.id)!,
                city: place.name,
                country: getCountryFromFormattedAddress(place),
                coordinate: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude),
                fromDate: self.fromDate,
                toDate: self.toDate,
                imagesIds: self.imagesIds,
                comments: self.commentsTextView.text)
            
            placesVisited.append( newPlaceVisited )
            savePlaceVisited ( newPlaceVisited )
            NSNotificationCenter.defaultCenter().postNotificationName("didDismissVC", object: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: DatePicker TextFields
    
    @IBAction func datePickerField(sender: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePicker
        
        if sender == self.fromDateTextField {
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
        if isFromDate == false {
            toDateTextField.text = dateFormatter.stringFromDate(sender.date)
            self.toDate = sender.date
        }
        else{
            fromDateTextField.text = dateFormatter.stringFromDate(sender.date)
            self.fromDate = sender.date
        }
    }
    
    // MARK: When user click oustide the the active View

    func tap(gesture: UITapGestureRecognizer) {
        if self.fromDateTextField.isFirstResponder() {
            self.fromDateTextField.resignFirstResponder()
        }
        else if self.toDateTextField.isFirstResponder() {
            self.toDateTextField.resignFirstResponder()
        }
        else if self.commentsTextView.isFirstResponder() {
            self.commentsTextView.resignFirstResponder()
        }
        else {
            self.searchPlaceTextField.resignFirstResponder()
        }
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
    
    // MARK: IBActions
    
    @IBAction func addPicturesButtonPressed(sender: UIButton) {
        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    // MARK: QBImagePickerControllerDelegate Methods
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        let options = PHImageRequestOptions()
        options.synchronous = true
        imageCollection.removeAll()
        for asset in assets {
            self.imageManager.requestImageForAsset(asset as! PHAsset, targetSize: CGSizeMake(60, 60), contentMode: .AspectFill, options: options, resultHandler: { (image, info) -> Void in
                self.imageCollection.append(image!)
                //Creates a new object for the current picture, returns its object ID and saves the ID in the imagesIds array
                savePlaceVisitedImages( NSData(data: UIImagePNGRepresentation(image!)!) ){
                    objectId in
                    self.imagesIds.append( objectId)
                    print(self.imagesIds)
                    }
            })
        }
        self.picturesCollectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.picturesCollectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PictureCell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as! PictureCell
        cell.pictureImageView.image = self.imageCollection[indexPath.row] as UIImage
        return cell
    }

    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(notification: NSNotification) {

        print("Keyboard was shown notification.")

        
        // keyboard frame is in window coordinates
        let userInfo: NSDictionary  = notification.userInfo!
        let keyboardSize = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size

        let contentInsets: UIEdgeInsets  = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        
        print("keyboard size height: \(keyboardSize!.height)")
        
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        print("frame rect: \(aRect)")
        
        aRect.size.height -= keyboardSize!.height
        
        print("frame rect height: \(aRect.size.height)")
        
        print("textView origin X, Y: \(self.commentsTextView!.frame.origin)")
        
        if self.commentsTextView.isFirstResponder() {
        //if ( !CGRectContainsPoint(aRect, self.commentsTextView!.frame.origin) ) {
            let scrollPoint:CGPoint = CGPointMake(0.0, self.commentsTextView!.frame.origin.y - keyboardSize!.height)
            print("scrollpoint: \(scrollPoint)")
            self.scrollView.setContentOffset(scrollPoint, animated: true)
            //self.scrollView.scrollRectToVisible(self.commentsTextView.frame, animated: true)
      //  }
        }
        
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(notification: NSNotification){
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
}
