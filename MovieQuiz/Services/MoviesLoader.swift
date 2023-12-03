import Foundation

struct MoviesLoader: MoviesLoadingProtocol {
    private let networkClient = NetworkClient()
    private let API_TOKEN = "k_zcuw1ytf"
    private let BASE_API_URL = "https://imdb-api.com/en/API/"

    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "\(BASE_API_URL)Top250Movies/\(API_TOKEN)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }
}