# RideAustin Rider
> iOS App for RideAustin Rider

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  


Ridesharing is valuable to all citizens, empowers drivers and riders, saves lives and is part of any transportation future. We created RideAustin to get the city moving again and to reinvest in our community.

RideAustin is a non-profit rideshare built for the Austin community. It is powered by donations, with paid and volunteer hours from both the Austin tech community and the broader Austin community working together. We believe ridesharing saves lives, empowers drivers & riders and is part of any transportation future.


![](https://static1.squarespace.com/static/57302ab61d07c088bf6e694b/57408281e3214003460a6d3a/5740828137013bfb815d1b4a/1463845509237/phone-main.jpg?format=1000w)

## Requirements

- bundler 2.0.1
- iOS 12.0+
- Ruby 2.5.5
- SSH for github access
- Xcode 11.3.1

## Installation

- Install [bundler](https://bundler.io) to manage ruby gems
```
gem install bundler --version=2.0.1
```

- Install gems

```
bundle install
```
- Install pods

```
bundle exec pod install
```

- After adding environment variables, generate the app plist by running
```
scripts/infoplist.sh
```

## Troubleshooting

- After running pod install if it fails with the following error

```
Unable to add a source with url `git@github.com:ride-austin/ios-podspecs.git` named `ride-austin`
```
check SSH configuration  check guide [SSH Help](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)  

## Environmental Variables

This project is configured with Fastlane to work with CLI tools  here are the environmental variables available in the fastlane that can be provided in `/fastlane/.env.default` file 

### Required

- __API_KEY__ Added as header X-Api-Key to every request

- __APP_IDENTIFIER_PROD:__  Add your Production App ID here for example `com.organization.appName`   

- __DELIVER_USERNAME:__ This name is shown in the messages for example  `RideAustin Version 5.1.0b (708) uploaded by:xyz@rideaustin.com`  in this message `xyz@rideaustin.com` is through this variable.  Also used in built in fastlane actions for example  `match` , `pilot`  

- __FASTLANE_TEAM_ID:__ The ID of your Developer Portal team if you're in multiple teams e.g. XXXXXXYVXX

- __GOOGLE_MAP_KEY:__ To use the Maps SDK for iOS you must have an API key. The API key is a unique identifier that is used to authenticate requests associated with your project for usage and billing purposes. To learn more see the [guide](https://developers.google.com/maps/documentation/ios-sdk/get-api-key) and [API Key Best Practices](https://developers.google.com/maps/api-key-best-practices) 

- __GOOGLE_MAP_DIRECTIONS_KEY:__ To use the Directions API, you must get an API key which you can then add to your mobile app, website, or web server. The API key is used to track API requests associated with your project for usage and billing. To learn more about API keys, see the [API Key Best Practices](https://developers.google.com/maps/api-key-best-practices) 

- __GOOGLE_SERVICE_INFO_PLIST_PRODUCTION:__ When using circleci, run ```base64 GoogleService-Info.plist``` and use the output as environment variable. Otherwise, just add the file Resources/Plists/GoogleService-Info.plist to enable firebase services.

- __MATCH_GIT_FULL_NAME:__ git user full name to commit

- __MATCH_GIT_URL:__ URL to the git repo containing all the certificates

- __MATCH_GIT_USER_EMAIL:__ git user email to commit

- __MATCH_PASSWORD:__ Provide the password for the match in this variable. Here is the guideline for configuring the match [guide](https://docs.fastlane.tools/actions/match/)

- __MATCH_USERNAME:__ Your Apple ID Username

- __TEAM_ID_QA:__  The ID of your App Store Connect team if you're in multiple teams. e.g  `118247423`


### Optional

- __APPCENTER_APP_NAME:__ Add your app name to be uploaded on Appcenter to get App name find at `https://appcenter.ms/orgs/<APPCENTER_OWNER_NAME>/apps/<APPCENTER_APP_NAME>`

- __APPCENTER_OWNER_NAME:__ Add owner name of the app to be uploaded on Appcenter to get App owner name find at `https://appcenter.ms/orgs/<APPCENTER_OWNER_NAME>`

- __APPCENTER_API_TOKEN:__ Add Api token for Appcenter.  Goto. `https://appcenter.ms/orgs/<organization-name>/applications?os=iOS` then in account settings, you can create token.  `Settings / API tokens`

- __APP_IDENTIFIER_QA:__  Add your QA App ID here for example `com.organization.appName`   

- __CRASHLYTICS_API_TOKEN:__ Get the api token from   [organization settings](https://www.fabric.io/settings/organizations) page

- __CRASHLYTICS_BUILD_SECRET:__ Get the build secret from   [organization settings](https://www.fabric.io/settings/organizations) page

- __HOCKEYAPP_API_TOKEN:__ While using HockeyApp , with the help of API Tokens we can control the access rights for a single app or multiple apps. The common API Access token key (All Apps) can be useful for all the apps. But, in case you want to give specific access right such as only upload, or just a read only, we should create specific access token. builds to devices. Please check the [guide](https://dailydotnettips.com/obtaining-the-app-specific-hockeyapp-api-token/) for help.

- __HOCKEYAPP_ID_QA:__  Add APP ID from hockey app here  get it from the main page of the app.  Just select the application in the hockey app it will open the page showing the overview tab. 

- __SLACK_URL:__ Provide webhook url for the slack to post the updates on the slack. Follow these steps to add webhook in your slack channel  [guide](https://api.slack.com/incoming-webhooks)


## Contribute 

We would love you for the contribution to **RideAustin Rider**, check the  [LICENSE](LICENSE) file for more info.

## Meta

Distributed under the MIT license. See [LICENSE](LICENSE) for more information.

