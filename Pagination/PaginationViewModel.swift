import Foundation
import RxSwift
import RxCocoa
import APIKit

class PaginationViewModel<Request: PaginationRequestType> {
    let session: Session

    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()

    let hasNextPage = Variable<Bool>(false)
    let loading = Variable<Bool>(false)
    let elements = Variable<[Request.Response.Element]>([])
    let lastLoadedPage = Variable<Int?>(nil)

    let error = PublishSubject<ErrorType>()

    private let disposeBag = DisposeBag()

    init(baseRequest: Request, session: Session = Session.sharedSession) {
        self.session = session

        let refreshRequest = loading.asObservable()
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<Request> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable.of(baseRequest.requestWithPage(1))
                }
            }

        let nextPageRequest = Observable
            .combineLatest(loading.asObservable(), hasNextPage.asObservable(), lastLoadedPage.asObservable()) { $0 }
            .sample(loadNextPageTrigger)
            .flatMap { loading, hasNextPage, lastLoadedPage -> Observable<Request> in
                if let page = lastLoadedPage where !loading && hasNextPage {
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
            .flatMap { [weak self] request in
                return session
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

        Observable
            .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return request.page == 1 ? response.elements : elements + response.elements
            }
            .sample(response)
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
