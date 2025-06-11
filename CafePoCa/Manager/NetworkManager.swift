//
//  NetworkManager.swift
//  CafePoCa
//
//  Created by 권정근 on 6/11/25.
//

import Foundation


struct Constants {
    
    static let api_key = Bundle.main.infoDictionary?["API_Key"] as! String
    static let baseURLString: String = "https://apis.data.go.kr/B551011/KorService1"
    static let latestbaseURLString: String = "https://apis.data.go.kr/B551011/KorService2"
    
}


final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() { }
    
    
    func getRegionCode() async throws -> [RegionCodeModel] {
        
        var components = URLComponents(string: "\(Constants.latestbaseURLString)/areaCode2")
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "serviceKey", value: Constants.api_key),
            URLQueryItem(name: "numOfRows", value: "20"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "MobileOS", value: "ETC"),
            URLQueryItem(name: "MobileApp", value: "AppTest"),
            URLQueryItem(name: "_type", value: "json")
        ]
        
        components?.queryItems = queryItems
        
        if let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "%25", with: "%") {
            components?.percentEncodedQuery = encodedQuery
        }
        
        guard let url = components?.url else {
            print("❌ URL 생성 실패: \(String(describing: components?.string))")
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 지역 코드 상태 코드: \(httpResponse.statusCode)")
            }
            
            let decoded = try JSONDecoder().decode(RegionWelcome.self, from: data)
            return decoded.response.body.items.item
        } catch let decodingError as DecodingError {
            print("❌ 지역 코드 디코딩 오류: \(decodingError)")
            throw decodingError
        } catch {
            print("❌ 지역 코드 네트워크 요청 오류: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getCafeBasedLocation(mapX: String, mapY: String, radius: String = "2000") async throws -> [CafeItem] {
        
        var components = URLComponents(string: "\(Constants.latestbaseURLString)/locationBasedList2")
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "serviceKey", value: Constants.api_key),
            URLQueryItem(name: "numOfRows", value: "10"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "MobileOS", value: "ETC"),
            URLQueryItem(name: "MobileApp", value: "AppTest"),
            URLQueryItem(name: "_type", value: "json"),
            URLQueryItem(name: "arrange", value: "Q"),
            URLQueryItem(name: "mapX", value: "\(mapX)"),
            URLQueryItem(name: "mapY", value: "\(mapY)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "contentTypeId", value: "39") // 음식점
        ]
        
        components?.queryItems = queryItems
        
        // 중복 인코딩 방지
        if let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "%25", with: "%") {
            components?.percentEncodedQuery = encodedQuery
        }
        
        guard let url = components?.url else {
            print("❌ URL 생성 실패: \(String(describing: components?.string))")
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📶 상태 코드: \(httpResponse.statusCode)")
            }
            
            let decoded = try JSONDecoder().decode(CafeWelcome.self, from: data)
            return decoded.response.body.items.item
        } catch let decodingError as DecodingError {
            print("❌ 디코딩 오류: \(decodingError)")
            throw decodingError
        } catch {
            print("❌ 네트워크 오류: \(error.localizedDescription)")
            throw error
        }
    }
}
