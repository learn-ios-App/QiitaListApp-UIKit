//
//  ArticlesAPIClient.swift
//  QiitaListApp-UIKit
//
//  Created by 渡邊魁優 on 2023/04/29.
//

import Foundation

class QiitaAPIClient {
    func fetchArticles() async throws -> [Article] {
        guard let url = URL(string: "https://qiita.com/api/v2/items") else {
            throw APIError.invalidURL
        }
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw APIError.networkError
        }
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.responseError
        }
        guard let result = try? JSONDecoder().decode([Article].self, from: data) else {
            throw APIError.decodeError
        }
        return result
    }
}
