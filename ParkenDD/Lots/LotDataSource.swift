import UIKit
import ParkKit

class LotDataSource: NSObject {
    let parkApi = ParkKit()

    var selectedCity: String? {
        didSet {
            guard let selectedCity = selectedCity else { return }
            self.update(for: selectedCity)
        }
    }

    var didRefresh: (() -> Void)?

    var lots: [Lot] = []
    var lastUpdated: Date?
    var lastDownloaded: Date?

    func update(for city: String) {
        parkApi.lots(forCity: city) { [weak self] result in
            switch result {
            case .failure(let error):
                // TODO: Handle error
                print(error)
                break
            case .success(let response):
                self?.lots = response.lots
                self?.lastUpdated = response.lastUpdated
                self?.lastDownloaded = response.lastDownloaded
                self?.didRefresh?()
            }
        }
    }
}

extension LotDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.lots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LotTableViewCell.self), for: indexPath) as! LotTableViewCell
        cell.lot = lots[indexPath.row]
        return cell
    }
}
