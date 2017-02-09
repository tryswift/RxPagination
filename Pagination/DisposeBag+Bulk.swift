import Foundation
import RxSwift

extension DisposeBag {
    func insert(_ disposables: [Disposable]) {
        disposables.forEach(insert)
    }
}
