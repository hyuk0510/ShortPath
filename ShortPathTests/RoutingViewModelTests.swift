//
//  RoutingViewModelTests.swift
//  ShortPathTests
//

import Testing
@testable import ShortPath

struct RoutingViewModelTests {
    
    private func makePlace(id: String, name: String = "테스트 장소") -> Place {
        Place(id: id, name: name, category: "", address: "", roadAddress: nil,
              longitude: 127.0, latitude: 37.5, distance: nil, phone: nil, placeURL: nil)
    }
    
    @Test func 초기상태는_출발지와_도착지_슬롯만_가진다() {
        let viewModel = RoutingViewModel()
        
        #expect(viewModel.numberOfItems == 2)
        #expect(viewModel.startPlace.place == nil)
        #expect(viewModel.destination.place == nil)
    }
    
    @Test func setStartPlace는_첫번째_슬롯에만_장소를_설정한다() {
        let viewModel = RoutingViewModel()
        let place = makePlace(id: "1")
        
        viewModel.setStartPlace(place)
        
        #expect(viewModel.startPlace.place == place)
        #expect(viewModel.destination.place == nil)
    }
    
    @Test func setEndPlace는_마지막_슬롯에만_장소를_설정한다() {
        let viewModel = RoutingViewModel()
        let place = makePlace(id: "2")
        
        viewModel.setEndPlace(place)
        
        #expect(viewModel.destination.place == place)
        #expect(viewModel.startPlace.place == nil)
    }
    
    @Test func setWayPoint를_두번_호출하면_도착지_앞에_순서대로_쌓인다() {
        let viewModel = RoutingViewModel()
        let first = makePlace(id: "way1")
        let second = makePlace(id: "way2")
        
        viewModel.setWayPoint(first)
        viewModel.setWayPoint(second)
        
        let wayPointPlaceIDs = (viewModel.wayPoints ?? []).map { $0.place?.id }
        
        #expect(viewModel.numberOfItems == 4)
        #expect(wayPointPlaceIDs == ["way1", "way2"])
        #expect(viewModel.destination.place == nil)
    }
    
    @Test func canRouting은_출발지와_도착지가_모두_있을_때만_true다() {
        let viewModel = RoutingViewModel()
        
        #expect(viewModel.canRouting == false)
        
        viewModel.setStartPlace(makePlace(id: "1"))
        #expect(viewModel.canRouting == false)
        
        viewModel.setEndPlace(makePlace(id: "2"))
        #expect(viewModel.canRouting == true)
    }
    
    @Test func isSamePlaceInARow는_연속된_같은_장소를_감지한다() {
        let viewModel = RoutingViewModel()
        let place = makePlace(id: "dup")
        
        viewModel.setStartPlace(place)
        viewModel.setEndPlace(place)
        
        #expect(viewModel.isSamePlaceInARow == true)
    }
    
    @Test func isSamePlaceInARow는_다른_장소면_false다() {
        let viewModel = RoutingViewModel()
        
        viewModel.setStartPlace(makePlace(id: "1"))
        viewModel.setEndPlace(makePlace(id: "2"))
        
        #expect(viewModel.isSamePlaceInARow == false)
    }
    
