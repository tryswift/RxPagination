import Foundation
import RxSwift
import RxCocoa
import APIKit

class PaginationViewModel<Request: PaginationRequestType> {
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let hasNextPage = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let elements = Variable<[Request.Response.Element]>([])
    let lastLoadedPage = Variable<Int?>(nil)

    let error = PublishSubject<ErrorType>()

    private let disposeBag = DisposeBag()

    init(baseRequest: Request) {
        let refreshRequest = refreshTrigger
            .withLatestFrom(loading.asObservable())
            .filter { !$0 }
            .map { _ in baseRequest.requestWithPage(1) }

        let nextPageRequest = loadNextPageTrigger
            .withLatestFrom(loading.asObservable())
            .filter { !$0 }
            .withLatestFrom(hasNextPage.asObservable())
            .filter { $0 }
            .withLatestFrom(lastLoadedPage.asObservable())
            .flatMap { lastLoadedPage -> Observable<Request> in
                if let page = lastLoadedPage {
                    return Observable.of(baseRequest.requestWithPage(page + 1))
                } else {
                    return Observable.empty()
                }
            }

        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .shareReplay(1)

        let response = request
            .flatMap { request in
                return Session
                    .rx_response(request)
                    .doOnError { [weak self] error in
                        self?.error.onNext(error)
                    }
                    .catchError { _ in Observable.empty() }
            }
            .shareReplay(1)

        Observable
            .of(
                request.map { _ in true },
                response.map { _ in false },
                error.map { _ in false }
            )
            .merge()
            .bindTo(loading)
            .addDisposableTo(disposeBag)

        response
            .withLatestFrom(request) { $0 }
            .withLatestFrom(elements.asObservable()) { requestResponse, elements in
                let request = requestResponse.1
                let response = requestResponse.0
                return request.page == 1 ? response.elements : elements + response.elements
            }
            .bindTo(elements)
            .addDisposableTo(disposeBag)

        response
            .withLatestFrom(request) { $1.page }
            .bindTo(lastLoadedPage)
            .addDisposableTo(disposeBag)

        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)
    }
}
