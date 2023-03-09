

import Foundation

struct Repo: Identifiable, Decodable, Equatable{//Listに表示するためIdentifiableな必要がある
    var id: Int//id必須
    var name: String
    var owner: User
    var description: String?
    var stargazersCount: Int
}
