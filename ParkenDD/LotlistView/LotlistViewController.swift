//
//  ViewController.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 18/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import ParkKit
import SwiftyTimer

class LotlistViewController: UITableViewController, UIViewControllerPreviewingDelegate {

	var parkinglots = [Lot]()
	var defaultSortedParkinglots = [Lot]()

	var dataURL: String?

    var dataSource = LotlistDataSource()

	@IBOutlet weak var titleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

        tableView.dataSource = dataSource

        Location.shared.onMove { [weak self] location in
            self?.tableView.reloadData()
        }

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
			if Location.authState == .authorizedWhenInUse {
                Location.manager.startUpdatingLocation()
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
			Location.manager.stopUpdatingLocation()
		}

        (tableView.dataSource as? LotlistDataSource)?.sortLots()

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
	@objc func updateData() {
		showActivityIndicator()

		// Set title to selected city
		updateTitle(withCity: nil)

        guard let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCity),
            let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType) else {
            return
        }

        park.fetchLots(forCity: selectedCity) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.stopRefreshUI()
                self?.handleUpdateError(error)
            case .success(let response):
                self?.stopRefreshUI()
                self?.showOutdatedDataWarning(lastUpdated: response.lastUpdated, lastDownloaded: response.lastDownloaded)
                DispatchQueue.main.async {
                    (self?.tableView.dataSource as? LotlistDataSource)?.set(lots: response.lots)
                    self?.parkinglots = response.lots
                    self?.tableView.reloadData()
                }
            }
        }
	}

    func showOutdatedDataWarning(lastUpdated: Date, lastDownloaded: Date) {
        // TODO: Use both dates to give a diff to the user or show that the server seems to be broken.
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let dateDiff = calendar.dateComponents(Set([.minute]), from: lastUpdated, to: now)

        var attrs = [NSAttributedStringKey: Any]()

        if let diff = dateDiff.minute, diff >= 60 {
            attrs = [NSAttributedStringKey.foregroundColor: UIColor.red]
            drop(L10n.outdatedDataWarning.string, state: .blur(.dark))
        }

        let dateFormatter = DateFormatter(dateFormat: "dd.MM.yyyy HH:mm", timezone: nil)
        DispatchQueue.main.async {
            self.refreshControl?.attributedTitle = NSAttributedString(string: "\(L10n.lastUpdated(dateFormatter.string(from: lastUpdated)))", attributes: attrs)
        }
    }

	/**
	Called by the request to the API in case of failure and handed the error to display to the user.
	*/
	func handleUpdateError(_ err: Error) {
        let description = err.localizedDescription
        drop(description, state: .error)
//        switch err {
//        case .server(_), .decoding:
//            drop(L10n.serverError.string, state: .error)
//        case .request:
//            drop(L10n.requestError.string, state: .error)
//            // TODO: Is this really a good idea?
////        case .notFound:
////            UserDefaults.standard.set("Dresden", forKey: Defaults.selectedCity)
////            UserDefaults.standard.set("Dresden", forKey: Defaults.selectedCityName)
////            UserDefaults.standard.synchronize()
////            updateData()
////            updateTitle(withCity: "Dresden")
//        default:
//            drop(L10n.unknownError.string, state: .error)
//        }
	}
	
	func updateTitle(withCity city: String?) {
		if let city = city {
			titleButton.setTitle(city, for: UIControlState())
		} else {
			let selectedCity = UserDefaults.standard.string(forKey: Defaults.selectedCityName)
			titleButton.setTitle(selectedCity, for: UIControlState())
		}
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

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: String(describing: LotCell.self)) as? LotCell) ?? LotCell()
		
		let thisLot = parkinglots[indexPath.row]
		cell.setParkinglot(thisLot)

		// Don't display any separators if the list is still empty
		if parkinglots.count == 0 {
			tableView.separatorStyle = .none
		} else {
			tableView.separatorStyle = .singleLine
		}

		return cell
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UITableViewDelegate
	// /////////////////////////////////////////////////////////////////////////

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let _ = (tableView.cellForRow(at: indexPath) as? LotCell)?.parkinglot?.coordinate {
			performSegue(withIdentifier: "showParkinglotMap", sender: self)
		} else {
			drop(L10n.noCoordsWarning.string, state: .blur(.dark))
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// /////////////////////////////////////////////////////////////////////////
	// MARK: - UIViewControllerPreviewingDelegate
	// /////////////////////////////////////////////////////////////////////////
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//		let fullForecastVC = ForecastViewController()
//		fullForecastVC.lot = (viewControllerToCommit as? MiniForecastViewController)?.lot
//		show(fullForecastVC, sender: nil)
	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//		if let indexPath = tableView.indexPathForRow(at: location) {
//			guard let hasForecast = (tableView.cellForRow(at: indexPath) as? LotCell)?.parkinglot?.hasForecast, hasForecast else { return nil }
//			
//			if #available(iOS 9.0, *) {
//			    previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
//			}
//			let forecastVC = MiniForecastViewController()
//			forecastVC.lot = parkinglots[indexPath.row]
//			return forecastVC
//		}
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
