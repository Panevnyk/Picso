//
//  RestApiManagerMock.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 17.07.2023.
//

import RestApiManager

final public class RestApiManagerMock: RestApiManager {
    
    // ---------------------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------------------
    
    /// RestApiManagerDIContainer
    public var restApiManagerDIContainer: RestApiManagerDIContainer {
        return urlSessionRAMDIContainer
    }
    
    /// URLSessionRAMDIContainer
    let urlSessionRAMDIContainer: URLSessionRAMDIContainer<DefaultRestApiError>
    
    /// Current URLSessionTask
    public var currentURLSessionTasks: [URLSessionTask] = []
    
    // ---------------------------------------------------------------------
    // MARK: - Inits
    // ---------------------------------------------------------------------
    
    /// Init with URLSessionRestApiManager properties
    ///
    /// - Parameter urlSessionRAMDIContainer: URLSessionRAMDIContainer
    public init(urlSessionRAMDIContainer: URLSessionRAMDIContainer<DefaultRestApiError>) {
        self.urlSessionRAMDIContainer = urlSessionRAMDIContainer
    }
    
    /// Init with default URLSessionRestApiManager properties
    public init() {
        urlSessionRAMDIContainer =
            URLSessionRAMDIContainer(errorType: DefaultRestApiError.self)
    }
}

// MARK: - Simple requests
extension RestApiManagerMock {
    /// Object call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated>(method: RestApiMethod, completion: @escaping (_ result: Result<T>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Array call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<[T]>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated>(method: RestApiMethod, completion: @escaping (_ result: Result<[T]>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// String call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<String>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call(method: RestApiMethod, completion: @escaping (_ result: Result<String>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Custom response serializer call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - responseSerializer: T where T: ResponseSerializer
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: ResponseSerializer>(method: RestApiMethod, responseSerializer: T) -> URLSessionTask? {
        return nil
    }
}

// MARK: - Simple requests with ET
extension RestApiManagerMock {
    /// Object call with ET
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<T, ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated, ET: RestApiError>(method: RestApiMethod, completion: @escaping (_ result: ResultWithET<T, ET>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Array call with ET
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<[T], ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated, ET: RestApiError>(method: RestApiMethod, completion: @escaping (_ result: ResultWithET<[T], ET>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// String call with ET
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<String, ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<ET: RestApiError>(method: RestApiMethod, completion: @escaping (_ result: ResultWithET<String, ET>) -> Void) -> URLSessionTask? {
        return nil
    }
}

// MARK: - Multipart
extension RestApiManagerMock {
    /// Multipart Object call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated>(multipartData: MultipartData,
                                    method: RestApiMethod,
                                    completion: @escaping (_ result: Result<T>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Multipart Array call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: Result<[T]>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated>(multipartData: MultipartData,
                                    method: RestApiMethod,
                                    completion: @escaping (_ result: Result<[T]>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Multipart String call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: Result<String>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call(multipartData: MultipartData,
                     method: RestApiMethod,
                     completion: @escaping (_ result: Result<String>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Multipart Custom response serializer call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - responseSerializer: T where T: ResponseSerializer
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: ResponseSerializer>(multipartData: MultipartData,
                                            method: RestApiMethod,
                                            responseSerializer: T) -> URLSessionTask? {
        return nil
    }
}

// MARK: - Multipart requests with ET
extension RestApiManagerMock {
    /// Multipart Object call with ET
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<T, ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated, ET: RestApiError>(multipartData: MultipartData,
                                                      method: RestApiMethod,
                                                      completion: @escaping (_ result: ResultWithET<T, ET>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Multipart Array call with ET
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<[T], ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<T: Associated, ET: RestApiError>(multipartData: MultipartData,
                                                      method: RestApiMethod,
                                                      completion: @escaping (_ result: ResultWithET<[T], ET>) -> Void) -> URLSessionTask? {
        return nil
    }
    
    /// Multipart String call with ET
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: ResultWithET<String, ET>
    /// - Returns: URLSessionTask?
    @discardableResult
    public func call<ET: RestApiError>(multipartData: MultipartData,
                                       method: RestApiMethod,
                                       completion: @escaping (_ result: ResultWithET<String, ET>) -> Void) -> URLSessionTask? {
        return nil
    }
}
