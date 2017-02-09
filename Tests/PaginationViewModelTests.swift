import Foundation
import XCTest
import APIKit
import RxSwift
import RxCocoa
import RxTest

@testable import Pagination

class PaginationViewModelTests: XCTestCase {
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!

    var sessionAdapter: TestSessionAdapter!
    var viewModel: PaginationViewModel<Repository>!

    let viewWillAppear = PublishSubject<Void>()
    let scrollViewDidScroll = PublishSubject<Void>()

    override func setUp() {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)

        driveOnScheduler(scheduler) {
            sessionAdapter = TestSessionAdapter()
            
            let session = Session(adapter: sessionAdapter, callbackQueue: .sessionQueue)
            let request = GitHubAPI.SearchRepositoriesRequest(query: "Swift")

            viewModel = PaginationViewModel(
                baseRequest: request,
                session: session,
                viewWillAppear: viewWillAppear.asDriver(onErrorDriveWith: .empty()),
                scrollViewDidReachBottom: scrollViewDidScroll.asDriver(onErrorDriveWith: .empty()))
        }
    }

    func test() {
        driveOnScheduler(scheduler) {
            let indicatorViewAnimating = scheduler.createObserver(Bool.self)
            let elementsCount = scheduler.createObserver(Int.self)

            let disposables = [
                viewModel.indicatorViewAnimating.drive(indicatorViewAnimating),
                viewModel.elements.map({ $0.count }).drive(elementsCount),
            ]

            scheduler.scheduleAt(10) { self.viewWillAppear.onNext() }
            scheduler.scheduleAt(20) { self.sessionAdapter.return(data: Fixture.SearchRepositories.data) }
            scheduler.scheduleAt(30) { disposables.forEach { $0.dispose() } }
            scheduler.start()

            XCTAssertEqual(indicatorViewAnimating.events, [
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
}
