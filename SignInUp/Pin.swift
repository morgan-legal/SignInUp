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
    let fromDate: NSDate
    let toDate: NSDate
}

struct PinPhotos {
    let userId: String
    let images: [NSData]
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
    pinObject.setObject(pin.fromDate, forKey: "fromDate")
    pinObject.setObject(pin.toDate, forKey: "toDate")
    pinObject.saveInBackgroundWithBlock(nil)
}

func saveImages(pinPhotos: PinPhotos){
    let images = PFObject(className: "Photos")
    images.setObject(pinPhotos.userId, forKey: "userId")
    images.setObject(pinPhotos.images, forKey: "photos")
    images.saveInBackgroundWithBlock(nil)
}

// MARK:

func getAllPins(callback: ([Pin]) -> ())
{
    var pins: [Pin] = []
    PFQuery(className: "Map").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        for object in objects!
        {
            pins.append(Pin(userId: object["userId"] as! String, isVisited: object["isVisited"] as! Bool, city: object["city"] as! String, country: object["country"] as! String, coordinates: object["coordinates"] as! PFGeoPoint, fromDate: object["fromDate"] as! NSDate, toDate: object["toDate"] as! NSDate))
        }
        callback(pins)
    })
}

// MARK: Fetch all the places visited

func fetchPlacesVisited(callback: ([Pin]) -> ())
{
    PFQuery(className: "Map").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        
        
        var placesVisited = Array<Pin>()
        
        for object in objects!
        {
            if object["isVisited"] as! Bool == true
            {
                placesVisited.append(Pin(userId: object["userId"] as! String, isVisited: object["isVisited"] as! Bool, city: object["city"] as! String, country: object["country"] as! String, coordinates: object["coordinates"] as! PFGeoPoint, fromDate: object["fromDate"] as! NSDate, toDate: object["toDate"] as! NSDate))
            }
                //placesVisited.filter({return $0.isVisited == true})
        }
        // Sends back the array of data
        callback( placesVisited )
    })
}

// MARK: Fecth all the places to visit

func fetchPlacesToVisit(callback: ([Pin]) -> ())
{
    PFQuery(className: "Map").whereKey("userId", equalTo: PFUser.currentUser()!.objectId!).findObjectsInBackgroundWithBlock({
        objects, error in
        
        var placesToVisit = Array<Pin>()
        
        for object in objects!
        {
            if object["isVisited"] as! Bool == false
            {
                placesToVisit.append(Pin(userId: object["userId"] as! String, isVisited: object["isVisited"] as! Bool, city: object["city"] as! String, country: object["country"] as! String, coordinates: object["coordinates"] as! PFGeoPoint, fromDate: object["fromDate"] as! NSDate, toDate: object["toDate"] as! NSDate))
            }
        }
        // Sends back the array of data
        callback( placesToVisit )
    })
}
