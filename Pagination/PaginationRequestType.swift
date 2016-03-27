import Foundation
import APIKit

protocol PaginationRequestType: RequestType {
    associatedtype Response: PaginationResponseType

    var page: Int { get }

    func requestWithPage(page: Int) -> Self
}
