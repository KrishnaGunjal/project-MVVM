//
//  APIService.swift
//  InnofiedAssingment
//
//  Created by krishna gunjal on 03/11/20.
//  Copyright © 2020 krishna gunjal. All rights reserved.
//

import Foundation

enum DataError: Error {
    case networkError
    case parsing
    case invalidURI
}

class APIService: NSObject {
    
    func getData(completion: @escaping(Result<[Album], DataError>) -> Void) {
        // The URI can be accepted from ViewModel if API has to be written more generic.
        // Same goes for API response parsing and model class array generation.
        let urlString = Constants.albumApi

        guard let dataURI = URL(string: urlString) else {
            completion(.failure(.invalidURI))
            return
        }

        let dataTask = URLSession.shared.dataTask(with: dataURI, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil, response != nil else {
                completion(.failure(.networkError))
                return
            }

            do {
                // Decode the json data.
                let decoder = JSONDecoder()
                let response = try decoder.decode([Album].self, from: data)
                completion(.success(response))
            } catch {
                print(error)
                completion(.failure(.parsing))
            }
        })

        dataTask.resume()
    }
    
}
