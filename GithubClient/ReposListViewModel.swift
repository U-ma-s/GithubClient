
import Foundation
@MainActor
class ReposListViewModel: ObservableObject {
    
    @Published private(set) var state:Stateful<[Repo]> = .idel
    
    private let repoRepository: RepoRepository//RepoRepositoryのI/Fを抽象化したprotocolをイニシャライザ引数とする
    init(repoRepository: RepoRepository = RepoDataRepository()) {//RepoRepositoryプロトコルに準拠したRepoDataRepository型のプロパティrepoRepositoryを初期化
        self.repoRepository = repoRepository
    }
    
    func onAppear() async {
        await loadRepos()
    }
    
    func onRetryButtonTapped() async {
        await loadRepos()
    }
    
     private func loadRepos() async {
         state = .loading
         do {
             let value = try await repoRepository.fetchRepos()//非同期関数fetchRepos()を呼び出すため，awaitをつけて中断可能性を伝える．
             state = .loaded(value)
         } catch {
             state = .failed(error)
         }
    }
    
    
}

