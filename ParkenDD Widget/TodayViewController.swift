//
//  TodayViewController.swift
//  ParkenDD Widget
//
//  Created by Kilian Költzsch on 27/04/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {

	var lotsToDisplay: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

		self.preferredContentSize = tableView.contentSize

//		lotsToDisplay = NSUserDefaults.standardUserDefaults().objectForKey("favoriteLots") as? [String]
		lotsToDisplay = ["Altmarkt", "An der Frauenkirche", "Haus am Zwinger"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lotsToDisplay!.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("widgetCell") as! WidgetTableViewCell

		cell.lotNameLabel.text = "Altmarktgalerie"
		cell.lotFreeLabel.text = "150"

		return cell
	}
    
}
