//
//  User.swift
//  SignInUp
//
//  Created by Morgan Le Gal on 10/26/15.
//  Copyright © 2015 Morgan Le Gal. All rights reserved.
//

import Foundation


struct User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    private let pfUser: PFUser
}

// MARK: Converts a PFUser to a User for modularity of the PARSE backend

func pfUserToUser(user: PFUser) -> User {
    return User(id: user.objectId!,
        firstName: user.objectForKey("firstName") as! String,
        lastName: user.objectForKey("lastName") as! String,
        email: user.objectForKey("email") as! String,
        pfUser: user)
}

// MARK: Return a PFUser converted into a User if we have a currentUser.

func currentUser() -> User? {
    if let user = PFUser.currentUser() {
        return pfUserToUser(user)
    }
    return nil
}