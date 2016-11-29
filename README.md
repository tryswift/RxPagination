# RxPagination

This is the demo project for my presentation at try! Swift conference 2016.

- Slides: https://speakerdeck.com/ishkawa/protocol-oriented-programming-in-networking
- Video: To be uploaded

## Set Up

- `carthage bootstrap --platform iOS`

## Requirements

- Swift 3.0.1
- Xcode 8.1

## Summary

This demo project illustrates how to use RxSwift, Action and APIKit. The demo app fetches repositories via GitHub search API and displays them using the libraries.

<img src="screenshot.png" width=320>

### ViewModel

`PaginationViewModel<Element>` is a view model for pagination. It has an initializer with type parameter `Request`, which is constrained to conform to `PaginationRequest` protocol. When `PaginationViewModel<Element>` is instantiated via `init<Request>(baseRequest:)`, the type of its property that represents pagination elements will be inferred as `Observable<[Request.Response.Element]>`.

```swift
final class PaginationViewModel<Element: Decodable> {
    let loading: Observable<Bool>
    let elements: Observable<[Element]>

    init<Request: PaginationRequest>(baseRequest: Request) where Request.Response.Element == Element {...}
}
```

### ViewController

Once ViewModel is instantiated with a `Request` type parameter, remained task that ViewController have to do is binding input streams and output streams.


```swift
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
    }
}
```


## Contact

Twitter: https://twitter.com/_ishkawa
