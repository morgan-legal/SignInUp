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
    
    @IBOutlet weak var placeVisitedLabel: UILabel!
    var placeVisited: Pin!
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placeVisitedLabel.text = placeVisited.city + ", " + placeVisited.country
        print(placeVisited.coordinates.longitude)
        print(placeVisited.coordinates.latitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBarButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func addPicturesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func deletePicturesButtonPressed(sender: UIButton) {
    }
    
    @IBAction func addPlaceVisitedBarButtonPressed(sender: UIBarButtonItem) {
        savePin(placeVisited)
        
        // Display map view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let googleMapVC = storyboard.instantiateViewControllerWithIdentifier("GoogleMaps")
        self.presentViewController(googleMapVC, animated: true, completion: nil)
    }
}
