//
//  PlacesVisited.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 12/15/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation
import MapKit

struct PlaceToVisit {
    let userId: String
    let city: String
    let country: String
    let coordinate: CLLocationCoordinate2D
    let fromDate: NSDate
    let toDate: NSDate
    //let images: [NSData]
    //let comments: String
}


// MARK: Fetch all the places visited

func getPlacesToVisit ( callback: ([PlaceToVisit]) -> () ) {
    getPlacesQuery("PlacesToVisit").findObjectsInBackgroundWithBlock { (places, error) in
        
        //var placesToVisit = [PlaceToVisit]()
        
        for place in places! {
            placesToVisit.append(
                PlaceToVisit(
                    userId: place["userId"] as! String,
                    city: place["city"] as! String,
                    country: place["country"] as! String,
                    coordinate: convertPFGeoPointToCLLocationCoordinate2D(place["coordinate"] as! PFGeoPoint),
                    fromDate: place["fromDate"] as! NSDate,
                    toDate: place["toDate"] as! NSDate)
            )
        }
        callback( placesToVisit )
    }
}

func savePlaceToVisit (placeToVisit: PlaceToVisit)
{
    let pfObject = PFObject(className: "PlacesToVisit")
    pfObject.setObject(placeToVisit.userId, forKey: "userId")
    pfObject.setObject(placeToVisit.city, forKey: "city")
    pfObject.setObject(placeToVisit.country, forKey: "country")
    pfObject.setObject(convertCLLocationCoordinate2DtoPFGeoPoint(placeToVisit.coordinate), forKey: "coordinate")
    pfObject.setObject(placeToVisit.fromDate, forKey: "fromDate")
    pfObject.setObject(placeToVisit.toDate, forKey: "toDate")
    
    pfObject.saveInBackground()
}