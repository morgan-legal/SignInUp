//
//  mapAnnotation.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/28/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var isVisited: Bool
       
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, isVisited: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.isVisited = isVisited
        
        super.init()
    }
}