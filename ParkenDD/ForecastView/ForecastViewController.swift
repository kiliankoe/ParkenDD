//
//  ForecastViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 24/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Charts

class ForecastViewController: UIViewController {
	
	var lot: Parkinglot?
	
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var chartView: LineChartView?
	@IBOutlet weak var percentageLabel: UILabel?
	@IBOutlet weak var progressView: UIProgressView?
	@IBOutlet weak var availableLabel: UILabel?
	@IBOutlet weak var datePicker: UIDatePicker?
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		guard let lot = lot else {
			NSLog("Initialized ForecastVC without a lot. Wat?")
			self.dismissViewControllerAnimated(true, completion: nil)
			return
		}
		
		let currentDate = NSDate()
		
		titleLabel?.text = L10n.FORECASTTITLE(lot.name).string
		percentageLabel?.text = "\(lot.loadPercentage)% \(L10n.OCCUPIED.string)"
		availableLabel?.text = ""
		progressView?.progress = Float(lot.loadPercentage) / 100
		datePicker?.date = currentDate
		
		ServerController.forecastWeek(lot.id, fromDate: currentDate) { (forecastData, error) -> Void in
			print(forecastData)
		}
    }
	
	@IBAction func infoButtonTapped(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	

}
