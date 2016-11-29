import Foundation
import APIKit
import Himotoki
import WebLinking

protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

extension GitHubRequest where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}

extension GitHubRequest where Response: PaginationResponse {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        let elements = try decodeArray(object, rootKeyPath: "items") as [Response.Element]
        
        let nextURI = urlResponse.findLink(relation: "next")?.uri
        let queryItems = nextURI.flatMap(URLComponents.init)?.queryItems
        let nextPage = queryItems?
            .filter { $0.name == "page" }
            .flatMap { $0.value }
            .flatMap { Int($0) }
            .first

        return Response(elements: elements, nextPage: nextPage)
    }
}
