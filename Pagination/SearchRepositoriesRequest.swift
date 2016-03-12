import Foundation
import APIKit

extension GitHubAPI {
    struct SearchRepositoriesRequest: GitHubRequestType, PaginationRequestType {
        let query: String
        let page: Int

        init(query: String, page: Int = 1) {
            self.query = query
            self.page = page
        }

        // MARK: RequestType
        typealias Response = PaginationResponse<Repository>

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/search/repositories"
        }

        var parameters: [String: AnyObject] {
            return ["q": query, "page": page]
        }

        // MARK: PaginationRequestType
        func requestWithPage(page: Int) -> SearchRepositoriesRequest {
            return SearchRepositoriesRequest(query: query, page: page)
        }
    }
}
