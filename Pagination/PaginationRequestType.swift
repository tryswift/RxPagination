import Foundation
import APIKit

protocol PaginationRequestType: RequestType {
    typealias Response: PaginationResponseType

    var page: Int { get }

    func requestWithPage(page: Int) -> Self
}
