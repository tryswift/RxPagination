import Foundation
import Himotoki

protocol PaginationResponseType {
    associatedtype Element: Decodable

    var elements: [Element] { get }

    var previousPage: Int? { get }
    var nextPage: Int? { get }

    init(elements: [Element], previousPage: Int?, nextPage: Int?)
}

extension PaginationResponseType {
    var hasPreviousPage: Bool {
        return previousPage != nil
    }

    var hasNextPage: Bool {
        return nextPage != nil
    }
}
