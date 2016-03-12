import UIKit
import RxSwift

class SearchRepositoriesViewController: UITableViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    let disposeBag = DisposeBag()
    let viewModel = PaginationViewModel(
        baseRequest: GitHubAPI.SearchRepositoriesRequest(query: "Swift"))

    override func viewDidLoad() {
        super.viewDidLoad()

        rx_sentMessage("viewWillAppear:")
            .map { _ in () }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading.asDriver()
            .drive(indicatorView.rx_animating)
            .addDisposableTo(disposeBag)

        viewModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.fullName
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
    }
}
