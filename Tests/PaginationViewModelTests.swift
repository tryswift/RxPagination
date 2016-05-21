import Foundation
import XCTest
import APIKit
import RxSwift
import RxTests

@testable import Pagination

class PaginationViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    var sessionAdapter: TestSessionAdapter!
    var session: Session!
    var request: GitHubAPI.SearchRepositoriesRequest!
    var viewModel: PaginationViewModel<GitHubAPI.SearchRepositoriesRequest>!

    override func setUp() {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)

        sessionAdapter = TestSessionAdapter()
        session = Session(adapter: sessionAdapter, callbackQueue: .SessionQueue)

        request = GitHubAPI.SearchRepositoriesRequest(query: "Swift")
        viewModel = PaginationViewModel(baseRequest: request, session: session)
    }

    func testAAA() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String)

        scheduler.scheduleAt(100) { observer.onNext("abc") }
        scheduler.scheduleAt(150) { observer.onNext("def") }
        scheduler.scheduleAt(200) { observer.onNext("ghi") }
        scheduler.start()

        XCTAssertEqual(observer.events, [
            next(100, "abc"),
            next(150, "def"),
            next(200, "ghi"),
        ])
    }

    func test() {
        let loading = scheduler.createObserver(Bool)
        viewModel.loading.asDriver()
            .drive(loading)
            .addDisposableTo(disposeBag)

        let elementsCount = scheduler.createObserver(Int)
        viewModel.elements.asDriver()
            .map { $0.count }
            .drive(elementsCount)
            .addDisposableTo(disposeBag)

        scheduler.scheduleAt(100) { self.viewModel.refreshTrigger.onNext() }
        scheduler.scheduleAt(150) { self.sessionAdapter.returnData(Fixture.SearchRepositories.data) }
        scheduler.start()

        XCTAssertEqual(loading.events, [
            next(  0, false),
            next(100, true),
            next(150, false),
        ])

        XCTAssertEqual(elementsCount.events, [
            next(  0, 0),
            next(150, 30),
        ])
    }
}
