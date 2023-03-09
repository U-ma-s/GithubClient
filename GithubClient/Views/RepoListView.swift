
import SwiftUI

@MainActor//reposをMainスレッドで更新するため
class ReposStore: ObservableObject {//このクラスの特定のプロパティ(repos)を監視する必要がある．
    //クラスにObervableObjectをつけ，監視したいpropertyには"@Published"をつける
    //    @Published private(set) var repos = [Repo]()//@Publishedで,そのpropertyの値の変更をView側から監視できる
    //    @Published private(set) var error: Error? = nil
    //    @Published private(set) var isLoading: Bool = false
    
    @Published private(set) var state: Stateful<[Repo]> = .idel
    
    func loadRepos() async {//非同期関数
        
        let url = URL(string: "https://api.github.com/orgs/mixigroup/repos")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = ["Accept": "application/vnd.github+json"]
        state = .loading
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)//URLSessionを開始し，終了を待つ(await)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            //throw URLError(.badServerResponse)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode([Repo].self, from: data)
            state = .loaded(value)
        } catch {
            state = .failed(error)
        }
    }
}

struct RepoListView: View {
    @StateObject private var reposStore = ReposStore()
    
    init() {
        _reposStore = StateObject(wrappedValue: ReposStore())
    }
    //@State private var reposStore = ReposStore()
    //@Stateはそのproperty自身に変更が加えられたときにViewの再描画を促す．
    //この場合，reposStoreの内部の状態が変化してもインスタンスが作り替えられるわけではないので更新が走らない．
    var body: some View {
        NavigationView {
            Group {
                switch reposStore.state {
                case .idel, .loading:
                    ProgressView("loading...")
                case .loaded([]):
                    Text("No Repositories")
                case .loaded(let repos):
                    List(repos) { repo in
                        NavigationLink(destination: RepoDetailView(repo: repo)) {//detailviewへのLink
                            RepoRow(repo: repo)//Listの表示
                        }
                    }
                    
                case .failed:
                    VStack {
                        Group {
                            Image("GitHubMark")
                                .resizable()
                                .frame(width: 100, height: 100)
                            Text("Failed to load repositories")
                                .padding(.top, 4)
                        }
                        .foregroundColor(.black)
                        .opacity(0.6)
                        .padding(.bottom, 2)
                        Button(
                            action: {
                                Task{
                                    await reposStore.loadRepos()
                                }
                            },
                            label:{
                                Text("Retry")
                                    .fontWeight(.bold)
                            }
                        )
                        .padding(.top, 6)
                    }
                }
            }
            .navigationTitle("Repositories")
        }
        // .onAppear {//viewが表示されたタイミングでリポジトリ一覧を読み込む
        //    Task{//同期関数onAppear()内で非同期関数loadRepos()を呼べない．
        // //「非同期なコンテキスト」を提供するTaskを作成し，Task内でloadRepos()を呼び出す
        .task{
            await reposStore.loadRepos()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepoListView()
    }
}


