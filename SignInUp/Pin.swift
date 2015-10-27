//
//  Pin.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/27/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation
import MapKit

struct Pin {
    let userId: String
    let isVisited: Bool
    let city: String
    let country: String
    let coordinates: PFGeoPoint
}

// MARK: Saves the places the User have visited in the database.

func savePin(pin: Pin)
{
    let pinObject = PFObject(className: "Map")
    pinObject.setObject(pin.userId, forKey: "userId")
    pinObject.setObject(pin.isVisited, forKey: "isVisited")
    pinObject.setObject(pin.city, forKey: "city")
    pinObject.setObject(pin.country, forKey: "country")
    pinObject.setObject(pin.coordinates, forKey: "coordinates")
    pinObject.saveInBackgroundWithBlock(nil)
}

func getAllPins(callback: ([Pin]) -> ())
{
    var pins: [Pin] = []
    PFQuery(className: "Map").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        for object in objects!
        {
            pins.append(Pin(userId: object["userId"] as! String, isVisited: object["isVisited"] as! Bool, city: object["city"] as! String, country: object["country"] as! String, coordinates: object["coordinates"] as! PFGeoPoint))
        }
        callback(pins)
    })
}

// MARK:

func fetchVisitedPlaces(callback: ([Pin]) -> ())
{
    PFQuery(className: "Map").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        var places = Array<Pin>()
        
        for object in objects!
        {
            places.append(Pin(userId: object["userId"] as! String, isVisited: object["isVisited"] as! Bool, city: object["city"] as! String, country: object["country"] as! String, coordinates: object["coordinates"] as! PFGeoPoint))
        }
        callback(places)
    })
}