    @Test func setAllItems는_기존_아이템을_통째로_교체한다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "old"))
        
        let newItems: [RouteSectionItem] = [
            RouteSectionItem(placeId: "a", role: .start, place: makePlace(id: "a")),
            RouteSectionItem(placeId: "b", role: .wayPoint, place: makePlace(id: "b")),
            RouteSectionItem(placeId: "c", role: .destination, place: makePlace(id: "c"))
        ]
        
        viewModel.setAllItems(newItems)
        
        #expect(viewModel.numberOfItems == 3)
        #expect(viewModel.startPlace.place?.id == "a")
        #expect(viewModel.destination.place?.id == "c")
    }
    
    @Test func resetItems는_출발지와_도착지만_남기고_초기화한다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "1"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setEndPlace(makePlace(id: "2"))
        
        viewModel.resetItems()
        
        #expect(viewModel.numberOfItems == 2)
        #expect(viewModel.startPlace.place == nil)
        #expect(viewModel.destination.place == nil)
    }
    
    @Test func moveItem은_두_경유지의_순서를_서로_바꾼다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setWayPoint(makePlace(id: "way2"))
        viewModel.setEndPlace(makePlace(id: "end"))
        
        viewModel.moveItem(from: 1, to: 2)
        
        let wayPointIDs = (viewModel.wayPoints ?? []).map{ $0.place?.id }
        #expect(wayPointIDs == ["way2", "way1"])
        #expect(viewModel.startPlace.place?.id == "start")
        #expect(viewModel.destination.place?.id == "end")
    }
    
    @Test func moveItem으로_맨앞을_맨뒤로_옮기면_role이_위치기준으로_재할당된다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setEndPlace(makePlace(id: "end"))
        
        viewModel.moveItem(from: 0, to: 2)
        
        #expect(viewModel.startPlace.place?.id == "way1")
        #expect(viewModel.destination.place?.id == "start")
        #expect(viewModel.wayPoints?.first?.place?.id == "end")
    }
    
    @Test func moveItem은_source와_destination이_같으면_아무_변화가_없다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setEndPlace(makePlace(id: "end"))
        
        viewModel.moveItem(from: 1, to: 1)
        
        #expect(viewModel.startPlace.place?.id == "start")
        #expect(viewModel.wayPoints?.first?.place?.id == "way1")
        #expect(viewModel.destination.place?.id == "end")
    }
    
    @Test func moveItem은_존재하지_않는_source_index를_넘기면_아무_변화가_없다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setEndPlace(makePlace(id: "end"))
        
        viewModel.moveItem(from: 0, to: 99)
        
        #expect(viewModel.startPlace.place?.id == "start")
        #expect(viewModel.wayPoints?.first?.place?.id == "way1")
        #expect(viewModel.destination.place?.id == "end")
        
        
    }
    
    @Test func moveItem은_존재하지_않는_destination_index를_넘기면_아무_변화가_없다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1"))
        viewModel.setEndPlace(makePlace(id: "end"))
        
        viewModel.moveItem(from: 99, to: 0)
        
        #expect(viewModel.startPlace.place?.id == "start")
        #expect(viewModel.wayPoints?.first?.place?.id == "way1")
        #expect(viewModel.destination.place?.id == "end")
    }
    
    @Test func makeRouteDraft은_출발지와_도착지가_없으면_nil을_반환한다() {
        let viewModel = RoutingViewModel()

        let draft = viewModel.makeRouteDraft()

        #expect(draft == nil)
    }
    
    @Test func makeRouteDraft은_currentRoute가_없으면_distance와_duration이_0이다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setEndPlace(makePlace(id: "end"))

        let draft = viewModel.makeRouteDraft()

        #expect(draft?.distance == 0)
        #expect(draft?.duration == 0)
    }
    
    @Test func makeRouteDraft은_currentRoute가_있으면_그_distance와_duration을_반영한다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setEndPlace(makePlace(id: "end"))

        viewModel.currentRoute = Route(
            resultCode: 0,
            resultMsg: "OK",
            summary: Summary(
                origin: Points(name: nil, x: 0, y: 0),
                destination: Points(name: nil, x: 0, y: 0),
                waypoints: nil,
                priority: "RECOMMEND",
                bound: Bound(minX: 0, minY: 0, maxX: 0, maxY: 0),
                fare: Fare(taxi: 0, toll: 0),
                distance: 12000,
                duration: 900
            ),
            sections: []
        )

        let draft = viewModel.makeRouteDraft()

        #expect(draft?.distance == 12000)
        #expect(draft?.duration == 900)
    }
    
    @Test func makeRouteDraft은_경유지들을_RoutePlace로_순서대로_변환한다() {
        let viewModel = RoutingViewModel()
        viewModel.setStartPlace(makePlace(id: "start"))
        viewModel.setWayPoint(makePlace(id: "way1", name: "경유지1"))
        viewModel.setWayPoint(makePlace(id: "way2", name: "경유지2"))
        viewModel.setEndPlace(makePlace(id: "end"))

        let draft = viewModel.makeRouteDraft()

        #expect(draft?.waypoints.map { $0.id } == ["way1", "way2"])
        #expect(draft?.waypoints.map { $0.placeName } == ["경유지1", "경유지2"])
    }
}
