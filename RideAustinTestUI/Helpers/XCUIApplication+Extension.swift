//
//  XCUIApplication+Extension.swift
//  Ride
//
//  Created by Roberto Abreu on 4/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

import XCTest

extension XCUIApplication {
    
    static let XCUIAppEnvironmentAutomation = "AUTOMATION"
    static let XCUIAppBehaviorNoAuth = "ATTNoAuth"
    static let XCUIAppBehaviorNoNetwork = "ATTNoNetwork"
    static let XCUIAppBehaviorSkipLogin = "ATTSkipLogin"
    static let XCUIAppArgumentConfiguration = "--StubConfiguration"
    static let XCUIAppArgumentConfigurationDefault = "Default"
    static let XCUIAppArgumentConfigurationDefaultHouston = "DefaultHouston"
    static let XCUIAppArgumentConfigurationRealAuth = "RealAuth"
    static let XCUIAppArgumentConfigurationCancelledRide = "CancelledRide"
    static let XCUIAppArgumentConfigurationCancelledRideResubmitted = "CancelledRideResubmitted"
    static let XCUIAppArgumentConfigurationUpgradeToSUV = "UpgradeToSUV"
    static let XCUIAppArgumentConfigurationUpgradeToSUVInOtherScreen = "UpgradeToSUVInOtherScreen"
    static let XCUIAppArgumentConfigurationUpgradeToSUVPF1 = "UpgradeToSUVPF1"
    static let XCUIAppArgumentConfigurationUpgradeToSUVExpired = "UpgradeToSUVExpired"
    static let XCUIAppArgumentConfigurationUpgradeToSUVAccepted = "UpgradeToSUVAccepted"
    static let XCUIAppArgumentConfigurationUpgradeToSUVAccepted2 = "UpgradeToSUVAccepted2"
    static let XCUIAppArgumentConfigurationUpgradeToSUVDeclined = "UpgradeToSUVDeclined"
    static let XCUIAppArgumentConfigurationUpgradeToSUVCancelled = "UpgradeToSUVCancelled"
    static let XCUIAppArgumentConfigurationUpgradeToSUVAcceptedThenCancelled = "UpgradeToSUVAcceptedThenCancelled"
    static let XCUIAppArgumentConfigurationUpgradeToSUVStartingRideAtDriverOnWay = "RideAtDriverOnWayAndUpgradeToSUV"
    static let XCUIAppArgumentConfigurationSynchronizeRideAtRatingScreen = "RideAtRatingScreen"
    static let XCUIAppArgumentConfigurationUpgradeToSUVWithNoNetwork = "UpgradeToSUVWithNoNetwork"
    static let XCUIAppArgumentConfigurationUpdateComment1 = "UpdateComment1"
    static let XCUIAppArgumentConfigurationAvoidCleaningRatingCache = "AvoidCleaningRatingCache"
    static let XCUIAppArgumentConfigurationExcludeCardsForCurrentRider = "kExcludeCardsKeyInCurrentRider"
    static let XCUIAppArgumentConfigurationExcludeCharityForCurrentRider = "kExcludeCharityKeyInCurrentRider"
    static let XCUIAppArgumentConfigurationIncludeUnpaidBalanceForCurrentRider = "kIncludeUnpaidKeyInCurrentRider"
    
    convenience init(launchArguments:[String],launchEnvironment:[String:String] = [XCUIApplication.XCUIAppEnvironmentAutomation:XCUIApplication.XCUIAppBehaviorNoAuth]) {
        self.init()
        self.launchArguments = launchArguments
        self.launchEnvironment = launchEnvironment
    }

}
