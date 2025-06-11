//
//  RegionCodeModel.swift
//  CafePoCa
//
//  Created by 권정근 on 6/11/25.
//

import Foundation


// MARK: - Welcome
struct RegionWelcome: Codable {
    let response: RegionResponse
}

// MARK: - Response
struct RegionResponse: Codable {
    let header: Header
    let body: RegionBody
}

// MARK: - Body
struct RegionBody: Codable {
    let items: RegionItems
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct RegionItems: Codable {
    let item: [RegionCodeModel]
}

// MARK: - Item
struct RegionCodeModel: Codable {
    let rnum: Int
    let code, name: String
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}
