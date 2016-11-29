import Foundation
import APIKit

protocol PaginationRequest: Request {
    associatedtype Response: PaginationResponse
    var page: Int { get set }
}
