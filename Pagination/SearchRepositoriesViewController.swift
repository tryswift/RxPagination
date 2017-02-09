import UIKit
import RxSwift

class SearchRepositoriesViewController: UITableViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    private let disposeBag = DisposeBag()
    private var viewModel: PaginationViewModel<Repository>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let baseRequest = GitHubAPI.SearchRepositoriesRequest(query: "Swift")

        viewModel = PaginationViewModel(
            baseRequest: baseRequest,
            viewWillAppear: rx.viewWillAppear.asDriver(),
            scrollViewDidReachBottom: tableView.rx.reachedBottom.asDriver())

        viewModel.indicatorViewAnimating
            .drive(indicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)

        viewModel.elements
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.fullName
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)

        viewModel.loadError
            .drive(onNext: { print($0) })
            .addDisposableTo(disposeBag)
    }
}
