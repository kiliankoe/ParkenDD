//
//  PrognosisViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import BEMSimpleLineGraph

class PrognosisViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var spotsAvailableLabel: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var percentageLabel: UILabel!
	@IBOutlet weak var lineGraph: BEMSimpleLineGraphView!

	var csvData: CSV!
	var thisWeekData = [68, 77, 86, 95, 87, 82, 78, 77, 75, 74, 72, 71, 76, 79, 78, 75, 71, 67, 60, 53, 49, 45, 43, 41, 41, 40, 42, 44, 43, 45, 47, 52, 57, 62, 67, 71, 76, 79, 78, 75, 71, 64, 58, 51, 47, 43, 41, 39, 39, 40, 42, 44, 43, 45, 47, 52, 57, 62, 67, 71, 76, 79, 78, 75, 71, 64, 58, 51, 45, 38, 34, 30, 27, 27, 26, 26, 28, 32, 37, 44, 51, 58, 65, 72, 76, 79, 78, 75, 71, 64, 57, 50, 44, 37, 33, 29, 26, 26, 26, 26, 25, 28, 33, 40, 47, 54, 61, 69, 76, 79, 80, 78, 75, 69, 62, 56, 48, 40, 33, 26, 21, 19, 17, 15, 16, 17, 24, 33, 44, 54, 65, 75, 84, 93, 96, 94, 89, 80, 72, 63, 63, 62, 63, 66, 71, 79, 87, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 86, 78, 70, 62, 54, 45, 36, 27]
	let thisWeekLabels = ["Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Mon", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Tue", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Wed", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Thu", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Fri", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sat", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun", "Sun"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

		titleLabel.text = NSLocalizedString("PROGNOSIS_CENTRUM_GALERIE", comment: "Prognosis for Centrum Galerie")
		let occupiedString = NSLocalizedString("OCCUPIED", comment: "occupied")
		percentageLabel.text = "15% \(occupiedString)"
		let caString = NSLocalizedString("CIRCA", comment: "ca.")
		let spotsAvailableString = NSLocalizedString("SPOTS_AVAILABLE", comment: "spots available")
		spotsAvailableLabel.text = "\(caString) 892/1050 \(spotsAvailableString)"

		// Read the CSV data on another thread
		let csvqueue = dispatch_queue_create("csvqueue", nil)
		dispatch_async(csvqueue, { () -> Void in
			self.readCSV()

			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.lineGraph.colorLine = UIColor.blackColor()
				self.lineGraph.reloadGraph()
			})
		})

		// Setup BEMSimpleLineGraph
		lineGraph.colorTop = UIColor.clearColor()
		lineGraph.colorBottom = UIColor.clearColor()
		lineGraph.colorPoint = UIColor.clearColor()
		lineGraph.animationGraphEntranceTime = 1.0
		lineGraph.enableBezierCurve = true

		// Feels hacky, but the graph starts animating on viewDidLoad and the data only comes in a second later
		// until that reload fires, I don't want to be showing a drawing line
		lineGraph.colorLine = UIColor.clearColor()

		// TODO: Set the datepicker to the current date if it's past May 1st 2015, nobody is interested in old data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	/**
	Read the data from the local CSV file containing the prognosis for Centrum Galerie
	*/
	func readCSV() {
		let path = NSBundle.mainBundle().pathForResource("forecast", ofType: "csv")
		var filecontent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!

		var error: NSErrorPointer = nil
		if let csv = CSV(fromString: filecontent, error: error) {
			csvData = csv
		}
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

	@IBAction func datePickerValueChanged(sender: UIDatePicker) {

		// The app crashes if the user changes the date before the CSV is fully parsed.
		// This takes about a second... So we'll just ignore the case if there's no csv data yet.
		if csvData == nil {
			return
		}

		var prognosis: Float = 0.0

		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let currentDateString = dateFormatter.stringFromDate(sender.date)

		for row in csvData.rows {
			if let rowDate = row["date"] where rowDate == currentDateString {
				prognosis = (row["percentage"]! as NSString).floatValue / 100
				break
			}
		}

		progressBar.progress = prognosis
		let occupiedString = NSLocalizedString("OCCUPIED", comment: "occupied")
		percentageLabel.text = "\(Int(round(prognosis*100)))% \(occupiedString)"

		let availableSpots = 1050-(1050*prognosis)
		let caString = NSLocalizedString("CIRCA", comment: "ca.")
		let spotsAvailableString = NSLocalizedString("SPOTS_AVAILABLE", comment: "spots available")
		spotsAvailableLabel.text = "\(caString) \(Int(round(availableSpots)))/1050 \(spotsAvailableString)"
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - BEMSimpleLineGraphDataSource
	// /////////////////////////////////////////////////////////////////////////

	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
//		if let csvData = csvData {
//			return csvData.rows.count
//		}
//		return 0
		return thisWeekData.count
	}

	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
//		let row = csvData.rows[index]
//		if let percentage = row["percentage"] {
//			return CGFloat((percentage as NSString).doubleValue)
//		}
//		return 0
		return CGFloat(thisWeekData[index])
	}

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
