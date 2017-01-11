// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// About
  case aboutButton
  /// Activate
  case activate
  /// dresden, parking, car, driving, navigation, park, public, parkinglot, lot
  case appstoreTags
  /// Cancel
  case cancel
  /// ca. %@ spots available
  case circaSpotsAvailable(String)
  /// City
  case cityOptions
  /// closed
  case closed
  /// Display
  case displayOptions
  /// Unfortunately there's no data available for the selected date.
  case endOfData
  /// No data
  case endOfDataTitle
  /// Forecast
  case forecast
  /// Use this function to view into the future. Pick a date and see how many spaces will presumably be available at that point in time.\n\nThe chart shows the selected day.
  case forecastInfoText
  /// Forecast Data
  case forecastInfoTitle
  /// Forecast for %@
  case forecastTitle(String)
  /// Hide Lots Without Data
  case hideNodataLots
  /// Last update:
  case lastUpdate
  /// Updated: %@
  case lastUpdated(String)
  /// List will be updated on next refresh.
  case listUpdateOnRefresh
  /// Load in %%
  case loadInPercent
  /// ParkenDD is unable to get location data. Please allow it to do so in the system settings.
  case locationDataError
  /// Location Data Error
  case locationDataErrorTitle
  /// %@ of %d available
  case mapsubtitle(String, Int)
  /// Unfortunately there don't seem to be any coordinates associated with this parking lot.
  case noCoordsWarning
  /// No coordinates
  case noCoordsWarningTitle
  /// Note
  case noteTitle
  /// Used to show location on map and for sorting parking lots by distance.
  case nsLocationWhenInUseUsageDescription
  /// occupied
  case occupied
  /// Other
  case otherOptions
  /// The data might be outdated. It was last updated more than an hour ago.
  case outdatedDataWarning
  /// Outdated data
  case outdatedDataWarningTitle
  /// Couldn't fetch data. You appear to be disconnected from the internet.
  case requestError
  /// Connection Error
  case requestErrorTitle
  /// Suggest a new city
  case requestNewCity
  /// Reset Notifications
  case resetNotifications
  /// Feedback / Report Problem
  case sendFeedback
  /// Couldn't read data from server. Please try again in a few moments.
  case serverError
  /// Server Error
  case serverErrorTitle
  /// Settings
  case settings
  /// Share on Twitter
  case shareOnTwitter
  /// The newly displayed cities are in an experimental state! Their data will probably be littered with errors and be incomplete. \n\nIf you're willing to join us in our effort of supporting new cities, please tap the feedback button below :)
  case showexperimentalcitiesalert
  /// Show Experimental Cities
  case showexperimentalcitiessetting
  /// Sort by
  case sortingOptions
  /// Alphabetical
  case sortingtypeAlphabetical
  /// Default
  case sortingtypeDefault
  /// Best first
  case sortingtypeEuklid
  /// Free Spots
  case sortingtypeFreespots
  /// Distance
  case sortingtypeLocation
  /// No free parking space in sight? → #ParkenDD http://parkendd.de
  case tweetText
  /// unknown address
  case unknownAddress
  /// Couldn't find coordinates for selected parking lot. 
  case unknownCoordinatesError
  /// Error
  case unknownCoordinatesTitle
  /// An unknown error has occurred.
  case unknownError
  /// Unknown error
  case unknownErrorTitle
  /// no data available
  case unknownLoad
  /// Use Grayscale Colorscheme
  case useGrayscaleColors
  /// waiting for location
  case waitingForLocation
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .aboutButton:
        return L10n.tr(key: "ABOUT_BUTTON")
      case .activate:
        return L10n.tr(key: "ACTIVATE")
      case .appstoreTags:
        return L10n.tr(key: "APPSTORE_TAGS")
      case .cancel:
        return L10n.tr(key: "CANCEL")
      case .circaSpotsAvailable(let p0):
        return L10n.tr(key: "CIRCA_SPOTS_AVAILABLE", p0)
      case .cityOptions:
        return L10n.tr(key: "CITY_OPTIONS")
      case .closed:
        return L10n.tr(key: "CLOSED")
      case .displayOptions:
        return L10n.tr(key: "DISPLAY_OPTIONS")
      case .endOfData:
        return L10n.tr(key: "END_OF_DATA")
      case .endOfDataTitle:
        return L10n.tr(key: "END_OF_DATA_TITLE")
      case .forecast:
        return L10n.tr(key: "FORECAST")
      case .forecastInfoText:
        return L10n.tr(key: "FORECAST_INFO_TEXT")
      case .forecastInfoTitle:
        return L10n.tr(key: "FORECAST_INFO_TITLE")
      case .forecastTitle(let p0):
        return L10n.tr(key: "FORECAST_TITLE", p0)
      case .hideNodataLots:
        return L10n.tr(key: "HIDE_NODATA_LOTS")
      case .lastUpdate:
        return L10n.tr(key: "LAST_UPDATE")
      case .lastUpdated(let p0):
        return L10n.tr(key: "LAST_UPDATED", p0)
      case .listUpdateOnRefresh:
        return L10n.tr(key: "LIST_UPDATE_ON_REFRESH")
      case .loadInPercent:
        return L10n.tr(key: "LOAD_IN_PERCENT")
      case .locationDataError:
        return L10n.tr(key: "LOCATION_DATA_ERROR")
      case .locationDataErrorTitle:
        return L10n.tr(key: "LOCATION_DATA_ERROR_TITLE")
      case .mapsubtitle(let p0, let p1):
        return L10n.tr(key: "MAPSUBTITLE", p0, p1)
      case .noCoordsWarning:
        return L10n.tr(key: "NO_COORDS_WARNING")
      case .noCoordsWarningTitle:
        return L10n.tr(key: "NO_COORDS_WARNING_TITLE")
      case .noteTitle:
        return L10n.tr(key: "NOTE_TITLE")
      case .nsLocationWhenInUseUsageDescription:
        return L10n.tr(key: "NSLocationWhenInUseUsageDescription")
      case .occupied:
        return L10n.tr(key: "OCCUPIED")
      case .otherOptions:
        return L10n.tr(key: "OTHER_OPTIONS")
      case .outdatedDataWarning:
        return L10n.tr(key: "OUTDATED_DATA_WARNING")
      case .outdatedDataWarningTitle:
        return L10n.tr(key: "OUTDATED_DATA_WARNING_TITLE")
      case .requestError:
        return L10n.tr(key: "REQUEST_ERROR")
      case .requestErrorTitle:
        return L10n.tr(key: "REQUEST_ERROR_TITLE")
      case .requestNewCity:
        return L10n.tr(key: "REQUEST_NEW_CITY")
      case .resetNotifications:
        return L10n.tr(key: "RESET_NOTIFICATIONS")
      case .sendFeedback:
        return L10n.tr(key: "SEND_FEEDBACK")
      case .serverError:
        return L10n.tr(key: "SERVER_ERROR")
      case .serverErrorTitle:
        return L10n.tr(key: "SERVER_ERROR_TITLE")
      case .settings:
        return L10n.tr(key: "SETTINGS")
      case .shareOnTwitter:
        return L10n.tr(key: "SHARE_ON_TWITTER")
      case .showexperimentalcitiesalert:
        return L10n.tr(key: "SHOWEXPERIMENTALCITIESALERT")
      case .showexperimentalcitiessetting:
        return L10n.tr(key: "SHOWEXPERIMENTALCITIESSETTING")
      case .sortingOptions:
        return L10n.tr(key: "SORTING_OPTIONS")
      case .sortingtypeAlphabetical:
        return L10n.tr(key: "SORTINGTYPE_ALPHABETICAL")
      case .sortingtypeDefault:
        return L10n.tr(key: "SORTINGTYPE_DEFAULT")
      case .sortingtypeEuklid:
        return L10n.tr(key: "SORTINGTYPE_EUKLID")
      case .sortingtypeFreespots:
        return L10n.tr(key: "SORTINGTYPE_FREESPOTS")
      case .sortingtypeLocation:
        return L10n.tr(key: "SORTINGTYPE_LOCATION")
      case .tweetText:
        return L10n.tr(key: "TWEET_TEXT")
      case .unknownAddress:
        return L10n.tr(key: "UNKNOWN_ADDRESS")
      case .unknownCoordinatesError:
        return L10n.tr(key: "UNKNOWN_COORDINATES_ERROR")
      case .unknownCoordinatesTitle:
        return L10n.tr(key: "UNKNOWN_COORDINATES_TITLE")
      case .unknownError:
        return L10n.tr(key: "UNKNOWN_ERROR")
      case .unknownErrorTitle:
        return L10n.tr(key: "UNKNOWN_ERROR_TITLE")
      case .unknownLoad:
        return L10n.tr(key: "UNKNOWN_LOAD")
      case .useGrayscaleColors:
        return L10n.tr(key: "USE_GRAYSCALE_COLORS")
      case .waitingForLocation:
        return L10n.tr(key: "WAITING_FOR_LOCATION")
    }
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

func tr(_ key: L10n) -> String {
  return key.string
}
