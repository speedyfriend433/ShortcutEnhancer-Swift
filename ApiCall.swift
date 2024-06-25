//
// ApiCall.swift
//
// Created by Speedyfriend67 on 25.06.24
//
 
import Foundation

func performAPICall(urlString: String, parameters: [String: String], completion: @escaping (Result<Data, Error>) -> Void) {
    guard var urlComponents = URLComponents(string: urlString) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    
    guard let url = urlComponents.url else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            completion(.success(data))
        }
    }
    
    task.resume()
}