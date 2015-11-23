// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
  /// Connection Error
  case REQUESTERRORTITLE
  /// Couldn't fetch data. You appear to be disconnected from the internet.
  case REQUESTERROR
  /// Server Error
  case SERVERERRORTITLE
  /// Couldn't read data from server. Please try again in a few moments.
  case SERVERERROR
  /// Error
  case UNKNOWNCOORDINATESTITLE
  /// Couldn't find coordinates for selected parking lot. 
  case UNKNOWNCOORDINATESERROR
  /// Last update:
  case LASTUPDATE
  /// occupied
  case OCCUPIED
  /// closed
  case CLOSED
  /// unknown address
  case UNKNOWNADDRESS
  /// no data available
  case UNKNOWNLOAD
  /// Other
  case OTHEROPTIONS
  /// Distance
  case SORTINGTYPELOCATION
  /// Share on Twitter
  case SHAREONTWITTER
  /// Free Spots
  case SORTINGTYPEFREESPOTS
  /// Sort by
  case SORTINGOPTIONS
  /// Alphabetical
  case SORTINGTYPEALPHABETICAL
  /// About
  case ABOUTBUTTON
  /// Default
  case SORTINGTYPEDEFAULT
  /// Used to show location on map and for sorting parking lots by distance.
  case NSLocationWhenInUseUsageDescription
  /// No free parking space in sight? -> #ParkenDD http://parkendd.de
  case TWEETTEXT
  /// waiting for location
  case WAITINGFORLOCATION
  /// ParkenDD shows you a list of the number of available public parking spots in Dresden, Germany. It shows you whether a public parking lot is open or not, how many spots are available and where it is on a map.\n\nThe information displayed is up-to-date according to what is published officially on dresden.de/freie-parkplaetze.\n\nThe source for this application is available on Github. See https://github.com/kiliankoe/parkendd
  case APPSTOREDESCRIPTION
  /// dresden, parking, car, driving, navigation, park, public, parkinglot, lot
  case APPSTORETAGS
  /// Location Data Error
  case LOCATIONDATAERRORTITLE
  /// ParkenDD is unable to get location data. Please allow it to do so in the system settings.
  case LOCATIONDATAERROR
  /// Cancel
  case CANCEL
  /// Settings
  case SETTINGS
  /// ca. %@ spots available
  case CIRCASPOTSAVAILABLE(String)
  /// Display
  case DISPLAYOPTIONS
  /// Hide Lots Without Data
  case HIDENODATALOTS
  /// Note
  case NOTETITLE
  /// List will be updated on next refresh.
  case LISTUPDATEONREFRESH
  /// Use Grayscale Colorscheme
  case USEGRAYSCALECOLORS
  /// Reset Notifications
  case RESETNOTIFICATIONS
  /// Feedback / Report Problem
  case SENDFEEDBACK
  /// Outdated data
  case OUTDATEDDATAWARNINGTITLE
  /// The data might be outdated. It was last updated more than an hour ago.
  case OUTDATEDDATAWARNING
  /// Unknown error
  case UNKNOWNERRORTITLE
  /// An unknown error has occurred.
  case UNKNOWNERROR
  /// Updated: %@
  case LASTUPDATED(String)
  /// No coordinates
  case NOCOORDSWARNINGTITLE
  /// Unfortunately there don't seem to be any coordinates associated with this parking lot.
  case NOCOORDSWARNING
  /// City
  case CITYOPTIONS
  /// Forecast Data
  case FORECASTINFOTITLE
  /// Use this function to view into the future. Pick a date and see how many spaces will presumably be available at that point in time.\n\nThe chart shows the selected day.
  case FORECASTINFOTEXT
  /// %@ of %d available
  case MAPSUBTITLE(String, Int)
  /// The newly displayed cities are in an experimental state! Their data will probably be littered with errors and be incomplete. \n\nIf you're willing to join us in our effort of supporting new cities, please tap the feedback button below :)
  case SHOWEXPERIMENTALCITIESALERT
  /// Activate
  case ACTIVATE
  /// Show Experimental Cities
  case SHOWEXPERIMENTALCITIESSETTING
  /// Forecast for %@
  case FORECASTTITLE(String)
  /// No data
  case ENDOFDATATITLE
  /// Unfortunately there's no data available for the selected date.
  case ENDOFDATA
  /// Best first
  case SORTINGTYPEEUKLID
  /// Forecast
  case FORECAST
  /// Load in %%
  case LOADINPERCENT
}

extension L10n : CustomStringConvertible {
  var description : String { return self.string }

