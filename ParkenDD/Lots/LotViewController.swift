import UIKit
import ParkKit
import FloatingPanel

protocol LotViewControllerDelegate {
    func didSelect(lot: Lot)
}

class LotViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let dataSource = LotDataSource()

    weak var floatingPanel: FloatingPanelController?
    var delegate: LotViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()

        dataSource.didRefresh = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        dataSource.update(for: "Dresden")
    }

    func configureView() {
        self.searchBar.delegate = self

        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: String(describing: LotTableViewCell.self), bundle: .main), forCellReuseIdentifier: String(describing: LotTableViewCell.self))
    }
}

extension LotViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let lot = (tableView.cellForRow(at: indexPath) as? LotTableViewCell)?.lot else { return }
        delegate?.didSelect(lot: lot)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension LotViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        floatingPanel?.move(to: .full, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Filtering for \(searchText)")
    }
}

extension LotViewController: FloatingPanelControllerDelegate {
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
        }
    }
}
