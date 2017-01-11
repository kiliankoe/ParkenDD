//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreLocation
import ParkKit
import SwiftyTimer
import Crashlytics

class LotlistViewController: UITableViewController, CLLocationManagerDelegate, UIViewControllerPreviewingDelegate {

	let locationManager = CLLocationManager()

	var parkinglots = [Lot]()
	var defaultSortedParkinglots = [Lot]()

	var dataURL: String?

	@IBOutlet weak var titleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		// set CLLocationManager delegate
		locationManager.delegate = self

		// display the standard reload button
		showReloadButton()

		// pretty navbar with black buttons
		let navBar = self.navigationController?.navigationBar
		navBar!.isTranslucent = false
		navBar!.tintColor = UIColor.black

		// Set title to selected city
		updateTitle(withCity: nil)

		// Set a table footer view so that separators aren't shown when no data is yet present
		self.tableView.tableFooterView = UIView(frame: CGRect.zero)

		if #available(iOS 9.0, *) {
			registerForPreviewing(with: self, sourceView: tableView)
		}

		updateData()
		Timer.every(5.minutes, updateData)
	}

	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()

		// Start getting location updates if the user wants lots sorted by distance
		if let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType), sortingType == Sorting.distance || sortingType == Sorting.euclid {
			if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
				locationManager.startUpdatingLocation()
			} else {
				let alertController = UIAlertController(title: L10n.locationDataErrorTitle.string, message: L10n.locationDataError.string, preferredStyle: UIAlertControllerStyle.alert)
				alertController.addAction(UIAlertAction(title: L10n.cancel.string, style: UIAlertActionStyle.cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: L10n.settings.string, style: UIAlertActionStyle.default, handler: {
					(action) in
					UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
				}))
				present(alertController, animated: true, completion: nil)
			}
		} else {
			locationManager.stopUpdatingLocation()
		}

		sortLots()

		refreshControl?.endRefreshing()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showParkinglotMap" {
			let indexPath = tableView.indexPathForSelectedRow

			let selectedParkinglot = parkinglots[indexPath!.row]

			let mapVC = segue.destination as? MapViewController
			mapVC?.detailParkinglot = selectedParkinglot
			mapVC?.allParkinglots = parkinglots
		}
	}

	/**
	Call ServerController to update all local data, catch possible errors and handle the UI based on the refresh (e.g. UIRefreshControl and the UIBarButtonItem).
	*/
	func updateData() {
		showActivityIndicator()

		// Set title to selected city
		updateTitle(withCity: nil)

        guard let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCity),
            let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType) else {
            return
        }
        Answers.logCustomEvent(withName: "View City", customAttributes: ["selected city": selectedCity, "sorting type": sortingType])

        ParkKit().fetchCities(onFailure: { [weak self] error in
            self?.handleUpdateError(error)
            self?.stopRefreshUI()
        }) { [weak self] response in
            self?.stopRefreshUI()

            let showExperimentalCities = UserDefaults.standard.bool(forKey: Defaults.showExperimentalCities) 
            let citiesList = showExperimentalCities ? response.cities : response.cities.filter { $0.hasActiveSupport }
            (UIApplication.shared.delegate as? AppDelegate)?.citiesList = citiesList

            ParkKit().fetchLots(forCity: selectedCity, onFailure: { [weak self] error in
                self?.handleUpdateError(error)
                self?.stopRefreshUI()
            }) { [weak self] response in
                self?.stopRefreshUI()

                let skipNodataLots = UserDefaults.standard.bool(forKey: Defaults.skipNodataLots)
                let lots = skipNodataLots ? response.lots.filter { $0.state != .nodata } : response.lots

                self?.parkinglots = lots
                self?.defaultSortedParkinglots = lots

                self?.showOutdatedDataWarning(lastUpdated: response.lastUpdated, lastDownloaded: response.lastDownloaded)
            }
        }
	}

    func showOutdatedDataWarning(lastUpdated: Date, lastDownloaded: Date) {
        // TODO: Use both dates to give a diff to the user or show that the server seems to be broken.
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let dateDiff = calendar.dateComponents(Set([.minute]), from: lastUpdated, to: now)

        var attrs = [String: Any]()

        if let diff = dateDiff.minute, diff >= 60 {
            attrs = [NSForegroundColorAttributeName: UIColor.red]
            drop(L10n.outdatedDataWarning.string, state: .blur(.dark))
        }

        let dateFormatter = DateFormatter(dateFormat: "dd.MM.yyyy HH:mm", timezone: nil)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "\(L10n.lastUpdated(dateFormatter.string(from: lastUpdated)))", attributes: attrs)
    }

	/**
	Called by the request to the API in case of failure and handed the error to display to the user.
	*/
	func handleUpdateError(_ err: ParkError) {
		switch err {
		case .server, .incompatibleAPI:
			drop(L10n.serverError.string, state: .error)
		case .request:
			drop(L10n.requestError.string, state: .error)
		case .notFound:
			UserDefaults.standard.set("Dresden", forKey: Defaults.selectedCity)
			UserDefaults.standard.set("Dresden", forKey: Defaults.selectedCityName)
			UserDefaults.standard.synchronize()
			updateData()
			updateTitle(withCity: "Dresden")
		default:
			drop(L10n.unknownError.string, state: .error)
		}
	}
	
	func updateTitle(withCity city: String?) {
		if let city = city {
			titleButton.setTitle(city, for: UIControlState())
		} else {
			let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCityName)
			titleButton.setTitle(selectedCity, for: UIControlState())
		}
	}

	/**
	Sort the parkingslots array based on what is currently saved for SortingType in NSUserDefaults.
	*/
	func sortLots() {
		guard let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType) else { return }
		switch sortingType {
		case Sorting.distance:
			parkinglots.sort(by: {
				(lot1: Parkinglot, lot2: Parkinglot) -> Bool in
				if let currentUserLocation = locationManager.location {
					return lot1.distance(from: currentUserLocation) < lot2.distance(from: currentUserLocation)
				}
				return lot1.name < lot2.name
			})
		case Sorting.alphabetical:
			parkinglots.sort(by: {
				$0.name < $1.name
			})
		case Sorting.free:
			parkinglots.sort(by: {
				$0.getFree() > $1.getFree()
			})
		case Sorting.euclid:
			self.parkinglots.sort(by: sortEuclidian)
		default:
			parkinglots = defaultSortedParkinglots
		}
	}

	func sortEuclidian(_ lot1: Parkinglot, lot2: Parkinglot) -> Bool {
		if let currentUserLocation = locationManager.location {
			// TODO: Also check if state is either open or unknown, others should not be sorted
			if lot1.total != 0 && lot2.total != 0 {
				let occ1 = Double(lot1.total - lot1.getFree()) / Double(lot1.total)
				let occ2 = Double(lot2.total - lot2.getFree()) / Double(lot2.total)
				
				// This factor gives a penalty for very crowded parking spaces
				// so they are ranked down the list, even if they are very close
				let smoothingfactor1 = 1.0 / Double(2.0*(1.0-occ1))
				let smoothingfactor2 = 1.0 / Double(2.0*(1.0-occ2))
				
				let sqrt1 = sqrt(pow(lot1.distance(from: currentUserLocation), 2.0) + smoothingfactor1 * pow(Double(occ1*1000), 2.0))
				let sqrt2 = sqrt(pow(lot2.distance(from: currentUserLocation), 2.0) + smoothingfactor2 * pow(Double(occ2*1000), 2.0))

				return sqrt1 < sqrt2
			}
		}
		return lot1.free > lot2.free
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

	@IBAction func titleButtonTapped(_ sender: UIButton) {
		let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: Bundle.main)
		let citySelectionVC = settingsStoryBoard.instantiateViewController(withIdentifier: "City SelectionTVC")
		show(citySelectionVC, sender: self)
	}
	
	@IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
		let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: Bundle.main)
		let settingsVC = settingsStoryBoard.instantiateInitialViewController()!
		navigationController?.present(settingsVC, animated: true, completion: nil)
	}
	
	// /////////////////////////////////////////////////////////////////////////
	// MARK: - Reload Button Stuff
	// /////////////////////////////////////////////////////////////////////////

	/**
	Remove all UI that has to do with refreshing data.
	*/
	func stopRefreshUI() {
		DispatchQueue.main.async(execute: { [unowned self] () -> Void in
			self.showReloadButton()
			self.refreshControl?.beginRefreshing() // leaving this here to fix a slight offset bug with the refresh control's attributed title
			self.refreshControl?.endRefreshing()
		})
	}

	/**
	Replace the right UIBarButtonItem with the reload button.
	*/
	func showReloadButton() {
		let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(LotlistViewController.updateData))
		navigationItem.rightBarButtonItem = refreshButton
	}

	/**
	Replace the right UIBarButtonItem with a UIActivityIndicatorView.
	*/
	func showActivityIndicator() {
		let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		activityIndicator.color = UIColor.black
		activityIndicator.startAnimating()
		let activityItem = UIBarButtonItem(customView: activityIndicator)
		navigationItem.rightBarButtonItem = activityItem
	}

	@IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
		updateData()
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDataSource
	// /////////////////////////////////////////////////////////////////////////

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return parkinglots.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row < parkinglots.count {
			return 60
		}
		return 30
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "parkinglotCell") as? ParkinglotTableViewCell
		if cell == nil {
			cell = ParkinglotTableViewCell()
		}
		
		let thisLot = parkinglots[indexPath.row]
		cell?.setParkinglot(thisLot)
		
		// Since we've got the locationManager available here it's kinda tricky telling the cell what the current distance
		// from the lot is, so we're passing that along and setting the label in the cell class to keep it separate.
		let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType)!
		if sortingType == Sorting.distance || sortingType == Sorting.euclid {
			if let userLocation = locationManager.location {
				cell?.distance = thisLot.distance(from: userLocation)
			} else {
				cell?.distance = Const.dummyDistance
			}
		}

		// Don't display any separators if the list is still empty
		if parkinglots.count == 0 {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		} else {
			tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
		}

		return cell!
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDelegate
	// /////////////////////////////////////////////////////////////////////////

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let _ = (tableView.cellForRow(at: indexPath) as? ParkinglotTableViewCell)?.parkinglot?.coords {
			performSegue(withIdentifier: "showParkinglotMap", sender: self)
		} else {
			drop(L10n.noCoordsWarning.string, state: .blur(.dark))
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - CLLocationManagerDelegate
	// /////////////////////////////////////////////////////////////////////////
	var lastLocation: CLLocation?
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let currentUserLocation = locationManager.location

		// The idea here is to check the location on each update from the locationManager and only re-sort
		// the lots and update the tableView if the user has moved more than 100 meters. Doing both every
		// second is aggravating and really not necessary.
		if let lastLoc = lastLocation {
			let distance = currentUserLocation!.distance(from: lastLoc)
			if distance > 100 {
				sortLots()
				tableView.reloadData()
				lastLocation = locations.last
			}
		} else {
			// we need to set lastLocation at least once somewhere
			lastLocation = locations.last
			tableView.reloadData()
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		// TODO: Implement me to hopefully fix #41
	}
	
	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UIViewControllerPreviewingDelegate
	// /////////////////////////////////////////////////////////////////////////
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		let fullForecastVC = ForecastViewController()
		fullForecastVC.lot = (viewControllerToCommit as? MiniForecastViewController)?.lot
		show(fullForecastVC, sender: nil)
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		if let indexPath = tableView.indexPathForRow(at: location) {
			guard (tableView.cellForRow(at: indexPath) as? ParkinglotTableViewCell)!.parkinglot!.forecast! else { return nil }
			
			if #available(iOS 9.0, *) {
			    previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
			}
			let forecastVC = MiniForecastViewController()
			forecastVC.lot = parkinglots[indexPath.row]
			return forecastVC
		}
		return nil
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - Helpers
	// /////////////////////////////////////////////////////////////////////////

	func viewWithImageName(_ imageName: String) -> UIImageView {
		let image = UIImage(named: imageName)
		let imageView = UIImageView(image: image)
		imageView.contentMode = UIViewContentMode.center
		return imageView
	}
}
