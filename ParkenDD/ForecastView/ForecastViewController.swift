//
//  ForecastViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 24/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Charts
import Crashlytics

class ForecastViewController: UIViewController {
	
	var lot: Parkinglot?
	var data: [String: String]?
	
	let dateFormatter = { () -> NSDateFormatter in
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//		dateFormatter.timeZone = NSTimeZone(name: "UTC")
		return dateFormatter
	}()
	
	let labelDateFormatter = { () -> NSDateFormatter in
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter
	}()
	
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var chartView: LineChartView?
	@IBOutlet weak var percentageLabel: UILabel?
	@IBOutlet weak var progressView: UIProgressView?
	@IBOutlet weak var availableLabel: UILabel?
	@IBOutlet weak var datePicker: UIDatePicker?
	
	var currentLine: ChartLimitLine?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		guard let lot = lot else {
			NSLog("Initialized ForecastVC without a lot. Wat?")
			self.dismissViewControllerAnimated(true, completion: nil)
			return
		}
		
		Answers.logCustomEventWithName("View Forecast", customAttributes: ["selected lot": lot.id])
		
		titleLabel?.text = L10n.FORECASTTITLE(lot.name).string
		percentageLabel?.text = "\(lot.loadPercentage)% \(L10n.OCCUPIED.string)"
		availableLabel?.text = L10n.CIRCASPOTSAVAILABLE(genAvailability(lot.total, load: lot.loadPercentage)).string
		progressView?.progress = Float(lot.loadPercentage) / 100
		datePicker?.date = NSDate()
		
		chartView?.descriptionText = L10n.LOADINPERCENT.string
		
		chartView?.backgroundColor = UIColor.whiteColor()
		chartView?.xAxis.labelPosition = .Bottom
		chartView?.gridBackgroundColor = UIColor.whiteColor()
		chartView?.highlightPerDragEnabled = false
		chartView?.highlightEnabled = false
		chartView?.rightAxis.enabled = false
		chartView?.drawGridBackgroundEnabled = false
		chartView?.legend.enabled = false
		chartView?.animate(xAxisDuration: 1.0)
		
		updateData()
    }
	
	@IBAction func infoButtonTapped(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	@IBAction func datePickerValueDidChange(sender: UIDatePicker) {
		guard let data = data else { return }
		
		let dateString = clearSeconds(fromDate: sender.date)
		
		updateLabels(data[dateString])
		
		let sortedDates = Array(data.keys).sort(<)
		
		if let limit = sortedDates.indexOf(dateString) {
			if currentLine == nil {
				chartView?.xAxis.removeAllLimitLines()
				currentLine = ChartLimitLine()
				chartView?.xAxis.addLimitLine(currentLine!)
			}
			currentLine?.limit = Double(limit)
			currentLine?.label = labelDateFormatter.stringFromDate(sender.date)
		}
		
		// Only update data from API if the selected date is after or before the currently selected day
		if dateFormatter.stringFromDate(sender.date) > sortedDates.last! || dateFormatter.stringFromDate(sender.date) < sortedDates.first! {
			updateData(fromDate: sender.date)
		} else {
			drawGraph()
		}
	}
	
	func updateData(fromDate date: NSDate = NSDate()) {
		guard let lot = lot else { return }
		ServerController.forecastDay(lot.id, fromDate: date) { [unowned self] (forecastData, error) -> Void in
			if let error = error {
				switch error {
				case .NoData:
					let alert = UIAlertController(title: L10n.ENDOFDATATITLE.string, message: L10n.ENDOFDATA.string, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: L10n.CANCEL.string, style: .Cancel, handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				default:
					let alert = UIAlertController(title: L10n.UNKNOWNERRORTITLE.string, message: L10n.UNKNOWNERROR.string, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: L10n.CANCEL.string, style: .Cancel, handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				}
				return
			}
			
			self.data = forecastData?.data
			self.drawGraph()
			
			if let selectedTime = self.datePicker?.date {
				self.updateLabels(self.data![self.clearSeconds(fromDate: selectedTime)])
			}
		}
	}
	
	func updateLabels(load: String?) {
		if let load = load {
			percentageLabel?.text = "\(load)% \(L10n.OCCUPIED.string)"
			progressView?.progress = Float(load)! / 100
			availableLabel?.text = L10n.CIRCASPOTSAVAILABLE(genAvailability(lot!.total, load: Int(load)!)).string
		}
	}
	
	func drawGraph() {
		guard let data = data else { return }
		let sortedDates = Array(data.keys).sort(<)
		
		let labels = sortedDates.map { (e) -> String in
			let date = dateFormatter.dateFromString(e)
			return labelDateFormatter.stringFromDate(date!)
		}
		
		var dataEntries = [ChartDataEntry]()
		for date in sortedDates {
			let value = Double(data[date]!)!
			let xIndex = sortedDates.indexOf(date)!
			let dataEntry = ChartDataEntry(value: value, xIndex: xIndex)
			dataEntries.append(dataEntry)
		}
		
		let lineChartDataSet = LineChartDataSet(yVals: dataEntries)
		lineChartDataSet.colors = [UIColor.darkGrayColor()]
		lineChartDataSet.fillColor = UIColor.grayColor()
		lineChartDataSet.drawValuesEnabled = false
		lineChartDataSet.drawCirclesEnabled = false
		lineChartDataSet.drawFilledEnabled = true
		lineChartDataSet.drawCubicEnabled = true
		let lineChartData = LineChartData(xVals: labels, dataSet: lineChartDataSet)
		chartView?.data = lineChartData
	}
	
	/**
	Working around the idiotic fact, that a UIDatePicker returns a random amount of seconds in its date
	without giving the user a possiblity of changing these anyways. Why?!
	
	- parameter date: a date
	
	- returns: a string representation of the date with cleared seconds
	*/
	func clearSeconds(fromDate date: NSDate) -> String {
		// This is just ridiculous, please don't look at it :(
		let dateString = dateFormatter.stringFromDate(date)
		let newDate = dateString.substringToIndex(dateString.endIndex.predecessor().predecessor())
		return "\(newDate)00"
	}
	
	/**
	Generate an availablity string for a parking lot.
	
	- parameter total: total available spaces
	- parameter load:  load as int percentage between 0 and 100
	
	- returns: e.g. "400/1000"
	*/
	func genAvailability(total: Int, load: Int) -> String {
		let available = total - Int(Double(total) * (Double(load) / 100))
		return "\(available)/\(total)"
	}
}
