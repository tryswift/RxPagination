import Foundation
import RxSwift
import RxCocoa
import APIKit
import Result
import Action

class PaginationViewModel<Request: PaginationRequestType> {
    let session: Session

    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let elements = Variable<[Request.Response.Element]>([])

    var hasNextPage: Observable<Bool> {
        return action.elements.map { $0.hasNextPage }
    }

    var loading: Observable<Bool> {
        return action.executing
    }

    var error: Observable<ErrorType> {
        return action.errors
            .flatMap { error -> Observable<ErrorType> in
                if case .UnderlyingError(let error) = error {
                    return Observable.of(error)
                } else {
                    return Observable.empty()
                }
        }
    }

    private let action = Action<Request, Request.Response> { Session.rx_response($0) }
    private let disposeBag = DisposeBag()

    init(baseRequest: Request, session: Session = Session.sharedSession) {
        self.session = session

        let refreshRequest = action.executing
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<Request> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable.of(baseRequest.requestWithPage(1))
                }
            }

        let nextPageRequest = Observable
            .combineLatest(action.executing, action.inputs, action.elements) { $0 }
            .sample(loadNextPageTrigger)
            .flatMap { loading, lastRequest, lastResponse -> Observable<Request> in
                if !loading && lastResponse.hasNextPage {
                    return Observable.of(baseRequest.requestWithPage(lastRequest.page + 1))
                } else {
                    return Observable.empty()
                }
            }

        Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .bindTo(action.inputs)
            .addDisposableTo(disposeBag)

        let request = action.inputs
        let result = Observable
            .of(
                action.elements.map { Result<Request.Response, ActionError>.Success($0) },
                action.errors.map { Result<Request.Response, ActionError>.Failure($0) }
            )
            .merge()

        Observable
            .zip(request, result, elements.asObservable()) { request, result, elements in
                if case .Success(let response) = result {
                    return request.page == 1 ? response.elements : elements + response.elements
                } else {
                    return elements
                }
            }
            .bindTo(elements)
            .addDisposableTo(disposeBag)
    }
}
