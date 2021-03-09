//
//  AuthManager.swift
//  Spotify
//
//  Created by Akhadjon Abdukhalilov on 2/28/21.
//

import Foundation

final class AuthManager{
    static let shared = AuthManager()
    private var refreshingToken = false
    
    struct Constants{
        static let clientID = "63ddec00215a478abd5c79ca999698ad"
        static let clientSecret = "04ebdd3e76fc4f329e388ce0d3c07894"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURL = "https://www.facebook.com/akhadjon.abdukhalilov/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init(){}
    
    public var signURL:URL?{
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURL)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn:Bool{
        return accessToken != nil
    }
    
    private var accessToken:String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken:String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExperationDate:Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken:Bool{
        guard let expirationDate = tokenExperationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code:String, completion:@escaping((Bool)->Void)){
        //Get token
        guard let url = URL(string: Constants.tokenAPIURL) else{  return }
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                 URLQueryItem(name: "code", value: code),
                                 URLQueryItem(name: "redirect_uri", value: Constants.redirectURL) ]
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion(false)
            print("Failure  to get base64")
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] (data, _, error) in
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result:result)
                completion(true)
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }
    
    public func cacheToken(result:AuthResponse){
        UserDefaults.standard.set(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.set(result.refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    private var onRefreshBlocks = [((String)->Void)]()
    
    //Supplies valid token to be used with API calls
    public func withValidToken(completion:@escaping(String)->Void){
        guard !refreshingToken else {
            //append completion
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            refreshIfNeeded { [weak self](success) in
                if let token = self?.accessToken, success{
                        completion(token)
                }
            }
        }else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion:@escaping(Bool)->Void){
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else{
            completion(true)
            return
        }
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        //Refresh Token
        guard let url = URL(string: Constants.tokenAPIURL) else{  return }
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                 URLQueryItem(name: "refresh_token", value: refreshToken) ]
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion(false)
            print("Failure  to get base64")
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] (data, _, error) in
            self?.refreshingToken = false
            
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                print("Successfully refreshed")
                self?.cacheToken(result:result)
                completion(true)
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
    }
    
}
