# Routee
### UIKit, KakaoMapsSDK, Realm 기반의 지도 경로 탐색 및 저장 iOS 앱


[앱스토어 링크](https://apps.apple.com/kr/app/routee/id6766235481)

## Tech Stack

| Category | Detail |
|---|---|
| Language | Swift |
| UI | UIKit, SnapKit |
| Map | KakaoMapsSDK (SPM) |
| DataBase | RealmSwift |
| Networking | URLSession + Codable (Kakao Local API) |
| Concurrency | async/await, GCD, MainActor |
| Min Deployment | iOS 16+ |
---

## Features

- KakaoMapsSDK 기반 지도 경로 탐색 및 시각화

- Kakao Local REST API 기반 장소 검색 및 상세 정보 제공

- Realm 기반 즐겨찾기, 최근 검색, 최근 경로 저장

- 오프라인에서도 접근 가능한 로컬 데이터 관리

- 4단계 snap state를 가진 커스텀 BottomSheet 구현

- 현재 위치 탐색 및 reverse geocoding 기반 주소 변환

---

## Architecture

이 프로젝트는 **MVC + Repository + Delegate** 구조를 기반으로 구성했습니다.  

중앙 컨테이너 역할을 하는 `RootContainerViewController`가 지도, BottomSheet, overlay view를 관리하고, 각 화면 간의 이벤트는 protocol 기반 delegate로 전달합니다.

```txt

RootContainerViewController
├── MapViewController            ← KakaoMapsSDK 렌더링, 위치, POI/경로 표시
│   └── 13 extensions            ← Auth, Layout, POI, Route, EventHandler,
│                                   LocationManager, UI, LifeCycle, Observers...
├── BottomSheetView              ← Gesture 기반 container (4 snap states)
│   ├── HomeTabViewController
│   ├── FavoriteTabViewController
│   └── SettingView (SwiftUI via UIHostingController)
├── RootViewModel                ← Sheet state 관리 (home / placeDetail / routing)
└── RoutingViewModel             ← 경로 지점 및 closure 기반 상태 전달
```

## State Binding

State binding은 Combine이나 RxSwift 대신  

가벼운 `didSet` + closure callback 기반으로 구현했습니다.

```swift

private(set) var items: [RouteSectionItem] = [] {

    didSet { onChange?() }

}

var onChange: (() -> Void)?
```
