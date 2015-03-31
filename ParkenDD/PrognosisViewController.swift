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

		// The app crashes if the user changes the date before the CSV is fully parsed.
		// This takes about a second... So we'll just ignore the case if there's no csv data yet.
		if csvData.rows.count == 0 {
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
}
