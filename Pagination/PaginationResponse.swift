import Foundation
import Himotoki

struct PaginationResponse<E: Decodable>: PaginationResponseType {
    typealias Element = E

    let elements: [Element]

    let previousPage: Int?
    let nextPage: Int?
}
