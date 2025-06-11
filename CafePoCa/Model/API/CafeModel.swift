//
//  CafeModel.swift
//  CafePoCa
//
//  Created by 권정근 on 6/11/25.
//

import Foundation

struct CafeWelcome: Codable {
    let response: CafeResponse
}

struct CafeResponse: Codable {
    let header: CafeHeader
    let body: CafeBody
}

struct CafeHeader: Codable {
    let resultCode: String
    let resultMsg: String
}

struct CafeBody: Codable {
    let items: CafeItems
    let numOfRows, pageNo, totalCount: Int
}

struct CafeItems: Codable {
    let item: [CafeItem]
}

struct CafeItem: Codable {
    let addr1: String
    let addr2: String
    let zipcode: String
    let areacode: String
    let cat1: String
    let cat2: String
    let cat3: String
    let contentid: String
    let contenttypeid: String
    let dist: String
    let firstimage: String
    let firstimage2: String
    let mapx: String     // 경도
    let mapy: String     // 위도
    let title: String
    let tel: String
}
