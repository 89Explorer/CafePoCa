//
//  HomeViewModel.swift
//  CafePoCa
//
//  Created by 권정근 on 6/11/25.
//

import Foundation
import Combine


@MainActor
final class HomeViewModel {
    
    // MARK: - Variable
    @Published var regionList: [RegionCodeModel] = []
    @Published var cafeList: [CafeItem] = []
    @Published var homeTotalModel: [HomeSection] = [] 
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    
    // MARK: - Function
    
    /// 지역 카테고리를 가져오는 함수
    func fetchRegionList() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await NetworkManager.shared.getRegionCode()
            self.regionList = result
            print("✅ 지역코드: \(result[0].name)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ 지역코드 에러: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    /// 위치 기반으로 카페리스트 가져오는 함수
    func fetchCafeList(mapX: String, mapY: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await NetworkManager.shared.getCafeBasedLocation(mapX: mapX, mapY: mapY)
            self.cafeList = result
            print("✅ 카페리스트: \(result[0].title)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ 지역코드 에러: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func clearHomeData() {
        self.cafeList = []
        self.regionList = []
    }
    
    
    func makeRegionSection() -> HomeSection? {
        guard !regionList.isEmpty else { return nil }
        
        let items = regionList.map { item in
            let info = RegionCodeInfo(code: item.code, name: item.name)
            return CafeItemType.region(info)
        }
        return HomeSection(type: .region, item: items)
    }
    
    func makeCafeSection() -> HomeSection? {
        guard !cafeList.isEmpty else { return nil }
        
        let items = cafeList.map { item in
            let info = CafeListInfo(title: item.title,
                                    address: item.addr1,
                                    imageURL: item.firstimage,
                                    contentid: item.contentid)
            return CafeItemType.cafe(info)
        }
        
        return HomeSection(type: .cafe, item: items)
    }
    
    func makeAllSection() {
        var sections: [HomeSection] = []
        
        if let region = makeRegionSection() {
            sections.append(region)
        }
        
        if let cafe = makeCafeSection() {
            sections.append(cafe)
        }
        
        self.homeTotalModel = sections
    }
}
