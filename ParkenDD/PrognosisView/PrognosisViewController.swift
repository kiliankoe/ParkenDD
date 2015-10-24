//
//  ForecastViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
//import Charts

class PrognosisViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var spotsAvailableLabel: UILabel?
	@IBOutlet weak var progressBar: UIProgressView?
	@IBOutlet weak var datePicker: UIDatePicker?
	@IBOutlet weak var percentageLabel: UILabel?
//	@IBOutlet weak var chartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

		let currentDate = NSDate()

//		titleLabel?.text = L10n.PROGNOSISCENTRUMGALERIE.stsring
		percentageLabel?.text = "15% \(L10n.OCCUPIED.string)"
		spotsAvailableLabel?.text = L10n.CIRCASPOTSAVAILABLE("892/1050").string

//		ServerController.sendForecastRequest("dresdencentrumgalerie", fromDate: currentDate, toDate: currentDate.dateByAddingTimeInterval(3600*24*7)) { (data) -> () in
//
//			dispatch_async(dispatch_get_main_queue(), { () -> Void in
//				self.lineGraph.colorLine = UIColor.blackColor()
//				self.lineGraph.reloadGraph()
//			})
//		}

		// Setup BEMSimpleLineGraph
//		lineGraph.colorTop = UIColor.clearColor()
//		lineGraph.colorBottom = UIColor.clearColor()
//		lineGraph.colorPoint = UIColor.clearColor()
//		lineGraph.animationGraphEntranceTime = 0.7
//		lineGraph.enableBezierCurve = true

		// Feels hacky, but the graph starts animating on viewDidLoad and the data only comes in a second later
		// until that reload fires, I don't want to be showing a drawing line
//		lineGraph.colorLine = UIColor.clearColor()

		datePicker?.date = currentDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

	
	@IBAction func infoButtonPressed(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	@IBAction func datePickerValueChanged(sender: UIDatePicker) {

//		ServerController.sendForecastRequest("dresdencentrumgalerie", fromDate: sender.date, toDate: dateWeekLater, completion: { () -> () in
//
//		})
		
		ServerController.forecastWeek("dresdencentrumgalerie", fromDate: NSDate()) { (forecastData, error) -> Void in
			print(forecastData)
		}

		var prognosis: Float = 0.0

		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let currentDateString = dateFormatter.stringFromDate(sender.date)

//		for row in csvData.rows {
//			if let rowDate = row["date"] where rowDate == currentDateString {
//				prognosis = (row["percentage"]! as NSString).floatValue / 100
//				break
//			}
//		}

		progressBar?.progress = prognosis
		let occupiedString = L10n.OCCUPIED.string
		percentageLabel?.text = "\(Int(round(prognosis*100)))% \(occupiedString)"

//		let availableSpots = 1050-(1050*prognosis)
//		let caString = L10n.CIRCA.string
//		let spotsAvailableString = L10n.SPOTSAVAILABLE.string
//		spotsAvailableLabel?.text = "\(caString) \(Int(round(availableSpots)))/1050 \(spotsAvailableString)"
	
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - BEMSimpleLineGraphDataSource
	// /////////////////////////////////////////////////////////////////////////

//	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
//		if let csvData = csvData {
//			return csvData.rows.count
//		}
//		return 0
//	}

//	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
//		let row = csvData.rows[index]
//		if let percentage = row["percentage"] {
//			return CGFloat((percentage as NSString).doubleValue)
//		}
//		return 0
//	}

//	func lineGraph(graph: BEMSimpleLineGraphView!, labelOnXAxisForIndex index: Int) -> String! {
//		return thisWeekLabels[index]
//	}

//	func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
//		return 25
//	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - BEMSimpleLineGraphDelegate
	// /////////////////////////////////////////////////////////////////////////
}
