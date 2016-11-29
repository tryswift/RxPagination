import Foundation
import Himotoki

struct SearchResponse<Element: Decodable>: PaginationResponse {
    let elements: [Element]
    let nextPage: Int?
}
