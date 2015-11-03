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
	
	let dateFormatter = NSDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", timezone: nil)
	let labelDateFormatter = NSDateFormatter(dateFormat: "HH:mm", timezone: nil)
	
	@IBOutlet weak var chartView: LineChartView?
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
		
		navigationItem.title = lot.name
		availableLabel?.text = L10n.CIRCASPOTSAVAILABLE(genAvailability(lot.total, load: lot.loadPercentage)).string
		datePicker?.date = NSDate()
		
		chartView?.descriptionText = L10n.LOADINPERCENT.string
		
		chartView?.backgroundColor = UIColor.whiteColor()
		chartView?.gridBackgroundColor = UIColor.whiteColor()
		chartView?.userInteractionEnabled = false
		chartView?.drawGridBackgroundEnabled = false
		chartView?.legend.enabled = false
		chartView?.autoScaleMinMaxEnabled = false
		chartView?.animate(xAxisDuration: 0.5)
		
		chartView?.xAxis.labelPosition = .Bottom
		chartView?.xAxis.drawGridLinesEnabled = false
		chartView?.xAxis.drawAxisLineEnabled = false
		
		chartView?.rightAxis.enabled = false
		
		chartView?.leftAxis.gridColor = UIColor(rgba: "#E4E4E4")
		chartView?.leftAxis.drawAxisLineEnabled = false
		chartView?.leftAxis.drawLabelsEnabled = false
		chartView?.leftAxis.customAxisMax = 100.0
		chartView?.leftAxis.customAxisMin = 0.0
		
		chartView?.backgroundColor = UIColor(rgba: "#F6F6F6")
		
		updateData()
    }
	
	@IBAction func infoButtonTapped(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	@IBAction func datePickerValueDidChange(sender: UIDatePicker) {
		guard let data = data else { return }
		
		let dateString = dateFormatter.stringFromDate(getDatepickerDate())
		
		updateLabels(data[dateString])
		
		let sortedDates = Array(data.keys).sort(<)
		
		if let limit = sortedDates.indexOf(dateString) {
			if currentLine == nil {
				chartView?.xAxis.removeAllLimitLines()
				currentLine = ChartLimitLine()
				chartView?.xAxis.addLimitLine(currentLine!)
			}
			currentLine?.limit = Double(limit)
			currentLine?.label = "\(data[dateString]!)%"
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
			self.datePickerValueDidChange(self.datePicker!) // Am I really doing this? Oh god... See #132
			
			self.updateLabels(self.data![self.dateFormatter.stringFromDate(self.getDatepickerDate())])
		}
	}
	
	func updateLabels(load: String?) {
		if let load = load {
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
	Get the datepickers date value and round that to the nearest half hour also settings the seconds to 0.
	
	- returns: date value of datepicker
	*/
	func getDatepickerDate() -> NSDate {
		let dpDate = datePicker!.date
		
		let calendar = NSCalendar.currentCalendar()
		let minuteComponent = calendar.components(NSCalendarUnit.Minute, fromDate: dpDate)
		
		let components = NSDateComponents()
		
		if minuteComponent.minute < 30 {
			components.minute = 60 - minuteComponent.minute
		} else {
			components.minute = 30 - minuteComponent.minute
		}
		
		let secondComponent = calendar.components(NSCalendarUnit.Second, fromDate: dpDate)
		components.second = -secondComponent.second
		
		return calendar.dateByAddingComponents(components, toDate: dpDate, options: NSCalendarOptions.WrapComponents)!
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
