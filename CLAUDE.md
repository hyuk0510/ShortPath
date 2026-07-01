# ShortPath (Routee) 프로젝트

## 나에 대해
- 이름: 선상혁
- iOS 개발자 취업 준비 중 (신입)
- 주요 기술: Swift, UIKit, KakaoMaps SDK, Realm, SnapKit

## 앱 개요
- **앱 이름**: ShortPath (개발 코드명: Routee)
- **장르**: 지도/내비게이션 앱
- **개발 형태**: 개인 프로젝트
- **개발 기간**: 2025년 11월 ~ 2026년 5월 (약 6개월)
- **배포**: App Store 제출 완료 (2026년 5월)

## 핵심 기능
- 카카오맵 기반 지도 뷰
- 장소 검색 (Kakao Local API)
- 경로 탐색 (출발지 → 경유지 → 목적지, 다중 경유지 지원)
- 즐겨찾기 (장소 / 경로)
- 최근 경로 및 최근 검색 장소 기록
- 현재 위치 탐지 및 역지오코딩

## 기술 스택
| 분류 | 기술 |
|------|------|
| UI | UIKit, SnapKit |
| 지도 | KakaoMaps SDK |
| 네트워크 | URLSession, async/await, Kakao Local API, Kakao Mobility API |
| 로컬 저장 | Realm (즐겨찾기, 최근 경로, 최근 장소) |
| 위치 | CoreLocation, CLGeocoder |

## 아키텍처
- MVC 패턴 기반
- Protocol을 활용한 Delegate 패턴으로 ViewController 간 통신
  - MapInteractionDelegate, BottomSheetInteractable, RoutingPanelViewDelegate 등
- MapViewController의 기능을 Extension으로 분리 (LifeCycle, UI, Route, POI, EventHandler 등)

## 주요 구현 포인트 (자소서 소재용)
- KakaoMaps SDK 연동 및 지도 초기화 흐름 직접 구현
- Kakao Mobility API를 이용한 다중 경유지 경로 요청 (POST + JSON body)
- Realm을 활용한 즐겨찾기/최근 경로 로컬 저장 구조 설계
- BottomSheet UI를 ScrollView 연동으로 직접 구현
- 커스텀 탭바 및 네비게이션 뷰 직접 제작

## 자소서 작업 맥락
- 현재 신입 iOS 개발자 채용 공고에 지원 준비 중
- 이 프로젝트를 주요 포트폴리오로 사용
- 성공/실패 사례, 지원 동기 등 항목 작성 시 이 프로젝트 경험을 활용할 것
