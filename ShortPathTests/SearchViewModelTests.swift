//
//  SearchViewModelTests.swift
//  ShortPathTests
//
//  Created by 선상혁 on 9/2/26.
//

import Testing
@testable import ShortPath
import CoreLocation

struct FakePlaceSearchService: PlaceSearchServiceProtocol {
    let result: PlaceInfo

    func fetchKeywordSearch(text: String, coordinate: CLLocationCoordinate2D) async throws -> PlaceInfo {
        result
    }
}

final class FakeFavoriteRepository: FavoriteRepositoryProtocol {
    var favoriteIDs: Set<String> = []

    func savePlace(place: Place) { favoriteIDs.insert(place.id) }
    func deletePlace(placeID: String) { favoriteIDs.remove(placeID) }
    func isFavorite(placeID: String) -> Bool { favoriteIDs.contains(placeID) }
    func fetchAlltoFavoritePlace() -> [FavoritePlace] { [] }
    func fetchAlltoPlace() -> [Place] { [] }
    func fetch(placeID: String) -> Place? { nil }
}

struct SearchViewModelTests {

    private func makeDocument(id: String, placeName: String, roadAddressName: String = "") -> Document {
        Document(
            addressName: "",
            categoryGroupCode: "",
            categoryGroupName: "",
            categoryName: "",
            distance: "",
            id: id,
            phone: "",
            placeName: placeName,
            placeURL: "",
            roadAddressName: roadAddressName,
            x: "127.0",
            y: "37.5"
        )
    }

    @Test func search은_이름이_검색어로_시작하는_장소를_우선_정렬한다() async throws {
        let documents = [
            makeDocument(id: "1", placeName: "강남 스타벅스"),
            makeDocument(id: "2", placeName: "스타벅스 강남점")
        ]
        let placeInfo = PlaceInfo(documents: documents, meta: Meta(totalCount: 2))
        let fakeService = FakePlaceSearchService(result: placeInfo)
        let viewModel = SearchViewModel(placeSearchService: fakeService, favoritePlaceRepo: FakeFavoriteRepository())

        viewModel.search(text: "스타벅스", coordinate: CLLocation(latitude: 37.5, longitude: 127.0))

        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(viewModel.places.first?.id == "2")
    }
    
    @Test func search에_빈_문자열을_넘기면_결과가_즉시_비워진다() {
        let fakeService = FakePlaceSearchService(result: PlaceInfo(documents: [], meta: Meta(totalCount: 0)))
        let viewModel = SearchViewModel(placeSearchService: fakeService, favoritePlaceRepo: FakeFavoriteRepository())

        viewModel.search(text: "   ", coordinate: nil)

        #expect(viewModel.places.isEmpty)
    }
    
    @Test func isFavorite는_favoriteRepo의_결과를_그대로_반환한다() {
        let fakeFavoriteRepo = FakeFavoriteRepository()
        fakeFavoriteRepo.favoriteIDs = ["1"]

        let viewModel = SearchViewModel(
            placeSearchService: FakePlaceSearchService(result: PlaceInfo(documents: [], meta: Meta(totalCount: 0))),
            favoritePlaceRepo: fakeFavoriteRepo
        )

        #expect(viewModel.isFavorite(placeID: "1") == true)
        #expect(viewModel.isFavorite(placeID: "2") == false)
    }
}
