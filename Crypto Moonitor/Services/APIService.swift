import Foundation

final class APIService {
    
    static let shared = APIService()
    private let session: URLSession = .shared
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    private init() {}

    // MARK: - Generic request

    private func request<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem] = [],
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            print("Invalid URL for endpoint: \(endpoint)")
            completion(.failure(APIError.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("Empty response")
                completion(.failure(APIError.emptyData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Decoding failed: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw JSON:\n\(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Public API

    func fetchCryptos(completion: @escaping (Result<[Crypto], Error>) -> Void) {
        request(
            endpoint: "/coins/markets",
            queryItems: [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "sparkline", value: "true")
            ],
            responseType: [Crypto].self,
            completion: completion
        )
    }

    func fetchCryptoByID(_ id: String, completion: @escaping (Result<Crypto, Error>) -> Void) {
        request(
            endpoint: "/coins/markets",
            queryItems: [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "ids", value: id),
                URLQueryItem(name: "sparkline", value: "true")
            ],
            responseType: [Crypto].self
        ) { result in
            switch result {
            case .success(let array): completion(.success(array.first!))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func fetchDetail(for id: String, completion: @escaping (Result<DetailedCrypto, Error>) -> Void) {
        request(
            endpoint: "/coins/\(id)",
            queryItems: [
                URLQueryItem(name: "localization", value: "false"),
                URLQueryItem(name: "tickers", value: "false"),
                URLQueryItem(name: "community_data", value: "false"),
                URLQueryItem(name: "developer_data", value: "false")
            ],
            responseType: DetailedCrypto.self,
            completion: completion
        )
    }

    func fetchTickers(for id: String, completion: @escaping (Result<[Ticker], Error>) -> Void) {
        request(
            endpoint: "/coins/\(id)/tickers",
            responseType: TickerResponse.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(Array(response.tickers.prefix(30))))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchExchanges(completion: @escaping (Result<[Exchange], Error>) -> Void) {
        request(
            endpoint: "/exchanges",
            queryItems: [
                URLQueryItem(name: "per_page", value: "30"),
                URLQueryItem(name: "page", value: "1")
            ],
            responseType: [Exchange].self,
            completion: completion
        )
    }

    func fetchPrice(for id: String, completion: @escaping (Result<Double, Error>) -> Void) {
        request(
            endpoint: "/simple/price",
            queryItems: [
                URLQueryItem(name: "ids", value: id),
                URLQueryItem(name: "vs_currencies", value: "usd")
            ],
            responseType: [String: [String: Double]].self
        ) { result in
            switch result {
            case .success(let dict):
                if let price = dict[id]?["usd"] {
                    completion(.success(price))
                } else {
                    completion(.failure(APIError.missingPrice))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum APIError: Error {
    case invalidURL
    case emptyData
    case missingPrice
}
