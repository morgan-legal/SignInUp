//
//  PlacesVisited.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/26/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation
import MapKit

struct PlaceVisited {
    let name: String
    let coordinates: PFGeoPoint
}

// MARK: Saves the places the User have visited in the database.

func savePlaceVisited(placeVisited: PlaceVisited) {
    let placeVisitedObject = PFObject(className: "PlacesVisited")
    placeVisitedObject.setObject(placeVisited.name, forKey: "cityName")
    placeVisitedObject.setObject(placeVisited.coordinates, forKey: "coordinates")
    placeVisitedObject.saveInBackgroundWithBlock(nil)
}


// MARK:

func fetchVisitedPlaces(callback: ([PlaceVisited]) -> ())
{
    PFQuery(className: "PlacesVisited").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        var places = Array<PlaceVisited>()
        
        for object in objects!
        {
            places.append( PlaceVisited(name: object["cityName"] as! String, coordinates: object["coordinates"] as! PFGeoPoint) )
        }
        callback(places)
    })
}