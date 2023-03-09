
import Foundation

struct RepoAPIClient {
    func getRepos() async throws -> [Repo]{// func hoge() async throws -> fuga でエラーをスローするasync(非同期)関数を示す
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = ["Accept": "application/vnd.github+json"]
        let (data, response) = try await URLSession.shared.data(for: urlRequest)//URLSessionを開始し，終了を待つ(await)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return  try decoder.decode([Repo].self, from: data)
    }
}
