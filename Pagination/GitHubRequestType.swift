import Foundation
import APIKit
import Himotoki
import WebLinking

protocol GitHubRequestType: RequestType {

}

extension GitHubRequestType {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

extension GitHubRequestType where Response: Decodable, Response.DecodedType == Response {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        return try? decode(object)
    }
}

extension GitHubRequestType where Response: PaginationResponseType, Response.Element.DecodedType == Response.Element {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        var previousPage: Int?
        if let previousURI = URLResponse.findLink(relation: "prev")?.uri,
           let queryItems = NSURLComponents(string: previousURI)?.queryItems {
            previousPage = queryItems
                .filter { $0.name == "page" }
                .first
                .flatMap { $0.value }
                .flatMap { Int($0) }
        }

        var nextPage: Int?
        if let nextURI = URLResponse.findLink(relation: "next")?.uri,
           let queryItems = NSURLComponents(string: nextURI)?.queryItems {
            nextPage = queryItems
                .filter { $0.name == "page" }
                .first
                .flatMap { $0.value }
                .flatMap { Int($0) }
        }

        let elements = try? decodeArray(object, rootKeyPath: "items") as [Response.Element]

        return elements.map { Response(elements: $0, previousPage: previousPage, nextPage: nextPage) }
    }
}
