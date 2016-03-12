import UIKit
import RxSwift

extension UIScrollView {
    var rx_reachedBottom: Observable<Void> {
        return rx_contentOffset
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }

                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)

                return y > threshold ? Observable.just() : Observable.empty()
            }
    }
}
