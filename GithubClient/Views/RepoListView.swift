
import SwiftUI
@MainActor//reposをMainスレッドで更新するため
class ReposStore: ObservableObject {//このクラスの特定のプロパティ(repos)を監視する必要がある．
    //クラスにObervableObjectをつけ，監視したいpropertyには"@Published"をつける
    @Published private(set) var repos = [Repo]()//@Publishedでannotateすると、
    //そのpropertyの値の変更をView側から監視できる
    func loadRepos() async {
        
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/vnd.github+json"
        ]
        do {
            let (data, response) = try! await URLSession.shared.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
                
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)
            repos = value
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }
}

struct RepoListView: View {
    @StateObject private var reposStore = ReposStore()
    //@State private var reposStore = ReposStore()
    //@Stateはそのproperty自身に変更が加えられたときにViewの再描画を促す．
    //この場合，reposStoreの内部の状態が変化してもインスタンスが作り替えられるわけではないので更新が走らない．
    var body: some View {
        
        NavigationView {
            if reposStore.repos.isEmpty {
                ProgressView("loading...")
            } else {
                List(reposStore.repos) { repo in
                    NavigationLink(destination: RepoDetailView(repo: repo)) {//detailviewへのLink
                        RepoRow(repo: repo)//Listの表示
                    }
                }
                .navigationTitle("Repositories")
                
            }
        }
        // .onAppear {//viewが表示されたタイミングでリポジトリ一覧を読み込む
        //    Task{//同期関数onAppear()内で非同期関数loadRepos()を呼べない．
        // //「非同期なコンテキスト」を提供するTaskを作成し，Task内でloadRepos()を呼び出す
        .task{
            await reposStore.loadRepos()
        }
    }
    
//    private func loadRepos() async{
////        //load mock data after 1s.
////        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
////        mockRepos = [Repo.mock1, .mock2, .mock3, .mock4, .mock5]
//        try! await Task.sleep(nanoseconds: 1_000_000_000)//1秒spleep
//        mockRepos = [Repo.mock1, .mock2, .mock3, .mock4, .mock5]
//        }
    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}


