import UIKit

class LotViewController: UITableViewController {

    let dataSource = LotDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureTableView()

        dataSource.didRefresh = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        dataSource.update(for: "Dresden")
    }

    func configureView() {
        self.tableView.backgroundColor = .clear
    }

    func configureTableView() {
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: String(describing: LotTableViewCell.self), bundle: .main), forCellReuseIdentifier: String(describing: LotTableViewCell.self))
    }
}

// MARK: - Table View Delegate
extension LotViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
