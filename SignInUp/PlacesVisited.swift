//
//  PlacesVisited.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 12/15/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation
import MapKit

struct PlaceVisited {
    let userId: String
    let city: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    let fromDate: NSDate
    let toDate: NSDate
    let imagesIds: [String]
    let comments: String
}


// MARK: Fetch all the places visited

func getPlacesVisited ( callback: ([PlaceVisited]) -> () ) {
    getPlacesQuery("PlacesVisited").findObjectsInBackgroundWithBlock { (places, error) in
        
        //var placesVisited = [PlaceVisited]()
        
        for place in places! {
            placesVisited.append(
                PlaceVisited(
                    userId: place["userId"] as! String,
                    city: place["city"] as! String,
                    country: place["country"] as! String,
                    coordinate: convertPFGeoPointToCLLocationCoordinate2D(place["coordinate"] as! PFGeoPoint),
                    fromDate: place["fromDate"] as! NSDate,
                    toDate: place["toDate"] as! NSDate,
                    imagesIds: place["imagesIds"] as! [String],
                    comments: place["comments"] as! String)
            )
        }
        callback( placesVisited )
    }
}

func savePlaceVisited (placeVisited: PlaceVisited)
{
    let pfObject = PFObject(className: "PlacesVisited")
    pfObject.setObject(placeVisited.userId, forKey: "userId")
    pfObject.setObject(placeVisited.city, forKey: "city")
    pfObject.setObject(placeVisited.country, forKey: "country")
    pfObject.setObject(convertCLLocationCoordinate2DtoPFGeoPoint(placeVisited.coordinate), forKey: "coordinate")
    pfObject.setObject(placeVisited.fromDate, forKey: "fromDate")
    pfObject.setObject(placeVisited.toDate, forKey: "toDate")
    pfObject.setObject(placeVisited.imagesIds, forKey: "imagesIds")
    pfObject.setObject(placeVisited.comments, forKey: "comments")
    pfObject.saveInBackground()
}

func getPlaceVisitedImages () {
    getPlaceImagesQuery("Images").findObjectsInBackgroundWithBlock { (images, error) in
    
    }
}

// Saves and return the object ID

func savePlaceVisitedImages (image: NSData, callback: (String) -> ()) {
    let pfObject = PFObject(className: "Images")
    pfObject.setObject(image, forKey: "image")
    pfObject.saveInBackground()
    pfObject.saveInBackgroundWithBlock {
        (success, error) -> Void in
        if success {
            //Gets called if save was done properly
            callback(pfObject.objectId!)
        }
        else {
            print(error)
        }
    }
}
