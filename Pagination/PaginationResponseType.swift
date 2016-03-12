import Foundation
import Himotoki

protocol PaginationResponseType {
    typealias Element: Decodable

    var elements: [Element] { get }
    var hasNextPage: Bool { get }

    init(elements: [Element], hasNextPage: Bool)
}
