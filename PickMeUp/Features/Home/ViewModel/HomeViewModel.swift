import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var state: HomeState
    let router: AppRouter

    init(initialState: HomeState = HomeState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func handleIntent(_ intent: HomeIntent) {
        // intent 처리
    }
} 