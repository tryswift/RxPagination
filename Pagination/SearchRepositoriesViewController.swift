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

        disposeBag.insert([
            viewModel.indicatorViewAnimating.drive(indicatorView.rx.isAnimating),
            viewModel.elements.drive(tableView.rx.items(cellIdentifier: "Cell", cellType: RepositoryCell.self)),
            viewModel.loadError.drive(onNext: { print($0) }),
        ])
    }
}
