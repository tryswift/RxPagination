import Foundation
import RxSwift
import APIKit
import Action
import Himotoki

class PaginationViewModel<Element: Decodable> {
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let loading: Observable<Bool>
    let elements: Observable<[Element]>
    let error: Observable<Error>

    private let action: Action<Int, AnyPaginationResponse<Element>>
    private let disposeBag = DisposeBag()

    init<Request: PaginationRequest>(baseRequest: Request, session: Session = Session.shared) where Request.Response.Element == Element {
        action = Action { page in
            var request = baseRequest
            request.page = page

            return session.rx
                .response(request)
                .map(AnyPaginationResponse.init)
        }

        loading = action.executing
        elements = action.elements
            .scan([]) { $1.page == 1 ? $1.elements : $0 + $1.elements }
            .startWith([])

        error = action.errors
            .flatMap { error -> Observable<Error> in
                switch error {
                case .underlyingError(let error):
                    return Observable.of(error)
                case .notEnabled:
                    return Observable.empty()
                }
            }

        refreshTrigger
            .map { _ in 1 }
            .bindTo(action.inputs)
            .addDisposableTo(disposeBag)

        loadNextPageTrigger
            .withLatestFrom(action.elements)
            .flatMap { $0.nextPage.map { Observable.of($0) } ?? Observable.empty() }
            .bindTo(action.inputs)
            .addDisposableTo(disposeBag)
    }
}
