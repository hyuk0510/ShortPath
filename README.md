# <img width="32" height="32" alt="image" src="https://github.com/user-attachments/assets/1e4102a7-b458-4c90-85b3-0062623bb676" /> Routee
### UIKit, KakaoMapsSDK, Realm 기반의 지도 경로 탐색 및 저장 iOS 앱

[앱스토어 링크](https://apps.apple.com/kr/app/routee/id6766235481)
<br>

<img width="300" alt="Image" src="https://github.com/user-attachments/assets/ca4c1be2-632b-4f67-be96-59f17efaed01" />
<img width="300" alt="Image" src="https://github.com/user-attachments/assets/de37e733-7751-48e9-969b-743e4def34a9" />
<img width="300" alt="Image" src="https://github.com/user-attachments/assets/2d731284-f1c2-4a6a-a030-d33e26d047ea" />
<img width="300" alt="Image" src="https://github.com/user-attachments/assets/668fee28-cb06-49c3-a78c-24b16d28e0a0" />
<img width="300" alt="Image" src="https://github.com/user-attachments/assets/fdeaab01-ade6-4ff0-bdbc-4f79a2fbe3bb" />
<img width="300" alt="Image" src="https://github.com/user-attachments/assets/7bac637d-c1cb-475a-aaf6-5edf7e723532" />

## 🛠️ Tech Stack

| Category | Tech |
|---|---|
| Language | Swift |
| UI | UIKit, SnapKit |
| Map | KakaoMapsSDK (SPM) |
| DataBase | RealmSwift |
| Networking | URLSession + Codable (Kakao Local API) |
| Concurrency | async/await, GCD, MainActor |
| Min Deployment | iOS 16+ |
---
<br>

## ✨ Features

- KakaoMapsSDK 기반 지도 경로 탐색 및 시각화

- Kakao Local API 기반 장소 검색, Kakao Mobility API 기반 다중 경유지 경로 계산
  
- 출발지 / 경유지 / 도착지 drag-to-reorder 및 역할 자동 재할당
  
- Realm 기반 즐겨찾기, 최근 검색, 최근 경로 로컬 저장
  
- 4단계 snap state(hidden / tip / medium / max)를 가진 Custom BottomSheet 현재 위치 기반 탐색 및 reverse geocoding 캐싱

---
<br>

## 🏗️ Architecture

이 프로젝트는 **MVC + Repository + Delegate** 구조를 기반으로 구성했습니다.  

중앙 컨테이너 역할을 하는 `RootContainerViewController`가 지도, BottomSheet, overlay view를 관리하고, 각 화면 간의 이벤트는 protocol 기반 delegate로 전달합니다.

```txt

RootContainerViewController
├── MapViewController            ← KakaoMapsSDK 렌더링, 위치, POI/경로 표시
│   └── 9 extensions            ← Auth, Layout, POI, Route, EventHandler,
│                                   LocationManager, UI, LifeCycle, Observers...
├── BottomSheetView              ← Gesture 기반 container (4 snap states)
│   ├── HomeTabViewController
│   ├── FavoriteTabViewController
│   └── SettingView (SwiftUI UIHostingController)
├── RootViewModel                ← Sheet state 관리 (home / placeDetail / routing)
└── RoutingViewModel             ← 경로 지점 및 closure 기반 상태 전달
```
<br>

## State Binding

### BottomSheet State
  
BottomSheet의 Y 위치는 (Mode, SheetMode) 조합으로 결정됩니다.
같은 snap 단계라도 현재 화면 상태에 따라 다른 위치로 이동합니다.

```swift
static let bottomSheetRatio: (Mode, SheetMode) -> Double = { mode, sheetMode in
      switch (mode, sheetMode) {
      case (.tip, .home):            return 0.9
      case (.tip, .placeDetail):     return 0.7
      case (.hidden, _):             return 1.0
      // ...
      }
  }
```

State binding은 Combine이나 RxSwift 대신  

가벼운 `didSet` + closure callback 기반으로 구현했습니다.

```swift

private(set) var items: [RouteSectionItem] = [] {

    didSet { onChange?() }

}

var onChange: (() -> Void)?
```

### Repository Pattern
  
Realm CRUD를 Protocol로 추상화해 각 데이터 타입별 Repository를 분리했습니다.
  
// 즐겨찾기 장소, 즐겨찾기 경로, 최근 장소, 최근 경로(현재위치 출발 / 출발지도 지정)
<br>
FavoriteRepository<br>
FavoriteRouteRepository<br>
RecentPlaceRepository<br>
CurrentLocationRecentRouteRepository(현재위치 출발)<br>
PresetRecentRouteRepository(출발지도 지정)<br>
<br>

## 🧯 Troubleshooting

### 지도 Gesture와 BottomSheet 충돌

충돌 1 — 지도 pan과 BottomSheet 동시 활성화

문제

지도를 드래그할 때 KakaoMap의 pan gesture와 BottomSheet의
UIPanGestureRecognizer가 동시에 활성화되어, 지도를 움직이면 시트도 함께
반응하는 현상이 발생했습니다.

해결

KakaoMapEventDelegate의 cameraWillMove(by: .pan) / kakaoMapDidTapped가
호출되면, MapInteractionDelegate를 통해 RootContainerViewController로 이벤트를
전달하고, BottomSheet를 자동으로 .tip 상태로 스냅 다운시켰습니다.

```swift
// Map+EventHandler.swift
  func cameraWillMove(kakaoMap: KakaoMap, by: MoveBy) {
      if by == .pan { 
          mapInterActiveDelegate?.mapDidReceiveUserInteraction(type: .pan)
      }
  }

// Root+Delegate.swift
  func mapDidReceiveUserInteraction(type: MapInteractionType) {
      setMode(.tip)
  }
```

지도와 시트의 활성 영역을 충돌시키는 대신, 지도 상호작용이 감지되는 순간
시트를 화면 아래로 내려 충돌 상황 자체를 없앴습니다.

---
충돌 2 — BottomSheet 내 ScrollView와 시트 드래그 충돌
  
문제

시트가 .max 상태일 때 내부 리스트를 위에서 아래로 스크롤하면, 시트를
드래그하는 건지 컨텐츠를 스크롤하는 건지 구분되지 않아 두 동작이 동시에
일어났습니다.
  
해결

ScrollView의 panGestureRecognizer에 별도 핸들러를 attach하고,
스크롤 최상단(contentOffset.y <= 0)에서 아래 방향(velocityY > 0) 드래그일
때만 스크롤을 잠그고 시트 드래그로 전환했습니다.

```swift
// scrollViewTracking()에서 attach
scrollView.panGestureRecognizer.addTarget(self, action:
#selector(handleScrollPan))
  
// handleScrollPan 내부
if offsetY <= 0, velocityY > 0 {
    isScrollDragged = true
    scrollView.contentOffset = .zero
    // 시트 드래그로 전환
}
```

시트가 .max가 아닐 때는 scrollView.isScrollEnabled = false로 스크롤을
비활성화해 불필요한 인터랙션을 차단했습니다.

---
### BottomSheet-지도 연동 구현 중 연쇄 트러블슈팅
  
문제 1 — 드래그 중 429 에러 발생

BottomSheet 드래그 시 지도 표시 영역을 시트 높이에 맞게 실시간으로 조정하기
위해
mapView.viewRect를 매 프레임 갱신했습니다. 이 방식이 호출마다 API 카운트가
증가하는 구조였고, 테스트 앱 키의 하루 쿼터 100회를 드래그 몇 번 만에 소진해
429 에러가 발생했습니다.

해결 1    

viewRect 재설정 대신 kakaoMap.setMargins()로 교체했습니다.
View 자체는 건드리지 않고 SDK 내부 뷰포트 기준점만 이동시키는 방식이라
API 호출 없이 동일한 시각적 효과를 얻을 수 있었습니다.

문제 2 — Margin 적용 후 지도 상단 흰 여백 노출
  
setMargins()로 뷰포트를 아래로 이동시키면, BottomSheet를 드래그해 내릴수록
지도도 함께 내려가면서 mapContainer 상단 경계 너머로 흰 여백이 노출됐습니다.

해결 2    

mapContainer에 상단 여유 공간을 미리 확보해 해결했습니다.
지도 View를 화면 위쪽으로 200pt 확장해, 뷰포트가 아래로 이동해도
실제 지도 콘텐츠가 상단을 항상 채우도록 했습니다.

```swift
mapContainer?.snp.makeConstraints {
    $0.edges.equalToSuperview().inset(
        UIEdgeInsets(top: -200, left: 0, bottom: 0, right: 0)
    )
}
```
