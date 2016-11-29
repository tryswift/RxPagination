import Foundation
import Himotoki

protocol PaginationResponse {
    associatedtype Element: Decodable
    var elements: [Element] { get }
    var nextPage: Int? { get }
    init(elements: [Element], nextPage: Int?)
}

