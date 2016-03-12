import Foundation
import RxSwift
import APIKit

extension Session {
    static func rx_response<T: RequestType>(request: T) -> Observable<T.Response> {
        return Observable.create { observer in
            let task = sendRequest(request) { result in
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
