// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// About
  case aboutbutton
  /// Activate
  case activate
  /// dresden, parking, car, driving, navigation, park, public, parkinglot, lot
  case appstoretags
  /// Cancel
  case cancel
  /// ca. %@ spots available
  case circaspotsavailable(String)
  /// City
  case cityoptions
  /// closed
  case closed
  /// Display
  case displayoptions
  /// Unfortunately there's no data available for the selected date.
  case endofdata
  /// No data
  case endofdatatitle
  /// Forecast
  case forecast
  /// Use this function to view into the future. Pick a date and see how many spaces will presumably be available at that point in time.\n\nThe chart shows the selected day.
  case forecastinfotext
  /// Forecast Data
  case forecastinfotitle
  /// Forecast for %@
  case forecasttitle(String)
  /// Hide Lots Without Data
  case hidenodatalots
  /// Last update:
  case lastupdate
  /// Updated: %@
  case lastupdated(String)
  /// List will be updated on next refresh.
  case listupdateonrefresh
  /// Load in %%
  case loadinpercent
  /// ParkenDD is unable to get location data. Please allow it to do so in the system settings.
  case locationdataerror
  /// Location Data Error
  case locationdataerrortitle
  /// %@ of %d available
  case mapsubtitle(String, Int)
  /// Unfortunately there don't seem to be any coordinates associated with this parking lot.
  case nocoordswarning
  /// No coordinates
  case nocoordswarningtitle
  /// Note
  case notetitle
  /// Used to show location on map and for sorting parking lots by distance.
  case nsLocationWhenInUseUsageDescription
  /// occupied
  case occupied
  /// Other
  case otheroptions
  /// The data might be outdated. It was last updated more than an hour ago.
  case outdateddatawarning
  /// Outdated data
  case outdateddatawarningtitle
  /// Couldn't fetch data. You appear to be disconnected from the internet.
  case requesterror
  /// Connection Error
  case requesterrortitle
  /// Suggest a new city
  case requestnewcity
  /// Reset Notifications
  case resetnotifications
  /// Feedback / Report Problem
  case sendfeedback
  /// Couldn't read data from server. Please try again in a few moments.
  case servererror
  /// Server Error
  case servererrortitle
  /// Settings
  case settings
  /// Share on Twitter
  case shareontwitter
  /// The newly displayed cities are in an experimental state! Their data will probably be littered with errors and be incomplete. \n\nIf you're willing to join us in our effort of supporting new cities, please tap the feedback button below :)
  case showexperimentalcitiesalert
  /// Show Experimental Cities
  case showexperimentalcitiessetting
  /// Sort by
  case sortingoptions
  /// Alphabetical
  case sortingtypealphabetical
  /// Default
  case sortingtypedefault
  /// Best first
  case sortingtypeeuklid
  /// Free Spots
  case sortingtypefreespots
  /// Distance
  case sortingtypelocation
  /// No free parking space in sight? → #ParkenDD http://parkendd.de
  case tweettext
  /// unknown address
  case unknownaddress
  /// Couldn't find coordinates for selected parking lot. 
  case unknowncoordinateserror
  /// Error
  case unknowncoordinatestitle
  /// An unknown error has occurred.
  case unknownerror
  /// Unknown error
  case unknownerrortitle
  /// no data available
  case unknownload
  /// Use Grayscale Colorscheme
  case usegrayscalecolors
  /// waiting for location
  case waitingforlocation
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .aboutbutton:
        return L10n.tr(key: "ABOUT_BUTTON")
      case .activate:
        return L10n.tr(key: "ACTIVATE")
      case .appstoretags:
        return L10n.tr(key: "APPSTORE_TAGS")
      case .cancel:
        return L10n.tr(key: "CANCEL")
      case .circaspotsavailable(let p0):
        return L10n.tr(key: "CIRCA_SPOTS_AVAILABLE", p0)
      case .cityoptions:
        return L10n.tr(key: "CITY_OPTIONS")
      case .closed:
        return L10n.tr(key: "CLOSED")
      case .displayoptions:
        return L10n.tr(key: "DISPLAY_OPTIONS")
      case .endofdata:
        return L10n.tr(key: "END_OF_DATA")
      case .endofdatatitle:
        return L10n.tr(key: "END_OF_DATA_TITLE")
      case .forecast:
        return L10n.tr(key: "FORECAST")
      case .forecastinfotext:
        return L10n.tr(key: "FORECAST_INFO_TEXT")
      case .forecastinfotitle:
        return L10n.tr(key: "FORECAST_INFO_TITLE")
      case .forecasttitle(let p0):
        return L10n.tr(key: "FORECAST_TITLE", p0)
      case .hidenodatalots:
        return L10n.tr(key: "HIDE_NODATA_LOTS")
      case .lastupdate:
        return L10n.tr(key: "LAST_UPDATE")
      case .lastupdated(let p0):
        return L10n.tr(key: "LAST_UPDATED", p0)
      case .listupdateonrefresh:
        return L10n.tr(key: "LIST_UPDATE_ON_REFRESH")
      case .loadinpercent:
        return L10n.tr(key: "LOAD_IN_PERCENT")
      case .locationdataerror:
        return L10n.tr(key: "LOCATION_DATA_ERROR")
      case .locationdataerrortitle:
        return L10n.tr(key: "LOCATION_DATA_ERROR_TITLE")
      case .mapsubtitle(let p0, let p1):
        return L10n.tr(key: "MAPSUBTITLE", p0, p1)
      case .nocoordswarning:
        return L10n.tr(key: "NO_COORDS_WARNING")
      case .nocoordswarningtitle:
        return L10n.tr(key: "NO_COORDS_WARNING_TITLE")
      case .notetitle:
        return L10n.tr(key: "NOTE_TITLE")
      case .nsLocationWhenInUseUsageDescription:
        return L10n.tr(key: "NSLocationWhenInUseUsageDescription")
      case .occupied:
        return L10n.tr(key: "OCCUPIED")
      case .otheroptions:
        return L10n.tr(key: "OTHER_OPTIONS")
      case .outdateddatawarning:
        return L10n.tr(key: "OUTDATED_DATA_WARNING")
      case .outdateddatawarningtitle:
        return L10n.tr(key: "OUTDATED_DATA_WARNING_TITLE")
      case .requesterror:
        return L10n.tr(key: "REQUEST_ERROR")
      case .requesterrortitle:
        return L10n.tr(key: "REQUEST_ERROR_TITLE")
      case .requestnewcity:
        return L10n.tr(key: "REQUEST_NEW_CITY")
      case .resetnotifications:
        return L10n.tr(key: "RESET_NOTIFICATIONS")
      case .sendfeedback:
        return L10n.tr(key: "SEND_FEEDBACK")
      case .servererror:
        return L10n.tr(key: "SERVER_ERROR")
      case .servererrortitle:
        return L10n.tr(key: "SERVER_ERROR_TITLE")
      case .settings:
        return L10n.tr(key: "SETTINGS")
      case .shareontwitter:
        return L10n.tr(key: "SHARE_ON_TWITTER")
      case .showexperimentalcitiesalert:
        return L10n.tr(key: "SHOWEXPERIMENTALCITIESALERT")
      case .showexperimentalcitiessetting:
        return L10n.tr(key: "SHOWEXPERIMENTALCITIESSETTING")
      case .sortingoptions:
        return L10n.tr(key: "SORTING_OPTIONS")
      case .sortingtypealphabetical:
        return L10n.tr(key: "SORTINGTYPE_ALPHABETICAL")
      case .sortingtypedefault:
        return L10n.tr(key: "SORTINGTYPE_DEFAULT")
      case .sortingtypeeuklid:
        return L10n.tr(key: "SORTINGTYPE_EUKLID")
      case .sortingtypefreespots:
        return L10n.tr(key: "SORTINGTYPE_FREESPOTS")
      case .sortingtypelocation:
        return L10n.tr(key: "SORTINGTYPE_LOCATION")
      case .tweettext:
        return L10n.tr(key: "TWEET_TEXT")
      case .unknownaddress:
        return L10n.tr(key: "UNKNOWN_ADDRESS")
      case .unknowncoordinateserror:
        return L10n.tr(key: "UNKNOWN_COORDINATES_ERROR")
      case .unknowncoordinatestitle:
        return L10n.tr(key: "UNKNOWN_COORDINATES_TITLE")
      case .unknownerror:
        return L10n.tr(key: "UNKNOWN_ERROR")
      case .unknownerrortitle:
        return L10n.tr(key: "UNKNOWN_ERROR_TITLE")
      case .unknownload:
        return L10n.tr(key: "UNKNOWN_LOAD")
      case .usegrayscalecolors:
        return L10n.tr(key: "USE_GRAYSCALE_COLORS")
      case .waitingforlocation:
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
