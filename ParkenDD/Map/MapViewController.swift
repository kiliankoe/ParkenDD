import UIKit
import MapKit

import ParkKit
import FloatingPanel

class MapViewController: UIViewController {

    private var floatingPanel: FloatingPanelController!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        // Map View
        mapView.showsTraffic = true
        mapView.showsUserLocation = true

        // Floating Panel
        floatingPanel = FloatingPanelController()
        let lotVC = LotViewController()
        floatingPanel.delegate = lotVC
        lotVC.floatingPanel = floatingPanel
        lotVC.delegate = self
        floatingPanel.set(contentViewController: lotVC)
        floatingPanel.track(scrollView: lotVC.tableView)
        floatingPanel.addPanel(toParent: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        floatingPanel.removePanelFromParent(animated: animated)
    }
}

extension MapViewController: LotViewControllerDelegate {
    func didSelect(lot: Lot) {
        guard let coordinate = lot.coordinate?.coordinate2D else { return }
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 2_000)
        self.mapView.setCamera(camera, animated: true)
    }
}
