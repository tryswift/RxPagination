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
        let hasNextPage = URLResponse.findLink(relation: "next") != nil

        let elements = try? decodeArray(object, rootKeyPath: "items") as [Response.Element]
        return elements.map { Response(elements: $0, hasNextPage: hasNextPage) }
    }
}
