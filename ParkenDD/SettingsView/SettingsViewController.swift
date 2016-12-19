//
//  SettingsViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 17/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Social
import MessageUI
import SwiftyDrop
import CoreLocation
import SafariServices
import Crashlytics

enum Sections: Int {
	case cityOptions = 0
	case sortingOptions
	case displayOptions
	case otherOptions
}

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.dismiss as (SettingsViewController) -> () -> ()))
		self.navigationItem.rightBarButtonItem = doneButton

		self.navigationItem.title = L10n.settings.string
		let font = UIFont(name: "AvenirNext-Medium", size: 18.0)
		var attrsDict = [String: AnyObject]()
		attrsDict[NSFontAttributeName] = font
		self.navigationController?.navigationBar.titleTextAttributes = attrsDict
    }

	func dismiss() {
		self.dismiss(animated: true, completion: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sec = Sections(rawValue: section)!
		switch sec {
		case .cityOptions:
			return 1
		case .sortingOptions:
			return 5
		case .displayOptions:
			return 3
		case .otherOptions:
			return 4
		}
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sec = Sections(rawValue: section)!
		switch sec {
		case .cityOptions:
			return L10n.cityoptions.string
		case .sortingOptions:
			return L10n.sortingoptions.string
		case .displayOptions:
			return L10n.displayoptions.string
		case .otherOptions:
			return L10n.otheroptions.string
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sec = Sections(rawValue: indexPath.section)!
		let cell: UITableViewCell = UITableViewCell()

		let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCityName)
		let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType)
		let doHideLots = UserDefaults.standard.bool(forKey: Defaults.skipNodataLots)
		let useGrayscale = UserDefaults.standard.bool(forKey: Defaults.grayscaleUI)
        let showExperimentalCities = UserDefaults.standard.bool(forKey: Defaults.showExperimentalCities)

		switch (sec, indexPath.row) {
		// CITY OPTIONS
		case (.cityOptions, 0):
			cell.textLabel!.text = selectedCity
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

		// SORTING OPTIONS
		case (.sortingOptions, 0):
			cell.textLabel?.text = L10n.sortingtypedefault.string
			cell.accessoryType = sortingType == Sorting.standard ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
		case (.sortingOptions, 1):
			cell.textLabel?.text = L10n.sortingtypelocation.string
			cell.accessoryType = sortingType == Sorting.distance ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
		case (.sortingOptions, 2):
			cell.textLabel?.text = L10n.sortingtypealphabetical.string
			cell.accessoryType = sortingType == Sorting.alphabetical ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
		case (.sortingOptions, 3):
			cell.textLabel?.text = L10n.sortingtypefreespots.string
			cell.accessoryType = sortingType == Sorting.free ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
		case (.sortingOptions, 4):
			cell.textLabel!.text = L10n.sortingtypeeuklid.string
			cell.accessoryType = sortingType == Sorting.euclid ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none

		// DISPLAY OPTIONS
		case (.displayOptions, 0):
			cell.textLabel?.text = L10n.hidenodatalots.string
			cell.accessoryType = doHideLots ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
		case (.displayOptions, 1):
			cell.textLabel?.text = L10n.usegrayscalecolors.string
			cell.accessoryType = useGrayscale ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        case (.displayOptions, 2):
            cell.textLabel?.text = L10n.showexperimentalcitiessetting.string
            cell.accessoryType = showExperimentalCities ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none

		// OTHER OPTIONS
		case (.otherOptions, 0):
			cell.textLabel?.text = L10n.aboutbutton.string
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		case (.otherOptions, 1):
			cell.textLabel?.text = L10n.shareontwitter.string
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		case (.otherOptions, 2):
			cell.textLabel?.text = L10n.sendfeedback.string
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		case (.otherOptions, 3):
			cell.textLabel?.text = L10n.requestnewcity.string
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

		default:
			break
		}

		cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		return cell

	}

	// MARK: - Table View Delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sec = Sections(rawValue: indexPath.section)!

		switch sec {
		// CITY OPTIONS
		case .cityOptions:
			performSegue(withIdentifier: "showCitySelection", sender: self)

		// SORTING OPTIONS
		case .sortingOptions:

			// Don't let the user select a location based sorting option if the required authorization is missing
			if indexPath.row == 1 || indexPath.row == 4 {
				if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
					let alertController = UIAlertController(title: L10n.locationdataerrortitle.string, message: L10n.locationdataerror.string, preferredStyle: UIAlertControllerStyle.alert)
					alertController.addAction(UIAlertAction(title: L10n.cancel.string, style: UIAlertActionStyle.cancel, handler: nil))
					alertController.addAction(UIAlertAction(title: L10n.settings.string, style: UIAlertActionStyle.default, handler: {
						(action) in
						UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
					}))
					present(alertController, animated: true, completion: nil)

					tableView.deselectRow(at: indexPath, animated: true)
					return
				}
			}

			for row in 0...4 {
				tableView.cellForRow(at: IndexPath(row: row, section: Sections.sortingOptions.rawValue))?.accessoryType = UITableViewCellAccessoryType.none
			}
			tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark

			var defaultsValue: String
			switch indexPath.row {
			case 1:
				defaultsValue = Sorting.distance
			case 2:
				defaultsValue = Sorting.alphabetical
			case 3:
				defaultsValue = Sorting.free
			case 4:
				defaultsValue = Sorting.euclid
			default:
				defaultsValue = Sorting.standard
			}
			UserDefaults.standard.setValue(defaultsValue, forKey: Defaults.sortingType)

		// DISPLAY OPTIONS
		case .displayOptions:
			switch indexPath.row {
			case 0:
				let doHideLots = UserDefaults.standard.bool(forKey: Defaults.skipNodataLots)
				if doHideLots {
					UserDefaults.standard.set(false, forKey: Defaults.skipNodataLots)
					tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
				} else {
					UserDefaults.standard.set(true, forKey: Defaults.skipNodataLots)
					tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
				}
				refreshLotlist()
			case 1:
				let useGrayscale = UserDefaults.standard.bool(forKey: Defaults.grayscaleUI)
				if useGrayscale {
					UserDefaults.standard.set(false, forKey: Defaults.grayscaleUI)
					tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
				} else {
					UserDefaults.standard.set(true, forKey: Defaults.grayscaleUI)
					tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
				}
            case 2:
                let showExperimentalCities = UserDefaults.standard.bool(forKey: Defaults.showExperimentalCities)
                if showExperimentalCities {
                    UserDefaults.standard.set(false, forKey: Defaults.showExperimentalCities)
                    tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
					Answers.logCustomEvent(withName: "Experimental Cities", customAttributes: ["experimental cities": "disable"])
                    refreshLotlist()
                } else {
                    let alert = UIAlertController(title: L10n.notetitle.string, message: L10n.showexperimentalcitiesalert.string, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: L10n.cancel.string, style: UIAlertActionStyle.cancel, handler: { (action) -> Void in

                    }))
                    alert.addAction(UIAlertAction(title: L10n.activate.string, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        UserDefaults.standard.set(true, forKey: Defaults.showExperimentalCities)
                        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                        refreshLotlist()

						Answers.logCustomEvent(withName: "Experimental Cities", customAttributes: ["experimental cities": "enable"])
                    }))
                    present(alert, animated: true, completion: nil)
                }
			default:
				break
			}

		// OTHER OPTIONS
		case .otherOptions:
			switch indexPath.row {
			case 0:
				Answers.logCustomEvent(withName: "About View", customAttributes: ["show about view": "show"])
				if #available(iOS 9.0, *) {
				    let safariVC = SFSafariViewController(url: URL(string: "http://parkendd.kilian.io/about.html")!, entersReaderIfAvailable: true)
					present(safariVC, animated: true, completion: nil)
				} else {
					UIApplication.shared.openURL(URL(string: "http://parkendd.kilian.io/about.html")!)
				}
			case 1:
				if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
					let tweetsheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
					tweetsheet?.setInitialText(L10n.tweettext.string)
					self.present(tweetsheet!, animated: true, completion: nil)
				}
			case 2:
				if MFMailComposeViewController.canSendMail() {
					let mail = MFMailComposeViewController()
					mail.mailComposeDelegate = self

					let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
					mail.setSubject("[ParkenDD v\(versionNumber!) (\(buildNumber!))] Feedback")
					mail.setToRecipients(["parkendd@kilian.io"])

					self.present(mail, animated: true, completion: nil)
				}
			case 3:
				if #available(iOS 9.0, *) {
					let safariVC = SFSafariViewController(url: URL(string: "http://goo.gl/forms/F8mmjAJxw4")!)
					present(safariVC, animated: true, completion: nil)
				} else {
					UIApplication.shared.openURL(URL(string: "http://goo.gl/forms/F8mmjAJxw4")!)
				}
			default:
				break
			}
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	// MARK: - MFMailComposeViewControllerDelegate

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		self.dismiss(animated: true, completion: nil)
	}

}

func refreshLotlist() -> Void {
    if let lotlistVC = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers[0] as? LotlistViewController {
        lotlistVC.updateData()
    }
}
