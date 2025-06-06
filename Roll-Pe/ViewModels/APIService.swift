//
//  APIService.swift
//  Roll-Pe
//
//  Created by 김태은 on 2/15/25.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import UIKit

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    private let disposeBag = DisposeBag()
    
    var isRefreshing: Bool = false
    
    // 요청
    func request(
        _ url: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        isDomainInclude: Bool = false
    ) -> Observable<(HTTPURLResponse, Data)> {
        return RxAlamofire.request(
            method,
            "\(isDomainInclude ? "" : API_SERVER_URL)\(url)",
            parameters: parameters,
            encoding: encoding,
            interceptor: AuthInterceptor.shared
        )
        .observe(on: MainScheduler.instance)
        .validate { _, response, _ in
            if response.statusCode == 401 || (500..<600).contains(response.statusCode) {
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
            } else {
                return .success(())
            }
        }
        .responseData()
    }
    
    // 요청과 Decode처리
    func requestDecodable<T: Decodable>(
        _ url: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        decodeType: T.Type,
        isDomainInclude: Bool = false
    ) -> Observable<T> {
        return RxAlamofire.request(
            method,
            "\(isDomainInclude ? "" : API_SERVER_URL)\(url)",
            parameters: parameters,
            encoding: encoding,
            interceptor: AuthInterceptor.shared
        )
        .observe(on: MainScheduler.instance)
        .validate { _, response, _ in
            if response.statusCode == 401 || (500..<600).contains(response.statusCode) {
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
            } else {
                return .success(())
            }
        }
        .responseData()
        .flatMap { response, data in
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(decodeType, from: data)
                return Observable.just(decodedData)
            } catch {
                return Observable.error(error)
            }
        }
    }
}

// MARK: - Interceptor

final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    
    private init() {}
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let keychain = Keychain.shared
        
        guard let accessToken = keychain.read(key: "ACCESS_TOKEN") else {
            completion(.failure(NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "액세스 토큰이 없음"])))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let userViewModel = UserViewModel()
        
        print("retry 진입")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            print("401 오류가 아님")
            completion(.doNotRetryWithError(error))
            return
        }
        
        if APIService.shared.isRefreshing {
            print("재발급 중")
            completion(.retry)
        } else {
            APIService.shared.isRefreshing = true
            
            refreshToken() { isSuccess in
                APIService.shared.isRefreshing = false
                
                if isSuccess {
                    print("재발급 완료")
                    completion(.retry)
                } else {
                    print("리프레시 토큰 만료")
                    userViewModel.logout()
                    completion(.doNotRetry)
                }
            }
        }
    }
    
    private func refreshToken(completion: @escaping(Bool) -> Void) {
        let keychain = Keychain.shared
        
        guard let refresh = keychain.read(key: "REFRESH_TOKEN") else {
            print("리프레시 토큰 없음")
            completion(false)
            return
        }
        
        let parameters: [String: Any] = ["refresh": refresh]
        
        AF.request("\(API_SERVER_URL)/api/user/token/refresh", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let model = try JSONDecoder().decode(RefreshModel.self, from: data)
                        keychain.create(key: "ACCESS_TOKEN", value: model.access)
                        
                        completion(true)
                    } catch {
                        print("디코딩 실패: \(error)")
                        completion(false)
                    }
                case .failure(let error):
                    print("재발급 요청 실패: \(error)")
                    completion(false)
                }
            }
    }
}
