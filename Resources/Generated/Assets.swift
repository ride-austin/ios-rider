// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let dotGreenSelected = ImageAsset(name: "dot-green-selected")
  internal static let dotGreen = ImageAsset(name: "dot-green")
  internal static let dotRedSelected = ImageAsset(name: "dot-red-selected")
  internal static let dotRed = ImageAsset(name: "dot-red")
  internal static let pinGreenPickup = ImageAsset(name: "pinGreenPickup")
  internal static let pinRedLocation = ImageAsset(name: "pinRedLocation")
  internal static let addPicture = ImageAsset(name: "AddPicture")
  internal static let back = ImageAsset(name: "back")
  internal static let iconBack = ImageAsset(name: "icon_back")
  internal static let background = ImageAsset(name: "Background")
  internal static let iconCarBack = ImageAsset(name: "iconCarBack")
  internal static let iconCarFront = ImageAsset(name: "iconCarFront")
  internal static let iconCarInside = ImageAsset(name: "iconCarInside")
  internal static let iconCarTrunk = ImageAsset(name: "iconCarTrunk")
  internal static let premium = ImageAsset(name: "premium")
  internal static let regular = ImageAsset(name: "regular")
  internal static let suv = ImageAsset(name: "suv")
  internal static let driverBackground = ImageAsset(name: "DriverBackground")
  internal static let fareEstimate = ImageAsset(name: "Fare-Estimate")
  internal static let fieldBox = ImageAsset(name: "Field-Box")
  internal static let fieldActive = ImageAsset(name: "Field-active")
  internal static let fieldUnactive = ImageAsset(name: "Field-unactive")
  internal static let field = ImageAsset(name: "Field")
  internal static let fields = ImageAsset(name: "Fields")
  internal static let iconCar = ImageAsset(name: "Icon-car")
  internal static let iconFacebook = ImageAsset(name: "Icon-facebook")
  internal static let iconLicense = ImageAsset(name: "Icon-license")
  internal static let iconNeedHelp = ImageAsset(name: "Icon-need-help")
  internal static let iconP = ImageAsset(name: "Icon-p")
  internal static let iconTime = ImageAsset(name: "Icon-time")
  internal static let iconUser = ImageAsset(name: "Icon-user")
  internal static let launchImageTileDiagonal = ImageAsset(name: "LaunchImageTileDiagonal")
  internal static let launchImageTileOld = ImageAsset(name: "LaunchImageTileOld")
  internal static let hourGlassIcon = ImageAsset(name: "hourGlassIcon")
  internal static let popupHeader = ImageAsset(name: "popupHeader")
  internal static let bgFieldActive = ImageAsset(name: "bgFieldActive")
  internal static let bgFieldDisable = ImageAsset(name: "bgFieldDisable")
  internal static let bgPriorityFare = ImageAsset(name: "bgPriorityFare")
  internal static let showContacts = ImageAsset(name: "ShowContacts")
  internal static let arrowDown = ImageAsset(name: "arrowDown")
  internal static let driverBack = ImageAsset(name: "driverBack")
  internal static let logoRideAustin = ImageAsset(name: "logoRideAustin")
  internal static let logoRideAustinWhite = ImageAsset(name: "logoRideAustin_white")
  internal static let logoRideHouston = ImageAsset(name: "logoRideHouston")
  internal static let pinIcon = ImageAsset(name: "pinIcon")
  internal static let splashAustin = ImageAsset(name: "splashAustin")
  internal static let terms = ImageAsset(name: "Terms")
  internal static let way = ImageAsset(name: "Way")
  internal static let iconPinkCar = ImageAsset(name: "icon-pink-car")
  internal static let iconPinkDrivers = ImageAsset(name: "icon-pink-drivers")
  internal static let active = ImageAsset(name: "active")
  internal static let addIcon = ImageAsset(name: "add-icon")
  internal static let backgroundDriverRating = ImageAsset(name: "backgroundDriverRating")
  internal static let backgroundNumberplate = ImageAsset(name: "backgroundNumberplate")
  internal static let backgroundRoundUpHeader = ImageAsset(name: "backgroundRoundUpHeader")
  internal static let bevoBuckLogo = ImageAsset(name: "bevoBuckLogo")
  internal static let bevoPay = ImageAsset(name: "bevoPay")
  internal static let emailUnverifiedIcon = ImageAsset(name: "email-unverified-icon")
  internal static let iconRoundUp = ImageAsset(name: "iconRoundUp")
  internal static let car = ImageAsset(name: "car")
  internal static let carPhotoPlaceholderWithCar = ImageAsset(name: "carPhotoPlaceholderWithCar")
  internal static let cellIconBlank = ImageAsset(name: "cellIconBlank")
  internal static let check = ImageAsset(name: "check")
  internal static let checkboxOff = ImageAsset(name: "checkbox-off")
  internal static let checkboxOn = ImageAsset(name: "checkbox-on")
  internal static let circleGreenIcon = ImageAsset(name: "circle-green-icon")
  internal static let circleRedIcon = ImageAsset(name: "circle-red-icon")
  internal static let cancel = ImageAsset(name: "Cancel")
  internal static let close1 = ImageAsset(name: "Close-1")
  internal static let closeAlert = ImageAsset(name: "Close_alert")
  internal static let close = ImageAsset(name: "close")
  internal static let splitFareCloseBtnIcon = ImageAsset(name: "split-fare-close-btn-icon")
  internal static let creditsAvailableIcon = ImageAsset(name: "credits-available-icon")
  internal static let creditsNoBalanceIcon = ImageAsset(name: "credits-no-balance-icon")
  internal static let creditsWalletIcon = ImageAsset(name: "credits-wallet-icon")
  internal static let directConnectIcon = ImageAsset(name: "direct-connect-icon")
  internal static let discountIcon = ImageAsset(name: "discount-icon")
  internal static let donate = ImageAsset(name: "donate")
  internal static let driveWithIconActive = ImageAsset(name: "drive-with-icon-active")
  internal static let dropdown = ImageAsset(name: "dropdown")
  internal static let emailUnverifiedFieldIcon = ImageAsset(name: "email-unverified-field-icon")
  internal static let emailVerifiedFieldIcon = ImageAsset(name: "email-verified-field-icon")
  internal static let emailVerifiedIcon = ImageAsset(name: "email-verified-icon")
  internal static let enterNewDestination = ImageAsset(name: "enterNewDestination")
  internal static let etaClockIcon = ImageAsset(name: "eta-clock-icon")
  internal static let etaDestinationBackground = ImageAsset(name: "eta-destination-background")
  internal static let fieldBg = ImageAsset(name: "fieldBg")
  internal static let findCurrentLocationIcon = ImageAsset(name: "find-current-location-icon")
  internal static let forward = ImageAsset(name: "forward")
  internal static let greenPin = ImageAsset(name: "green-pin")
  internal static let greenCircleFilled = ImageAsset(name: "greenCircleFilled")
  internal static let handlePlaceholder = ImageAsset(name: "handle-placeholder")
  internal static let historyIconActive = ImageAsset(name: "history-icon-active")
  internal static let hondaWhiteIcon = ImageAsset(name: "honda-white-icon")
  internal static let iconCalendar = ImageAsset(name: "icon-calendar")
  internal static let iconCamera = ImageAsset(name: "icon-camera")
  internal static let iconInsurance = ImageAsset(name: "icon-insurance")
  internal static let iconSticker = ImageAsset(name: "icon-sticker")
  internal static let iconUnpaidBalanceLargeIcon = ImageAsset(name: "icon-unpaid-balance-large-icon")
  internal static let iconUnpaidBalance = ImageAsset(name: "icon-unpaid-balance")
  internal static let iconChevron = ImageAsset(name: "iconChevron")
  internal static let imageLegal = ImageAsset(name: "imageLegal")
  internal static let info = ImageAsset(name: "info")
  internal static let mapSample = ImageAsset(name: "mapSample")
  internal static let mapPlaceholder = ImageAsset(name: "map_placeholder")
  internal static let menuWheelChair = ImageAsset(name: "menuWheelChair")
  internal static let or = ImageAsset(name: "or")
  internal static let otherAmount = ImageAsset(name: "otherAmount")
  internal static let patternBGFacebook = ImageAsset(name: "patternBGFacebook")
  internal static let paymentIconActive = ImageAsset(name: "payment-icon-active")
  internal static let personPlaceholder = ImageAsset(name: "person_placeholder")
  internal static let phoneRoundUp = ImageAsset(name: "phoneRoundUp")
  internal static let photo = ImageAsset(name: "photo")
  internal static let pickUpCommentBg = ImageAsset(name: "pickUpCommentBg")
  internal static let pinLocationDividers = ImageAsset(name: "pin-location-dividers")
  internal static let pin = ImageAsset(name: "pin")
  internal static let addressHistoryIcon = ImageAsset(name: "address-history-icon")
  internal static let addressHomeIcon = ImageAsset(name: "address-home-icon")
  internal static let addressLocationOnMapIcon = ImageAsset(name: "address-location-on-map-icon")
  internal static let addressPlaceIcon = ImageAsset(name: "address-place-icon")
  internal static let addressRemoveDestinationIcon = ImageAsset(name: "address-remove-destination-icon")
  internal static let addressWorkIcon = ImageAsset(name: "address-work-icon")
  internal static let addressHomeBlack = ImageAsset(name: "addressHomeBlack")
  internal static let addressWorkBlack = ImageAsset(name: "addressWorkBlack")
  internal static let transitIcon = ImageAsset(name: "transit_icon")
  internal static let precedingTripMarkerIcon = ImageAsset(name: "preceding-trip-marker-icon")
  internal static let promoChatIcon = ImageAsset(name: "promoChatIcon")
  internal static let promoDollarIcon = ImageAsset(name: "promoDollarIcon")
  internal static let promoEmailIcon = ImageAsset(name: "promoEmailIcon")
  internal static let promoFBIcon = ImageAsset(name: "promoFBIcon")
  internal static let promoLabelIcon = ImageAsset(name: "promoLabelIcon")
  internal static let promoTwitterIcon = ImageAsset(name: "promoTwitterIcon")
  internal static let promoWhatsappIcon = ImageAsset(name: "promoWhatsappIcon")
  internal static let redPin = ImageAsset(name: "red-pin")
  internal static let redCircleFilled = ImageAsset(name: "redCircleFilled")
  internal static let settingsIconActive = ImageAsset(name: "settings-icon-active")
  internal static let setupPinRed = ImageAsset(name: "setup-pin-red")
  internal static let setupPin = ImageAsset(name: "setupPin")
  internal static let splitFareBigIcon = ImageAsset(name: "split-fare-big-icon")
  internal static let starActive = ImageAsset(name: "star-active")
  internal static let starInactive = ImageAsset(name: "star-inactive")
  internal static let star = ImageAsset(name: "star")
  internal static let successIcon = ImageAsset(name: "success-icon")
  internal static let tncUpload = ImageAsset(name: "tncUpload")
  internal static let iconFareEstimate = ImageAsset(name: "icon-fare-estimate")
  internal static let iconFareSplit = ImageAsset(name: "icon-fare-split")
  internal static let iconPromoCode = ImageAsset(name: "icon-promo-code")
  internal static let backIcon = ImageAsset(name: "back-icon")
  internal static let backArrow = ImageAsset(name: "backArrow")
  internal static let blueCircleWhiteCheck = ImageAsset(name: "blue-circle-white-check")
  internal static let currentLocation = ImageAsset(name: "current-location")
  internal static let disclosureArrow = ImageAsset(name: "disclosure-arrow")
  internal static let fingerprint = ImageAsset(name: "fingerprint")
  internal static let iconBlueCircleCar = ImageAsset(name: "iconBlueCircleCar")
  internal static let iconDestination = ImageAsset(name: "iconDestination")
  internal static let iconPickup = ImageAsset(name: "iconPickup")
  internal static let menuIcon = ImageAsset(name: "menu-icon")
  internal static let messageIcon = ImageAsset(name: "message-icon")
  internal static let whiteCancel = ImageAsset(name: "whiteCancel")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
