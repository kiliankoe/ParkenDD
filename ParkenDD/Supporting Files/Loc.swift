// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
    case REQUESTERRORTITLE
    case REQUESTERROR
    case SERVERERRORTITLE
    case SERVERERROR
    case UNKNOWNCOORDINATESTITLE
    case UNKNOWNCOORDINATESERROR
    case LASTUPDATE
    case NODATA
    case OCCUPIED
    case CLOSED
    case UNKNOWNADDRESS
    case UNKNOWNLOAD
    case OTHEROPTIONS
    case SORTINGTYPELOCATION
    case SHAREONTWITTER
    case SORTINGTYPEFREESPOTS
    case SORTINGOPTIONS
    case SORTINGTYPEALPHABETICAL
    case ABOUTBUTTON
    case SORTINGTYPEDEFAULT
    case NSLocationWhenInUseUsageDescription
    case TWEETTEXT
    case WAITINGFORLOCATION
    case APPSTOREDESCRIPTION
    case APPSTORETAGS
    case LOCATIONDATAERRORTITLE
    case LOCATIONDATAERROR
    case CANCEL
    case SETTINGS
    case CIRCASPOTSAVAILABLE(String)
    case DISPLAYOPTIONS
    case HIDENODATALOTS
    case NOTETITLE
    case LISTUPDATEONREFRESH
    case USEGRAYSCALECOLORS
    case RESETNOTIFICATIONS
    case SENDFEEDBACK
    case OUTDATEDDATAWARNINGTITLE
    case OUTDATEDDATAWARNING
    case UNKNOWNERRORTITLE
    case UNKNOWNERROR
    case LASTUPDATED(String)
    case NOCOORDSWARNINGTITLE
    case NOCOORDSWARNING
    case CITYOPTIONS
    case FORECASTINFOTITLE
    case FORECASTINFOTEXT
    case MAPSUBTITLE(String, Int)
    case SHOWEXPERIMENTALCITIESALERT
    case ACTIVATE
    case SHOWEXPERIMENTALCITIESSETTING
    case FORECASTTITLE(String)
    case SORTINGTYPEEUKLID
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
            case .NODATA:
                return L10n.tr("NO_DATA")
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
            case .SORTINGTYPEEUKLID:
                return L10n.tr("SORTINGTYPE_EUKLID")
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

