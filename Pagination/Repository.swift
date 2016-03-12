import Foundation
import Himotoki

struct Repository: Decodable {
    let id: Int
    let fullName: String
    let stargazersCount: Int

    static func decode(e: Extractor) throws -> Repository {
        return try Repository(
            id:              e <| "id",
            fullName:        e <| "full_name",
            stargazersCount: e <| "stargazers_count"
        )
    }
}
