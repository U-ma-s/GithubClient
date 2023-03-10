
import XCTest
@testable import GithubClient//本来publicで修飾されていなければ外部ターゲットのフィールドにはアクセスできないが，これでinternalなフィールドにもアクセス可能になる

@MainActor
final class RepoListViewModelTests: XCTestCase {

    func test_onAppear_正常系() async {
        let viewModel = ReposListViewModel(
            repoRepository: MockRepoRepository(
                repos: [.mock1, .mock2]
            )
        )
        
        await viewModel.onAppear()//onAppearを実行しその結果を待つ
        switch viewModel.state {
        case let .loaded(repos):
            XCTAssertEqual(repos, [Repo.mock1, Repo.mock2])//作成した処理を通じて取得した"repos"が直接指定したmockと一致しているか検証
        default:
            XCTFail()
        }
    }
    
    func test_onAppear_異常系() async {
        let viewModel = ReposListViewModel(
            repoRepository: MockRepoRepository(
                repos: [],
                error: DummyError()
            )
        )
        
        await viewModel.onAppear()//onAppearを実行しその結果を待つ
        switch viewModel.state {
        case let .failed(error):
            XCTAssert(error is DummyError)//作成した処理を通じて取得した"repos"が直接指定したmockと一致しているか検証
        default:
            XCTFail()
        }
    }

    struct DummyError: Error {}
    
    struct MockRepoRepository: RepoRepository {
        
        let repos: [Repo]
        let error: Error?
        
        init(repos: [Repo], error: Error? = nil) {
            self.repos = repos
            self.error = error
        }
        
        func fetchRepos() async throws -> [Repo] {
            if let error = error {
                throw error
            }else {
                return repos
            }
            
        }
        
    }

}


