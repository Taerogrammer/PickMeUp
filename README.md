# 🧁 픽미업 (PickMeUp)  
> 위치 기반 디저트 픽업 예약 서비스 🍰📍

`픽미업`은 내 주변 디저트 매장을 탐색하고, 간편 결제를 통해 픽업까지 완료할 수 있는 iOS 앱입니다.

PG 연동 결제, 실시간 채팅, 지도 기반 매장 탐색 등 실제 서비스에 필요한 핵심 기능을 구현하여, 매장 탐색부터 주문, 결제, 픽업까지의 전 과정을 구현했습니다.

<br><br>

## 📺 스크린샷 (Screenshots)

| 매장 탐색 | 상품 상세 | 주문 및 결제 | 실시간 채팅 |
|:--:|:--:|:--:|:--:|
| <img src="https://github.com/user-attachments/assets/8de714c4-7edd-4550-be2d-7888b8e6b875" width="300" /> | <img src="https://github.com/user-attachments/assets/22f100be-90b2-4343-afc4-04689b040fda" width="300" /> | <img src="https://github.com/user-attachments/assets/4d3b7e08-bbc1-4907-950a-7adf1192d020" width="300" /> | <img src="https://github.com/user-attachments/assets/4cac3016-f90b-43d6-89f7-a65c025bc486" width="300" /> |

<br>

### 위치 기반 매장 탐색  
사용자가 설정한 주소를 기준으로 주변 디저트 매장을 탐색할 수 있습니다.  
네이버 지도 API를 활용하여 직관적인 지도 UI와 함께, 지오코딩/리버스 지오코딩 기능을 통해 정확한 위치 기반 서비스를 제공합니다.

### 매장 상세 정보 및 상품 선택  
매장의 위치, 운영시간, 리뷰 등 핵심 정보를 제공하며, 판매 중인 디저트 상품들을 리스트로 확인하고 선택할 수 있습니다.  
고해상도 이미지는 다운샘플링 및 캐시 전략을 통해 메모리 효율적으로 처리됩니다.

### 간편 주문 및 결제  
선택한 상품은 장바구니에 담아 주문할 수 있으며, `iamport iOS SDK`를 통해 다양한 결제 수단을 지원합니다.  
결제 후 서버 기반 영수증 검증을 통해 보안성과 신뢰성을 강화했습니다.

### 실시간 채팅  
`Socket.IO` 기반 실시간 채팅을 통해 다른 사용자와 직접 소통할 수 있으며, 채팅 내역은 `CoreData`에 저장되어 오프라인에서도 조회할 수 있습니다.

<br><br>

## ✨ 주요 기능 (Features)

| 기능명 | 설명 |
|---|---|
| 🍰 **위치 기반 디저트 탐색** | 설정한 주소 주변의 디저트 매장을 지도 기반으로 탐색 |
| 🔐 **회원 가입 및 소셜 로그인** | 이메일, 카카오, 애플 로그인을 통한 통합 인증 지원 |
| 🏪 **매장 상세 정보 확인** | 위치, 운영시간, 리뷰 등 매장 정보 제공 |
| 💳 **간편 주문 및 결제** | PG 연동을 통한 카드, 간편결제 등 다양한 결제 수단 지원 |
| 💬 **실시간 채팅 기능** | Socket.IO 기반으로 매장과 실시간 소통 가능 |
| 📍 **지도 기반 주소 설정** | 네이버 지도 API 기반 위치 지정 UI 제공 |

<br><br>

## 🛠️ 아키텍처 & 디자인 패턴 (Architecture & Design Pattern)

<img src="https://github.com/user-attachments/assets/aa746aae-3991-40b6-8ae2-c52f130d1e95" width="1000" />

<br>

- **`MVI(Model-View-Intent)`** 기반 아키텍처를 적용하여 단방향 데이터 흐름을 구성  
- 모든 유저 인터랙션을 `Action(Intent)`으로 정의하여 상태 변화가 명확하고 예측 가능하게 구성  
- **`Feature 단위 모듈화`**를 통해 State, Action, Reducer, Effect 등을 독립적으로 관리하고 결합도 최소화  
- **`의존성 주입(DI`)** 및 **`SOLID 원칙`** 기반 설계  
- **`Router Pattern`**을 적용해 화면 전환과 객체 생성을 분리하여 구조적 유연성 확보  

<br><br>

## ⚙️ 주요 설계 및 구현

---

### 단방향 아키텍처 기반 상태 관리 최적화  
- MVI 패턴을 통해 `View → Intent → Effect → Result → State → View`의 데이터 흐름 구성  
- `Intent`와 `Result`를 명확히 분리하여 복잡한 상태 관리를 단순화  
- 사이드 이펙트(결제, 채팅 등)는 Effect로 독립 관리

---

### Swift Concurrency 기반 비동기 처리  
- `async/await`, `Task`, `@MainActor`를 통해 명확하고 안전한 비동기 로직 구성  
- UI 작업에 대해 메인 스레드 안전성을 확보하고, 중첩 없는 가독성 높은 비동기 처리 구현

---

### 네트워크 최적화 및 캐싱 전략  
- `Wi-Fi / Cellular` 환경에 따라 `httpMaximumConnectionsPerHost` 동적 조정  
- NSCache + FileManager 기반의 **2단계 이미지 캐싱 시스템** 구성  
- `ETag` 기반의 조건부 요청으로 불필요한 이미지 다운로드 방지

---

### 고성능 이미지 처리 및 메모리 관리  
- DownSampling 적용으로 고해상도 이미지의 메모리 사용량 최소화  
- **LRU 캐시 알고리즘**을 직접 구현해 빠른 접근과 제거 성능 확보  
- 전체 메모리 사용량의 25%를 상한선으로 설정하여 안정성 확보

---

### 실시간 통신 및 로컬 데이터 동기화  
- `Socket.IO` 기반 실시간 채팅 시스템 구현  
- `CoreData`를 통해 채팅 내역을 로컬에 저장하여 서버 부하 감소 및 오프라인 접근 가능  
- 메시지 ID 기반 중복 방지 처리로 데이터 정합성 보장

---

### 사용자 경험 및 UI 성능 개선  
- Optimistic UI를 적용해 서버 응답 없이도 즉각적인 사용자 피드백 제공  
- 실패 시 자동 롤백으로 안정성 확보  
- SwiftUI의 `Equatable` 기반 렌더링 최적화  
- 지도 이동 시 디바운싱 대신 `카메라 정지 시점` 기반으로 API 호출하여 응답 성능 개선

---

### 보안 및 인증 처리  
- Access / Refresh Token 기반 로그인 시스템 구성 → 자동 로그인 + 토큰 갱신 처리  
- 결제 시 서버 기반 영수증 검증으로 위변조 방지  
- 최소 권한 요청 전략 적용 → 위치 권한은 앱 활성화 중에만 요청

<br><br>

## 🗓️ 프로젝트 정보

- **개발 기간:** 2025.05 ~ (진행 중)  
- **개발 인원:** 2명 (iOS 1명, 백엔드 1명 협업)  
- **타겟 플랫폼:** iOS 17 이상  

<br><br>

## 🧰 Frameworks & Libraries

| 구분 | 기술 |
|---|---|
| **UI** | SwiftUI |
| **Asynchronous** | Swift Concurrency (async/await), Combine |
| **Network** | URLSession, Socket.IO |
| **Database** | CoreData |
| **Map** | Naver Map API |
| **Payment** | iamport iOS SDK |
| **Security** | Keychain |
| **Caching** | NSCache, FileManager |
