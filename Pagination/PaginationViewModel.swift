import Foundation
import RxSwift
import RxCocoa
import APIKit

class PaginationViewModel<Request: PaginationRequestType> {
    let baseRequest: Request

    init(baseRequest: Request) {
        self.baseRequest = baseRequest
        self.bindBaseRequest(baseRequest, nextPage: nil)
    }

    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let hasNextPage = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let elements = Variable<[Request.Response.Element]>([])

    private var disposeBag = DisposeBag()

    private func bindBaseRequest(baseRequest: Request, nextPage: Int?) {
        disposeBag = DisposeBag()

        let refreshRequest = refreshTrigger
            .take(1)
            .map { baseRequest.requestWithPage(1) }

        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { () -> Observable<Request> in
                if let page = nextPage {
                    return Observable.of(baseRequest.requestWithPage(page))
                } else {
                    return Observable.empty()
                }
            }

        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)

        let response = request
            .flatMap { Session.rx_response($0) }
            .shareReplay(1)

        Observable
            .of(
                request.map { _ in true },
                response.map { _ in false }
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)

        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage
                    ? elements + response.elements
                    : response.elements
            }
            .take(1)
            .bindTo(elements)
            .addDisposableTo(disposeBag)

        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)

        response
            .subscribeNext { [weak self] response in
                self?.bindBaseRequest(baseRequest, nextPage: response.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}
