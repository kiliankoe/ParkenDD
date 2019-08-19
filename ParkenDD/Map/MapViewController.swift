import UIKit
import MapKit
import Pulley

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()


    }
}

extension MapViewController: PulleyPrimaryContentControllerDelegate {

}
