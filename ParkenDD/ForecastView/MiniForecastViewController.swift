//
//  MiniForecastViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 03/11/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Charts

class MiniForecastViewController: UIViewController {
	
	@IBOutlet weak var chartView: LineChartView!
	
	var currentLine: ChartLimitLine?
	
	var lot: Parkinglot?
	var data: [String: String]?
	
	let dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss", timezone: nil)
	let labelDateFormatter = DateFormatter(dateFormat: "HH:mm", timezone: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

		guard let lot = lot else {
			NSLog("Initialized MiniForecastVC without a lot. Wat?")
			self.dismiss(animated: true, completion: nil)
			return
		}
		
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
		
		ServerController.forecastDay(lot.lotID, fromDate: Date()) { [unowned self] (forecastData, error) -> Void in
			if let _ = error {
				return
			}
			
			self.data = forecastData?.data
			self.drawGraph()
		}
    }
	
	func drawGraph() {
		guard let data = data else { return }
		let sortedDates = Array(data.keys).sorted(by: <)
		
		let labels = sortedDates.map { (element) -> String in
			let date = dateFormatter.date(from: element)
			return labelDateFormatter.string(from: date!)
		}
		
		var dataEntries = [ChartDataEntry]()
		for date in sortedDates {
			let value = Double(data[date]!)!
			let xIndex = sortedDates.index(of: date)!
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
		
		let dateString = dateFormatter.string(from: getDate())
		if let limit = sortedDates.index(of: dateString) {
			if currentLine == nil {
				chartView?.xAxis.removeAllLimitLines()
				currentLine = ChartLimitLine()
				chartView?.xAxis.addLimitLine(currentLine!)
			}
			currentLine?.limit = Double(limit)
			currentLine?.label = "\(data[dateString]!)%"
		}
	}
	
	func getDate() -> Date {
		let dpDate = Date()
		
		let calendar = Calendar.current
		let minuteComponent = (calendar as NSCalendar).components(Calendar.Unit.minute, from: dpDate)
		
		var components = DateComponents()
		
		if minuteComponent.minute! < 30 {
			components.minute = 60 - minuteComponent.minute!
		} else {
			components.minute = 30 - minuteComponent.minute!
		}
		
		let secondComponent = (calendar as NSCalendar).components(Calendar.Unit.second, from: dpDate)
		components.second = -secondComponent.second
		
		return (calendar as NSCalendar).date(byAdding: components, to: dpDate, options: NSCalendar.Options.wrapComponents)!
	}

}
