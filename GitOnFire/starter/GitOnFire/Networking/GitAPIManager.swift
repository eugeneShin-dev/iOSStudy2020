/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Alamofire

class GitAPIManager {
  static let shared = GitAPIManager()
  
  let sessionManager: Session = {
    let configuration = URLSessionConfiguration.af.default
    configuration.timeoutIntervalForRequest = 30
    configuration.waitsForConnectivity = true
    let networkLogger = GitNetworkLogger()
    return Session(configuration: configuration, eventMonitors: [networkLogger])
  }()

  func fetchPopularSwiftRepositories(completion: @escaping ([Repository]) -> Void) {
    searchRepositories(query: "language:Swift", completion: completion)
  }

  func fetchCommits(for repository: String, completion: @escaping ([Commit]) -> Void) {
    let url = "https://api.github.com/repos/\(repository)/commits"
    sessionManager.request(url)
      .responseDecodable(of: [Commit].self) { response in
        guard let commits = response.value else {
          return
        }
        completion(commits)
      }
  }

  func searchRepositories(query: String, completion: @escaping ([Repository]) -> Void) {
    let url = "https://api.github.com/search/repositories"
    var queryParameters: [String: Any] = ["sort": "stars", "order": "desc", "page": 1]
    queryParameters["q"] = query
    
    // 전달 받은 response를 decode한 후 레퍼지토리의 array를 compeletion block으로 리턴한다
    sessionManager.request(url, parameters: queryParameters)
      .responseDecodable(of: Repositories.self) { response in
        guard let items = response.value else {
          return completion([])
        }
        completion(items.items)
      }
  }
  
  func fetchAccessToken(accessCode: String, completion: @escaping (Bool) -> Void) {
    let headers: HTTPHeaders = [
      "Accept" : "application/json"
    ]
    
    let parameters = [
      "client_id" : GitHubConstants.clientID,
      "client_secret" : GitHubConstants.clientSecret,
      "code" : accessCode
    ]
    
    sessionManager.request("https://github.com/login/oauth/access_token",
                           method: .post,
                           parameters: parameters,
                           headers: headers).responseDecodable(of: GitHubAccessToken.self) { response in
                            guard let cred = response.value else {
                              return completion(false)
                            }
                            TokenManager.shared.saveAccessToken(gitToken: cred)
                            completion(true)
                           }
  }
}
