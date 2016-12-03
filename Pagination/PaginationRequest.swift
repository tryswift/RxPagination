import Foundation
import APIKit
import Himotoki

protocol PaginationRequest: Request {
    associatedtype Response: PaginationResponse
    var page: Int { get set }
}

extension PaginationRequest {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let elements = try decodeArray(object, rootKeyPath: "items") as [Response.Element]
        
        let nextURI = urlResponse.findLink(relation: "next")?.uri
        let queryItems = nextURI.flatMap(URLComponents.init)?.queryItems
        let nextPage = queryItems?
            .filter { $0.name == "page" }
            .flatMap { $0.value }
            .flatMap { Int($0) }
            .first

        return Response(elements: elements, page: page, nextPage: nextPage)
    }
}
