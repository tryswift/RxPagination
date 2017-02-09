import Foundation
import RxSwift
import RxCocoa
import APIKit
import Action
import Himotoki

class PaginationViewModel<Element: Decodable> {
    let indicatorViewAnimating: Driver<Bool>
    let elements: Driver<[Element]>
    let loadError: Driver<Error>

    private let loadAction: Action<Int, AnyPaginationResponse<Element>>
    private let disposeBag = DisposeBag()

    init<Request: PaginationRequest>(
        baseRequest: Request,
        session: Session = Session.shared,
        viewWillAppear: Driver<Void>,
        scrollViewDidReachBottom: Driver<Void>) where Request.Response.Element == Element {

        loadAction = Action { page in
            var request = baseRequest
            request.page = page

            return session.rx
                .response(request)
                .map(AnyPaginationResponse.init)
        }

        indicatorViewAnimating = loadAction.executing.asDriver(onErrorJustReturn: false)
        elements = loadAction.elements.asDriver(onErrorDriveWith: .empty())
            .scan([]) { $1.page == 1 ? $1.elements : $0 + $1.elements }
            .startWith([])

        loadError = loadAction.errors.asDriver(onErrorDriveWith: .empty())
            .flatMap { error -> Driver<Error> in
                switch error {
                case .underlyingError(let error):
                    return Driver.just(error)
                case .notEnabled:
                    return Driver.empty()
                }
            }

        viewWillAppear.asObservable()
            .map { _ in 1 }
            .subscribe(loadAction.inputs)
            .addDisposableTo(disposeBag)

        scrollViewDidReachBottom.asObservable()
            .withLatestFrom(loadAction.elements)
            .flatMap { $0.nextPage.map { Observable.of($0) } ?? Observable.empty() }
            .subscribe(loadAction.inputs)
            .addDisposableTo(disposeBag)
    }
}
