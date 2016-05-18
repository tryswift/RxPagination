import Foundation
import RxSwift
import APIKit

extension Session {
    class func rx_response<T: RequestType>(request: T) -> Observable<T.Response> {
        return Session.sharedSession.rx_response(request)
    }

    func rx_response<T: RequestType>(request: T) -> Observable<T.Response> {
        return Observable.create { [weak self] observer in
            let task = self?.sendRequest(request) { result in
                switch result {
                case .Success(let response):
                    observer.on(.Next(response))
                    observer.on(.Completed)

                case .Failure(let error):
                    observer.onError(error)
                }
            }

            return AnonymousDisposable {
                task?.cancel()
            }
        }
    }
}
