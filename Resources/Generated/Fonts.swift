// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
  internal typealias Font = NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
  internal typealias Font = UIFont
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum Montserrat {
    internal static let black = FontConvertible(name: "Montserrat-Black", family: "Montserrat", path: "Montserrat-Black.otf")
    internal static let bold = FontConvertible(name: "Montserrat-Bold", family: "Montserrat", path: "Montserrat-Bold.otf")
    internal static let extraBold = FontConvertible(name: "Montserrat-ExtraBold", family: "Montserrat", path: "Montserrat-ExtraBold.otf")
    internal static let hairline = FontConvertible(name: "Montserrat-Hairline", family: "Montserrat", path: "Montserrat-Hairline.otf")
    internal static let light = FontConvertible(name: "Montserrat-Light", family: "Montserrat", path: "Montserrat-Light.otf")
    internal static let lightItalic = FontConvertible(name: "Montserrat-LightItalic", family: "Montserrat", path: "Montserrat-LightItalic.otf")
    internal static let regular = FontConvertible(name: "Montserrat-Regular", family: "Montserrat", path: "Montserrat-Regular.otf")
    internal static let semiBold = FontConvertible(name: "Montserrat-SemiBold", family: "Montserrat", path: "Montserrat-SemiBold.otf")
    internal static let ultraLight = FontConvertible(name: "Montserrat-UltraLight", family: "Montserrat", path: "Montserrat-UltraLight.otf")
    internal static let all: [FontConvertible] = [black, bold, extraBold, hairline, light, lightItalic, regular, semiBold, ultraLight]
  }
  internal enum Poppins {
    internal static let black = FontConvertible(name: "Poppins-Black", family: "Poppins", path: "Poppins-Black.ttf")
    internal static let blackItalic = FontConvertible(name: "Poppins-BlackItalic", family: "Poppins", path: "Poppins-BlackItalic.ttf")
    internal static let bold = FontConvertible(name: "Poppins-Bold", family: "Poppins", path: "Poppins-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Poppins-BoldItalic", family: "Poppins", path: "Poppins-BoldItalic.ttf")
    internal static let extraBold = FontConvertible(name: "Poppins-ExtraBold", family: "Poppins", path: "Poppins-ExtraBold.ttf")
    internal static let extraBoldItalic = FontConvertible(name: "Poppins-ExtraBoldItalic", family: "Poppins", path: "Poppins-ExtraBoldItalic.ttf")
    internal static let extraLight = FontConvertible(name: "Poppins-ExtraLight", family: "Poppins", path: "Poppins-ExtraLight.ttf")
    internal static let extraLightItalic = FontConvertible(name: "Poppins-ExtraLightItalic", family: "Poppins", path: "Poppins-ExtraLightItalic.ttf")
    internal static let italic = FontConvertible(name: "Poppins-Italic", family: "Poppins", path: "Poppins-Italic.ttf")
    internal static let light = FontConvertible(name: "Poppins-Light", family: "Poppins", path: "Poppins-Light.ttf")
    internal static let lightItalic = FontConvertible(name: "Poppins-LightItalic", family: "Poppins", path: "Poppins-LightItalic.ttf")
    internal static let medium = FontConvertible(name: "Poppins-Medium", family: "Poppins", path: "Poppins-Medium.ttf")
    internal static let mediumItalic = FontConvertible(name: "Poppins-MediumItalic", family: "Poppins", path: "Poppins-MediumItalic.ttf")
    internal static let regular = FontConvertible(name: "Poppins-Regular", family: "Poppins", path: "Poppins-Regular.ttf")
    internal static let semiBold = FontConvertible(name: "Poppins-SemiBold", family: "Poppins", path: "Poppins-SemiBold.ttf")
    internal static let semiBoldItalic = FontConvertible(name: "Poppins-SemiBoldItalic", family: "Poppins", path: "Poppins-SemiBoldItalic.ttf")
    internal static let thin = FontConvertible(name: "Poppins-Thin", family: "Poppins", path: "Poppins-Thin.ttf")
    internal static let thinItalic = FontConvertible(name: "Poppins-ThinItalic", family: "Poppins", path: "Poppins-ThinItalic.ttf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, medium, mediumItalic, regular, semiBold, semiBoldItalic, thin, thinItalic]
  }
  internal static let allCustomFonts: [FontConvertible] = [Montserrat.all, Poppins.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  internal func font(size: CGFloat) -> Font! {
    return Font(font: self, size: size)
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    let bundle = Bundle(for: BundleToken.self)
    return bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension Font {
  convenience init!(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

private final class BundleToken {}
