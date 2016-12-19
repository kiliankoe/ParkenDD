// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// About
  case ABOUTBUTTON
  /// Activate
  case ACTIVATE
  /// ParkenDD shows you a list of the number of available public parking spots in Dresden, Germany. It shows you whether a public parking lot is open or not, how many spots are available and where it is on a map.\n\nThe information displayed is up-to-date according to what is published officially on dresden.de/freie-parkplaetze.\n\nThe source for this application is available on Github. See https://github.com/kiliankoe/parkendd
  case APPSTOREDESCRIPTION
  /// dresden, parking, car, driving, navigation, park, public, parkinglot, lot
  case APPSTORETAGS
  /// Cancel
  case CANCEL
  /// ca. %@ spots available
  case CIRCASPOTSAVAILABLE(String)
  /// City
  case CITYOPTIONS
  /// closed
  case CLOSED
  /// Display
  case DISPLAYOPTIONS
  /// Unfortunately there's no data available for the selected date.
  case ENDOFDATA
  /// No data
  case ENDOFDATATITLE
  /// Forecast
  case FORECAST
  /// Use this function to view into the future. Pick a date and see how many spaces will presumably be available at that point in time.\n\nThe chart shows the selected day.
  case FORECASTINFOTEXT
  /// Forecast Data
  case FORECASTINFOTITLE
  /// Forecast for %@
  case FORECASTTITLE(String)
  /// Hide Lots Without Data
  case HIDENODATALOTS
  /// Last update:
  case LASTUPDATE
  /// Updated: %@
  case LASTUPDATED(String)
  /// List will be updated on next refresh.
  case LISTUPDATEONREFRESH
  /// Load in %%
  case LOADINPERCENT
  /// ParkenDD is unable to get location data. Please allow it to do so in the system settings.
  case LOCATIONDATAERROR
  /// Location Data Error
  case LOCATIONDATAERRORTITLE
  /// %@ of %d available
  case MAPSUBTITLE(String, Int)
  /// Unfortunately there don't seem to be any coordinates associated with this parking lot.
  case NOCOORDSWARNING
  /// No coordinates
  case NOCOORDSWARNINGTITLE
  /// Note
  case NOTETITLE
  /// Used to show location on map and for sorting parking lots by distance.
  case NSLocationWhenInUseUsageDescription
  /// occupied
  case OCCUPIED
  /// Other
  case OTHEROPTIONS
  /// The data might be outdated. It was last updated more than an hour ago.
  case OUTDATEDDATAWARNING
  /// Outdated data
  case OUTDATEDDATAWARNINGTITLE
  /// Couldn't fetch data. You appear to be disconnected from the internet.
  case REQUESTERROR
  /// Connection Error
  case REQUESTERRORTITLE
  /// Suggest a new city
  case REQUESTNEWCITY
  /// Reset Notifications
  case RESETNOTIFICATIONS
  /// Feedback / Report Problem
  case SENDFEEDBACK
  /// Couldn't read data from server. Please try again in a few moments.
  case SERVERERROR
  /// Server Error
  case SERVERERRORTITLE
  /// Settings
  case SETTINGS
  /// Share on Twitter
  case SHAREONTWITTER
  /// The newly displayed cities are in an experimental state! Their data will probably be littered with errors and be incomplete. \n\nIf you're willing to join us in our effort of supporting new cities, please tap the feedback button below :)
  case SHOWEXPERIMENTALCITIESALERT
  /// Show Experimental Cities
  case SHOWEXPERIMENTALCITIESSETTING
  /// Sort by
  case SORTINGOPTIONS
  /// Alphabetical
  case SORTINGTYPEALPHABETICAL
  /// Default
  case SORTINGTYPEDEFAULT
  /// Best first
  case SORTINGTYPEEUKLID
  /// Free Spots
  case SORTINGTYPEFREESPOTS
  /// Distance
  case SORTINGTYPELOCATION
  /// No free parking space in sight? -> #ParkenDD http://parkendd.de
  case TWEETTEXT
  /// unknown address
  case UNKNOWNADDRESS
  /// Couldn't find coordinates for selected parking lot. 
  case UNKNOWNCOORDINATESERROR
  /// Error
  case UNKNOWNCOORDINATESTITLE
  /// An unknown error has occurred.
  case UNKNOWNERROR
  /// Unknown error
  case UNKNOWNERRORTITLE
  /// no data available
  case UNKNOWNLOAD
  /// Use Grayscale Colorscheme
  case USEGRAYSCALECOLORS
  /// waiting for location
  case WAITINGFORLOCATION
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .ABOUTBUTTON:
        return L10n.tr("ABOUT_BUTTON")
      case .ACTIVATE:
        return L10n.tr("ACTIVATE")
      case .APPSTOREDESCRIPTION:
        return L10n.tr("APPSTORE_DESCRIPTION")
      case .APPSTORETAGS:
        return L10n.tr("APPSTORE_TAGS")
      case .CANCEL:
        return L10n.tr("CANCEL")
      case .CIRCASPOTSAVAILABLE(let p0):
        return L10n.tr("CIRCA_SPOTS_AVAILABLE", p0)
      case .CITYOPTIONS:
        return L10n.tr("CITY_OPTIONS")
      case .CLOSED:
        return L10n.tr("CLOSED")
      case .DISPLAYOPTIONS:
        return L10n.tr("DISPLAY_OPTIONS")
      case .ENDOFDATA:
        return L10n.tr("END_OF_DATA")
      case .ENDOFDATATITLE:
        return L10n.tr("END_OF_DATA_TITLE")
      case .FORECAST:
        return L10n.tr("FORECAST")
      case .FORECASTINFOTEXT:
        return L10n.tr("FORECAST_INFO_TEXT")
      case .FORECASTINFOTITLE:
        return L10n.tr("FORECAST_INFO_TITLE")
      case .FORECASTTITLE(let p0):
        return L10n.tr("FORECAST_TITLE", p0)
      case .HIDENODATALOTS:
        return L10n.tr("HIDE_NODATA_LOTS")
      case .LASTUPDATE:
        return L10n.tr("LAST_UPDATE")
      case .LASTUPDATED(let p0):
        return L10n.tr("LAST_UPDATED", p0)
      case .LISTUPDATEONREFRESH:
        return L10n.tr("LIST_UPDATE_ON_REFRESH")
      case .LOADINPERCENT:
        return L10n.tr("LOAD_IN_PERCENT")
      case .LOCATIONDATAERROR:
        return L10n.tr("LOCATION_DATA_ERROR")
      case .LOCATIONDATAERRORTITLE:
        return L10n.tr("LOCATION_DATA_ERROR_TITLE")
      case .MAPSUBTITLE(let p0, let p1):
        return L10n.tr("MAPSUBTITLE", p0, p1)
      case .NOCOORDSWARNING:
        return L10n.tr("NO_COORDS_WARNING")
      case .NOCOORDSWARNINGTITLE:
        return L10n.tr("NO_COORDS_WARNING_TITLE")
      case .NOTETITLE:
        return L10n.tr("NOTE_TITLE")
      case .NSLocationWhenInUseUsageDescription:
        return L10n.tr("NSLocationWhenInUseUsageDescription")
      case .OCCUPIED:
        return L10n.tr("OCCUPIED")
      case .OTHEROPTIONS:
        return L10n.tr("OTHER_OPTIONS")
      case .OUTDATEDDATAWARNING:
        return L10n.tr("OUTDATED_DATA_WARNING")
      case .OUTDATEDDATAWARNINGTITLE:
        return L10n.tr("OUTDATED_DATA_WARNING_TITLE")
      case .REQUESTERROR:
        return L10n.tr("REQUEST_ERROR")
      case .REQUESTERRORTITLE:
        return L10n.tr("REQUEST_ERROR_TITLE")
      case .REQUESTNEWCITY:
        return L10n.tr("REQUEST_NEW_CITY")
      case .RESETNOTIFICATIONS:
        return L10n.tr("RESET_NOTIFICATIONS")
      case .SENDFEEDBACK:
        return L10n.tr("SEND_FEEDBACK")
      case .SERVERERROR:
        return L10n.tr("SERVER_ERROR")
      case .SERVERERRORTITLE:
        return L10n.tr("SERVER_ERROR_TITLE")
      case .SETTINGS:
        return L10n.tr("SETTINGS")
      case .SHAREONTWITTER:
        return L10n.tr("SHARE_ON_TWITTER")
      case .SHOWEXPERIMENTALCITIESALERT:
        return L10n.tr("SHOWEXPERIMENTALCITIESALERT")
      case .SHOWEXPERIMENTALCITIESSETTING:
        return L10n.tr("SHOWEXPERIMENTALCITIESSETTING")
      case .SORTINGOPTIONS:
        return L10n.tr("SORTING_OPTIONS")
      case .SORTINGTYPEALPHABETICAL:
        return L10n.tr("SORTINGTYPE_ALPHABETICAL")
      case .SORTINGTYPEDEFAULT:
        return L10n.tr("SORTINGTYPE_DEFAULT")
      case .SORTINGTYPEEUKLID:
        return L10n.tr("SORTINGTYPE_EUKLID")
      case .SORTINGTYPEFREESPOTS:
        return L10n.tr("SORTINGTYPE_FREESPOTS")
      case .SORTINGTYPELOCATION:
        return L10n.tr("SORTINGTYPE_LOCATION")
      case .TWEETTEXT:
        return L10n.tr("TWEET_TEXT")
      case .UNKNOWNADDRESS:
        return L10n.tr("UNKNOWN_ADDRESS")
      case .UNKNOWNCOORDINATESERROR:
        return L10n.tr("UNKNOWN_COORDINATES_ERROR")
      case .UNKNOWNCOORDINATESTITLE:
        return L10n.tr("UNKNOWN_COORDINATES_TITLE")
      case .UNKNOWNERROR:
        return L10n.tr("UNKNOWN_ERROR")
      case .UNKNOWNERRORTITLE:
        return L10n.tr("UNKNOWN_ERROR_TITLE")
      case .UNKNOWNLOAD:
        return L10n.tr("UNKNOWN_LOAD")
      case .USEGRAYSCALECOLORS:
        return L10n.tr("USE_GRAYSCALE_COLORS")
      case .WAITINGFORLOCATION:
        return L10n.tr("WAITING_FOR_LOCATION")
    }
  }

  private static func tr(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, locale: NSLocale.current, arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}
