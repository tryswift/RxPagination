import Foundation
import RxSwift
import RxCocoa
import APIKit

class PaginationViewModel<Request: PaginationRequestType> {
    let baseRequest: Request

    init(baseRequest: Request) {
        self.baseRequest = baseRequest
        self.bindBaseRequest(baseRequest, previousRequest: nil)
    }

    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let hasNextPage = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let elements = Variable<[Request.Response.Element]>([])

    private var disposeBag = DisposeBag()

    private func bindBaseRequest(baseRequest: Request, previousRequest: Request?) {
        disposeBag = DisposeBag()

        let refreshRequest = [
                Observable.never().takeUntil(refreshTrigger),
                Observable.of(baseRequest.requestWithPage(1))
            ]
            .concat()
            .shareReplay(1)

        let nextPageRequest: Observable<Request>

        if let previousPage = previousRequest?.page {
            nextPageRequest = [
                    Observable.never().takeUntil(loadNextPageTrigger),
                    Observable.of(baseRequest.requestWithPage(previousPage + 1))
                ]
                .concat()
                .shareReplay(1)
        } else {
            nextPageRequest = Observable.never()
        }

        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)

        let requestResponse = request
            .flatMap { request in
                return Session
                    .rx_response(request)
                    .map { (request, $0) }
            }
            .shareReplay(1)

        let response = requestResponse.map { $0.1 }

        Observable
            .of(
                Observable.of(true).sample(request),
                Observable.of(false).sample(requestResponse)
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)

        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)

        requestResponse
            .subscribeNext { [weak self] request, response in
                if request.page == 1 {
                    self?.elements.value = response.elements
                } else {
                    self?.elements.value += response.elements
                }

                self?.bindBaseRequest(baseRequest, previousRequest: request)
            }
            .addDisposableTo(disposeBag)
    }
}
