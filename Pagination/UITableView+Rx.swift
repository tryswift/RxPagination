import UIKit
import RxSwift
import RxCocoa

protocol BindableCell {
    associatedtype Value
    func bind(_ value: Value)
}

extension Reactive where Base: UITableView {
    func items<S: Sequence, Cell: UITableViewCell, O: ObservableType>(
        cellIdentifier: String,
        cellType: Cell.Type)
        -> (O)
        -> (Disposable)
        where O.E == S, Cell: BindableCell, Cell.Value == S.Iterator.Element {
        return { source in
            let binder: (Int, Cell.Value, Cell) -> Void = { $2.bind($1) }
            return self.items(cellIdentifier: cellIdentifier, cellType: cellType)(source)(binder)
        }
    }
}
