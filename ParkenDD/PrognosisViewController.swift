//
//  PrognosisViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class PrognosisViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var spotsAvailableLabel: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var percentageLabel: UILabel!

	var csvData: CSV!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

		// Read the CSV data on another thread
		let csvqueue = dispatch_queue_create("csvqueue", nil)
		dispatch_async(csvqueue, { () -> Void in
			self.readCSV()
		})

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
		let path = NSBundle.mainBundle().pathForResource("Centrum-Galerie-Belegung-Vorhersage-2015", ofType: "csv")
		var filecontent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!

		var error: NSErrorPointer = nil
		if let csv = CSV(fromString: filecontent, error: error) {
			csvData = csv
		}
	}

	@IBAction func datePickerValueChanged(sender: UIDatePicker) {

		// FIXME: The app crashes if the user changes the date before the CSV is fully parsed. 
		// This usually takes about a second... But it still shouldn't be happening.

		var prognosis: Float = 0.0

		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let currentDateString = dateFormatter.stringFromDate(sender.date)

		for row in csvData.rows {
			if let rowDate = row["date"] {
				if rowDate == currentDateString {
					prognosis = (row["percentage"]! as NSString).floatValue / 100
					break
				}
			}
		}

		progressBar.progress = prognosis
		percentageLabel.text = "\(Int(round(prognosis*100)))% occupied"

		let availableSpots = 1050-(1050*prognosis)
		spotsAvailableLabel.text = "ca. \(Int(round(availableSpots)))/1050 spots available"
	}
}
