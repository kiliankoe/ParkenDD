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
	var data: [String: String]?
	
	let dateFormatter = { () -> NSDateFormatter in
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy.MM.dd'T'HH:mm:ss"
//		dateFormatter.timeZone = NSTimeZone(name: "UTC")
		return dateFormatter
	}()
	
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
		
		titleLabel?.text = L10n.FORECASTTITLE(lot.name).string
		percentageLabel?.text = "\(lot.loadPercentage)% \(L10n.OCCUPIED.string)"
		availableLabel?.text = ""
		progressView?.progress = Float(lot.loadPercentage) / 100
		datePicker?.date = NSDate()
		
		updateData()
    }
	
	@IBAction func infoButtonTapped(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	@IBAction func datePickerValueDidChange(sender: UIDatePicker) {
		guard let data = data else { return }
		let dateString = dateFormatter.stringFromDate(sender.date)
		if data[dateString] == nil {
			updateData(fromDate: sender.date)
		}
	}
	
	func updateData(fromDate date: NSDate = NSDate()) {
		guard let lot = lot else { return }
		ServerController.forecastWeek(lot.id, fromDate: date) { (forecastData, error) -> Void in
			if let _ = error {
				print(error)
				let alert = UIAlertController(title: L10n.UNKNOWNERRORTITLE.string, message: L10n.UNKNOWNERROR.string, preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: L10n.CANCEL.string, style: .Cancel, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
				return
			}
			
			self.data = forecastData?.data
			self.drawGraph()
		}
	}
	
	func drawGraph() {
		guard let data = data else { return }
		let sortedDates = Array(data.keys).sort(<)
		
		var dataEntries = [ChartDataEntry]()
		for date in sortedDates {
			let value = Double(data[date]!)!
			let xIndex = sortedDates.indexOf(date)!
			let dataEntry = ChartDataEntry(value: value, xIndex: xIndex)
			dataEntries.append(dataEntry)
		}
		
		let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Belegung in %")
		let lineChartData = LineChartData(xVals: sortedDates, dataSet: lineChartDataSet)
		chartView?.data = lineChartData
	}

}
