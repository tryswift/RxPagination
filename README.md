# RxPagination

This is the demo project for my presentation at try! Swift conference 2016. 

- Slides: https://speakerdeck.com/ishkawa/protocol-oriented-programming-in-networking
- Video: To be uploaded

## Set Up

- `carthage bootstrap --platform iOS`

## Requirements

- Swift 2.2
- Xcode 7.3

## Summary

When you give a type parameter `Request` to `PaginationViewModel<Request: PaginationRequestType>`, you can get typed response stream `Observable<[Request.Response.Element]>`.

```swift
import UIKit
import RxSwift

class SearchRepositoriesViewController: UITableViewController {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    let disposeBag = DisposeBag()

    // PaginationViewModel<GitHubAPI.SearchRepositoriesRequest>
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

        // viewModel.loading: Variable<Bool>
        viewModel.loading.asDriver()
            .drive(indicatorView.rx_animating)
            .addDisposableTo(disposeBag)

        // viewModel.elements: Variable<[Request.Response.Element]>
        viewModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository, cell in
                // repository: Repository (= Request.Response.Element)
                cell.textLabel?.text = repository.fullName
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
    }
}
```

## Contact

Twitter: https://twitter.com/_ishkawa

