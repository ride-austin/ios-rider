//
//  RAUITestConstants.swift
//  Ride
//
//  Created by Marcos Alba on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import Foundation

let TestUser1 = Account(username:"user1@gmail.com", password: "test123")
let TestUser2 = Account(username:"austinrider@xo.com", password: "test123")
let TestUser3 = Account(username:"notdriver@xo.com", password: "test123")
let TestUserInvalid = Account(username:"invalid@gmail.com", password: "123456")
let TestUserDisabled = Account(username:"disabledUser@gmail.com", password: "123456")
let TestUserInactive = Account(username:"inactivedriver@xo.com", password: "test123")
let TestUserNetworkFailed = Account(username:"network@failed.com", password: "123456")
let TestUserFB = Account(username:"rider_saaltle_automation@tfbnw.net", password: "passwordAutomation123")
let TestUserNew  = Account(username:"anewuser@xo.com", password: "test123")

struct Account {
    var username: String
    var password: String
}
