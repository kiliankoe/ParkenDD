import UIKit
import MapKit
import FloatingPanel

class MapViewController: UIViewController {

    private var floatingPanel: FloatingPanelController!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        floatingPanel = FloatingPanelController()
        floatingPanel.delegate = self
        let lotVC = LotsViewController()
        lotVC.floatingPanel = floatingPanel
        floatingPanel.set(contentViewController: lotVC)
        floatingPanel.track(scrollView: lotVC.tableView)
        floatingPanel.addPanel(toParent: self)

        floatingPanel.view.backgroundColor = .clear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        floatingPanel.removePanelFromParent(animated: animated)
    }
}

extension MapViewController: FloatingPanelControllerDelegate {

}
