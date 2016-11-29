import Foundation
import XCTest
import APIKit
import RxSwift
import RxTest

@testable import Pagination

class PaginationViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    var sessionAdapter: TestSessionAdapter!
    var session: Session!
    var request: GitHubAPI.SearchRepositoriesRequest!
    var viewModel: PaginationViewModel<Repository>!

    override func setUp() {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)

        sessionAdapter = TestSessionAdapter()
        session = Session(adapter: sessionAdapter, callbackQueue: .sessionQueue)

        request = GitHubAPI.SearchRepositoriesRequest(query: "Swift")
        viewModel = PaginationViewModel(baseRequest: request, session: session)
    }

    func test() {
        let loading = scheduler.createObserver(Bool.self)
        viewModel.loading
            .bindTo(loading)
            .addDisposableTo(disposeBag)

        let elementsCount = scheduler.createObserver(Int.self)
        viewModel.elements
            .map { $0.count }
            .bindTo(elementsCount)
            .addDisposableTo(disposeBag)

        scheduler.scheduleAt(10) { self.viewModel.refreshTrigger.onNext() }
        scheduler.scheduleAt(20) { self.sessionAdapter.return(data: Fixture.SearchRepositories.data) }
        scheduler.start()

        XCTAssertEqual(loading.events, [
            next(0, false),
            next(10, true),
            next(20, false),
        ])

        XCTAssertEqual(elementsCount.events, [
            next(0, 0),
            next(20, 30),
        ])
    }
}
