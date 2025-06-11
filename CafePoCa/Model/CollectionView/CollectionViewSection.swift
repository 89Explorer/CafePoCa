//
//  CollectionViewSection.swift
//  CafePoCa
//
//  Created by 권정근 on 6/5/25.
//

import Foundation


// 통합 데이터를 담기 위한 구조체
struct HomeSection: Hashable {
    let type: CafeSectionType
    let item: [CafeItemType]
}


enum CafeSectionType: Int, CaseIterable {
    case region
    case cafe
    
    var title: String {
        switch self {
        case .region: return "지역카테고리"
        case .cafe: return "현위치카페정보"
        }
    }
}


enum CafeItemType: Hashable {
    case region(RegionCodeInfo)
    case cafe(CafeListInfo)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .region(let region):
            hasher.combine(region.code)
        case .cafe(let cafe):
            hasher.combine(cafe.contentid)
        }
    }
    
    static func == (lhs: CafeItemType, rhs: CafeItemType) -> Bool {
        switch (lhs, rhs) {
        case (.region(let a), .region(let b)):
            return a.code == b.code
        case (.cafe(let a), .cafe(let b)):
            return a.contentid == b.contentid
        default:
            return false
        }
    }
}

/// API를 통해 받아온 지역 카테고리에서 필요한 정보만 모으기 위한 데이터모델 -> 컬렉션뷰 목적 
struct RegionCodeInfo: Hashable {
    let code: String
    let name: String
}

/// API를 통해 받아온 카페 정보에서 필요한 정보만 모으기 위한 데이터 모델 -> 컬렉션뷰 목적
struct CafeListInfo: Hashable {
    let title: String?
    let address: String?
    let imageURL: String?
    let contentid: String?
}
