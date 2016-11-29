import UIKit
import RxSwift

class SearchRepositoriesViewController: UITableViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    let disposeBag = DisposeBag()
    let viewModel = PaginationViewModel(baseRequest:
        GitHubAPI.SearchRepositoriesRequest(query: "Swift"))

    override func viewDidLoad() {
        super.viewDidLoad()

        rx.sentMessage(#selector(viewWillAppear))
            .map { _ in }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        tableView.rx.reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading
            .bindTo(indicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)

        viewModel.elements
            .bindTo(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.fullName
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)

        viewModel.error
            .subscribe { print($0) }
            .addDisposableTo(disposeBag)
    }
}
