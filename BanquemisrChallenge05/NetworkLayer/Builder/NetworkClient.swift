//
//  NetworkClient.swift
//  BanquemisrChallenge
//
//  Created by Alshimaa on 04/03/2024.
//

import Foundation

public class NetworkClient {
    
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
}


//MARK: -  implementation with Async and await
extension NetworkClient: NetworkClientType {
    
    public func sendRequest<ResponseType: Decodable>(_ request: Endpoint) async throws -> ResponseType {
       
        do {
            
            let request = build(request)

            let (data, response) = try await session.data(for: request)
            
            log(with: request, data: data)
                        
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.noInternetConnection
            }
            
            if let error = VerifyResponse.checkResponseError(for: response, data: data) {
                throw error
            }
            
            guard let decodedData = try? JSONDecoder()
                .decode(ResponseType.self, from: data) else {
                throw NetworkError.decodingFailed
            }
            
            return decodedData
            
        } catch {
            if let noInternetError = error as NSError?,
               noInternetError.code == NSURLErrorNotConnectedToInternet,
               noInternetError.domain == NSURLErrorDomain {
                throw NetworkError.noInternetConnection
            }
            throw error
        }
    }
}


private extension NetworkClient {
    func log(with request: URLRequest, data: Data) {
        debugPrint(request.url?.absoluteString ?? "")
        debugPrint(String(decoding: data, as: UTF8.self))
    }
}
