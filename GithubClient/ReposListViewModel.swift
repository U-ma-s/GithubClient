
import Foundation

class ReposListViewModel: ObservableObject {
    
    @Published private(set) var state:Stateful<[Repo]> = .idel
    
    func onAppear() async {
        await loadRepos()
    }
    
    func onRetryButtonTapped() async {
        await loadRepos()
    }
    
     private func loadRepos() async {
         state = .loading
         do {
             let value = try await RepoRepository().fetchRepos()//非同期関数fetchRepos()を呼び出すため，awaitをつけて中断可能性を伝える．
             state = .loaded(value)
         } catch {
             state = .failed(error)
         }
    }
    
    
}

