import Foundation

class NetworkManager {
    var urlSession = URLSession.shared

    private let config: Config
    init(config: Config) {
        self.config = config
    }

    func post(path: String, object: Encodable, handler: ((Error?) -> Void)? = nil) {
        let url = URL(string: "\(config.urlEndpoint)/client/\(path)")!
        print(url)

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.jsonDateFormat)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(object)

        print(request)

        self.request(request: request, handler: handler)
    }

    func request(request: URLRequest, handler: ((Error?) -> Void)? = nil) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                handler?(error ?? URLError(.badServerResponse))
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            handler?(nil)
        }

        task.resume()
    }
}
