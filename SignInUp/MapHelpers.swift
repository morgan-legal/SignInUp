//
//  MapHelpers.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 12/16/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation


// MARK: Converts CLLocationCoordintate2D to PFGeoPoint

func convertCLLocationCoordinate2DtoPFGeoPoint ( coordinate: CLLocationCoordinate2D ) -> PFGeoPoint {
    return PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
}

func convertPFGeoPointToCLLocationCoordinate2D ( coordinate: PFGeoPoint ) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
}

// MARK: Create a Query

func getPlacesQuery(className: String) -> PFQuery! {
    return PFQuery(className: className).whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
}
func getPlaceImagesQuery(imageId: String) -> PFQuery! {
    return PFQuery(className: "Images").whereKey("objectId", equalTo: imageId)
}

func getAutoCompleteTextFromQuery (searchText: String, callback: ([GMSAutocompletePrediction]) -> ()) {
    if searchText != "" {
        let autoCompleteFilter = GMSAutocompleteFilter()
        autoCompleteFilter.type = GMSPlacesAutocompleteTypeFilter.City
        
        GMSPlacesClient().autocompleteQuery( searchText, bounds: nil, filter: autoCompleteFilter, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            callback( (results as? [GMSAutocompletePrediction])! )
        })
    }
}

func getCountryFromFormattedAddress(place: GMSPlace) -> String {
    let countryArray = place.formattedAddress.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ".,-") )
    return countryArray.last!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}

func getGMSPlaceFromPlaceId (placeId: String, callback: (GMSPlace) -> ()) {
    GMSPlacesClient().lookUpPlaceID(placeId, callback:
        { (place, error) -> Void in
            if error != nil {
                print("lookup place id query error: \(error!.localizedDescription)")
                return
            }
            else {
                print("No place details for \(placeId)")
            }
            callback( place! )
    })
}