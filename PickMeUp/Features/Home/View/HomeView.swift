import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 토큰 정보 표시
            VStack(alignment: .leading, spacing: 4) {
                Text("accessToken: \(UserDefaults.standard.string(forKey: "accessToken") ?? "nil")")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("refreshToken: \(UserDefaults.standard.string(forKey: "refreshToken") ?? "nil")")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding([.top, .horizontal])

            // 상단 위치/검색
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("문래역, 영등포구")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "bell")
                }
                HStack {
                    TextField("검색어를 입력해주세요.", text: $viewModel.state.searchText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.orange)
                }
            }
            .padding()

            // 카테고리
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(["커피", "패스트푸드", "디저트", "베이커리", "more"], id: \.self) { category in
                        VStack {
                            Image(systemName: "circle.fill") // 실제 아이콘으로 교체
                            Text(category)
                                .font(.caption)
                        }
                        .foregroundColor(category == "디저트" ? .orange : .gray)
                    }
                }
                .padding(.horizontal)
            }

            // 실시간 인기 맛집 (예시)
            VStack(alignment: .leading) {
                Text("실시간 인기 맛집")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<2) { _ in
                            VStack(alignment: .leading) {
                                Image("donut") // 실제 이미지로 교체
                                    .resizable()
                                    .frame(width: 120, height: 80)
                                    .cornerRadius(12)
                                Text("새싹 도넛 가게")
                                    .font(.subheadline)
                                HStack {
                                    Text("3.2km")
                                    Text("7PM")
                                    Text("135회")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                            .frame(width: 140)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)

            Spacer()

            // 하단 탭바 (예시)
            HStack {
                Spacer()
                Image(systemName: "house.fill").foregroundColor(.orange)
                Spacer()
                Image(systemName: "heart")
                Spacer()
                Image(systemName: "person")
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }
} 
