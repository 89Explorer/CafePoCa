//
//  RegionCodeModel.swift
//  CafePoCa
//
//  Created by 권정근 on 6/11/25.
//

// 지역 코드와 지역명 관련 데이터 모델
import Foundation


struct RegionWelcome: Codable {
    let response: RegionResponse
}

struct RegionResponse: Codable {
    let header: Header
    let body: RegionBody
}

struct RegionBody: Codable {
    let items: RegionItems
    let numOfRows, pageNo, totalCount: Int
}

struct RegionItems: Codable {
    let item: [RegionCodeModel]
}

struct RegionCodeModel: Codable {
    let rnum: Int
    let code, name: String
}

struct Header: Codable {
    let resultCode, resultMsg: String
}
