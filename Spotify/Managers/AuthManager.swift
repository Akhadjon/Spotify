//
//  AuthManager.swift
//  Spotify
//
//  Created by Akhadjon Abdukhalilov on 2/28/21.
//

import Foundation

final class AuthManager{
    static let shared = AuthManager()
    
    struct Constants{
        static let clientID = "63ddec00215a478abd5c79ca999698ad"
        static let clientSecret = "04ebdd3e76fc4f329e388ce0d3c07894"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    }
    
    private init(){}
    
    public var signURL:URL?{
        let scopes = "user-read-private"
        let redirectURL = "https://www.facebook.com/akhadjon.abdukhalilov/"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURL)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn:Bool{
        return false
    }
    
    private var accessToken:String?{
        return nil
    }
    
    private var refreshToken:String?{
        return nil
    }
    
    private var experationDate:Data?{
        return nil
    }
    
    private var shouldRefreshToken:Bool{
        return false
    }
    
    public func exchangeCodeForToken(code:String, completion:@escaping((Bool)->Void)){
        //Get token
        guard let url = URL(string: Constants.tokenAPIURL) else{  return }
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                 URLQueryItem(name: "code", value: code),
                                 URLQueryItem(name: "redirect_uri", value: "https://www.facebook.com/akhadjon.abdukhalilov/") ]
        
        
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("Success: \(json)")
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
        
        
    }
    
    public func cacheToken(){
        
    }
    
    public func refreshAccessToken(){
        
    }
    
}