  var string : String {
    switch self {
      case .REQUESTERRORTITLE:
        return L10n.tr("REQUEST_ERROR_TITLE")
      case .REQUESTERROR:
        return L10n.tr("REQUEST_ERROR")
      case .SERVERERRORTITLE:
        return L10n.tr("SERVER_ERROR_TITLE")
      case .SERVERERROR:
        return L10n.tr("SERVER_ERROR")
      case .UNKNOWNCOORDINATESTITLE:
        return L10n.tr("UNKNOWN_COORDINATES_TITLE")
      case .UNKNOWNCOORDINATESERROR:
        return L10n.tr("UNKNOWN_COORDINATES_ERROR")
      case .LASTUPDATE:
        return L10n.tr("LAST_UPDATE")
      case .OCCUPIED:
        return L10n.tr("OCCUPIED")
      case .CLOSED:
        return L10n.tr("CLOSED")
      case .UNKNOWNADDRESS:
        return L10n.tr("UNKNOWN_ADDRESS")
      case .UNKNOWNLOAD:
        return L10n.tr("UNKNOWN_LOAD")
      case .OTHEROPTIONS:
        return L10n.tr("OTHER_OPTIONS")
      case .SORTINGTYPELOCATION:
        return L10n.tr("SORTINGTYPE_LOCATION")
      case .SHAREONTWITTER:
        return L10n.tr("SHARE_ON_TWITTER")
      case .SORTINGTYPEFREESPOTS:
        return L10n.tr("SORTINGTYPE_FREESPOTS")
      case .SORTINGOPTIONS:
        return L10n.tr("SORTING_OPTIONS")
      case .SORTINGTYPEALPHABETICAL:
        return L10n.tr("SORTINGTYPE_ALPHABETICAL")
      case .ABOUTBUTTON:
        return L10n.tr("ABOUT_BUTTON")
      case .SORTINGTYPEDEFAULT:
        return L10n.tr("SORTINGTYPE_DEFAULT")
      case .NSLocationWhenInUseUsageDescription:
        return L10n.tr("NSLocationWhenInUseUsageDescription")
      case .TWEETTEXT:
        return L10n.tr("TWEET_TEXT")
      case .WAITINGFORLOCATION:
        return L10n.tr("WAITING_FOR_LOCATION")
      case .APPSTOREDESCRIPTION:
        return L10n.tr("APPSTORE_DESCRIPTION")
      case .APPSTORETAGS:
        return L10n.tr("APPSTORE_TAGS")
      case .LOCATIONDATAERRORTITLE:
        return L10n.tr("LOCATION_DATA_ERROR_TITLE")
      case .LOCATIONDATAERROR:
        return L10n.tr("LOCATION_DATA_ERROR")
      case .CANCEL:
        return L10n.tr("CANCEL")
      case .SETTINGS:
        return L10n.tr("SETTINGS")
      case .CIRCASPOTSAVAILABLE(let p0):
        return L10n.tr("CIRCA_SPOTS_AVAILABLE", p0)
      case .DISPLAYOPTIONS:
        return L10n.tr("DISPLAY_OPTIONS")
      case .HIDENODATALOTS:
        return L10n.tr("HIDE_NODATA_LOTS")
      case .NOTETITLE:
        return L10n.tr("NOTE_TITLE")
      case .LISTUPDATEONREFRESH:
        return L10n.tr("LIST_UPDATE_ON_REFRESH")
      case .USEGRAYSCALECOLORS:
        return L10n.tr("USE_GRAYSCALE_COLORS")
      case .RESETNOTIFICATIONS:
        return L10n.tr("RESET_NOTIFICATIONS")
      case .SENDFEEDBACK:
        return L10n.tr("SEND_FEEDBACK")
      case .OUTDATEDDATAWARNINGTITLE:
        return L10n.tr("OUTDATED_DATA_WARNING_TITLE")
      case .OUTDATEDDATAWARNING:
        return L10n.tr("OUTDATED_DATA_WARNING")
      case .UNKNOWNERRORTITLE:
        return L10n.tr("UNKNOWN_ERROR_TITLE")
      case .UNKNOWNERROR:
        return L10n.tr("UNKNOWN_ERROR")
      case .LASTUPDATED(let p0):
        return L10n.tr("LAST_UPDATED", p0)
      case .NOCOORDSWARNINGTITLE:
        return L10n.tr("NO_COORDS_WARNING_TITLE")
      case .NOCOORDSWARNING:
        return L10n.tr("NO_COORDS_WARNING")
      case .CITYOPTIONS:
        return L10n.tr("CITY_OPTIONS")
      case .FORECASTINFOTITLE:
        return L10n.tr("FORECAST_INFO_TITLE")
      case .FORECASTINFOTEXT:
        return L10n.tr("FORECAST_INFO_TEXT")
      case .MAPSUBTITLE(let p0, let p1):
        return L10n.tr("MAPSUBTITLE", p0, p1)
      case .SHOWEXPERIMENTALCITIESALERT:
        return L10n.tr("SHOWEXPERIMENTALCITIESALERT")
      case .ACTIVATE:
        return L10n.tr("ACTIVATE")
      case .SHOWEXPERIMENTALCITIESSETTING:
        return L10n.tr("SHOWEXPERIMENTALCITIESSETTING")
      case .FORECASTTITLE(let p0):
        return L10n.tr("FORECAST_TITLE", p0)
      case .ENDOFDATATITLE:
        return L10n.tr("END_OF_DATA_TITLE")
      case .ENDOFDATA:
        return L10n.tr("END_OF_DATA")
      case .SORTINGTYPEEUKLID:
        return L10n.tr("SORTINGTYPE_EUKLID")
      case .FORECAST:
        return L10n.tr("FORECAST")
      case .LOADINPERCENT:
        return L10n.tr("LOAD_IN_PERCENT")
    }
  }

  private static func tr(key: String, _ args: CVarArgType...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}

