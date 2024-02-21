import Foundation

// MARK: - Network Connection
enum NetworkError: Error {
    case decodingError(Error)
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
            let decoder = JSONDecoder()
            let urlSession = URLSession.shared
            return urlSession.data(for: request) { (result: Result<Data, Error>) in
                let response = result.flatMap { data -> Result<T, Error> in
                    Result {try decoder.decode(T.self, from: data)}
                }
                completion(response)
            }
        }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
    
    func postOrDeleteLike(
        for request: URLRequest,
        completion: @escaping (Result<Void, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            let data: Void
            if let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}

