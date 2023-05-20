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
    
    
    func loadImage1(url: URL?, complecation: @escaping (Result<Data, APIError>) -> Void) {
        
        guard let url = url else {
            return complecation(.failure(APIError.invalidURL))
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                return complecation(.failure(APIError.networkError))
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return complecation(.failure(APIError.responseError))
            }
            return complecation(.success(data))
        }.resume()
    }
    
    func loadImage2(url: URL?, complecation: @escaping (Result<Data, APIError>) -> Void) {
        
        // 既存の画像ロードタスクがあればキャンセル
        task?.cancel()
        
        guard let url = url else {
            return complecation(.failure(APIError.invalidURL))
        }
        
        // セッション設定のキャッシュポリシーを設定します。キャッシュデータがあればそれを返し、なければネットワークからロードします。
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        let session = URLSession(configuration: configuration)
        
        let reqest = URLRequest(url: url)
        
        task = session.dataTask(with: reqest) { data, response, error in
            
            guard let data = data else {
                if let error = error as? NSError {
                    print(error.code)
                }
                return complecation(.failure(APIError.networkError))
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return complecation(.failure(APIError.responseError))
            }
            
            return complecation(.success(data))
        }
        task?.resume()
    }

    // 新たなタスクが設定された場合、古いタスクはキャンセルされる
    private var task: URLSessionDataTask? {
        didSet {
            oldValue?.cancel()
        }
    }
    
}
