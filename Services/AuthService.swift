//
//  AuthService.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/27/25.
//

import Foundation
import Supabase

class AuthService {
    static let shared = AuthService()
    
    private let client: SupabaseClient
    
    private init() {
        // Initialize the Supabase client
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    func register(email: String, password: String, completion: @escaping (_ isSucceed: Bool, _ error: Error?) -> Void) async {
        do {
            try await client.auth.signUp(email: email, password: password)
            completion(true, nil)
        } catch {
            print("Failed to register. \(error.localizedDescription)")
            completion(false, error)
        }
    }
    
    
    func login(email: String, password: String, completion: @escaping (_ isSucceed: Bool, _ error: Error?) -> Void) async {
        do {
            print("Attempting login for email: \(email)")
            let response = try await client.auth.signIn(email: email, password: password)
            print("Login response: \(response)")
            let session = try await client.auth.session
            print("Session after login: \(session)")
            completion(true, nil)
        } catch {
            print("Failed to log in. \(error.localizedDescription)")
            completion(false, error)
        }
    }
    
}
