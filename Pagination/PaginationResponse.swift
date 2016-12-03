import Foundation
import Himotoki

struct SearchResponse<Element: Decodable>: PaginationResponse {
    let elements: [Element]
    let page: Int
    let nextPage: Int?
}
