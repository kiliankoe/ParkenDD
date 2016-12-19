//
//  ForecastChartDataSource.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 19/12/2016.
//  Copyright © 2016 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import ResearchKit

class ForecastViewDataSource: NSObject, ORKGraphChartViewDataSource {
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return 0
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        return ORKRangedPoint()
    }
}
