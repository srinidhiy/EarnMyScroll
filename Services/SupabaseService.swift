//
//  SupabaseService.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        // Initialize the Supabase client
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    func createGoal(_ goal: Goal, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await client.from("goals")
                    .insert(goal)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getUser(userId: UUID, completion: @escaping (Result<User, Error>) -> Void) {
        Task {
            do {
                let userIdString = userId.uuidString.lowercased()
                
                let users: [User] = try await client.from("profiles")
                    .select("*")
                    .eq("id", value: userIdString)
                    .execute()
                    .value
            
                if let user = users.first {
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getCurrentSession() async throws -> Session {
        return try await client.auth.session
    }

    func getSupabaseClient() async throws -> SupabaseClient {
        return client
    }
    
//    func uploadProof(goalId: UUID, imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
//        Task {
//            do {
//                // First upload the image to Supabase Storage
//                let fileName = "\(goalId)-\(UUID().uuidString).jpg"
//                let filePath = "proofs/\(fileName)"
//                
//                try await client.storage
//                    .from("proofs")
//                    .upload(
//                        path: filePath,
//                        file: imageData
//                    )
//                
//                // Then call your Edge Function
//                let response: () = try await client.functions
//                    .invoke("verify-proof", 
//                           options: .init(
//                            body: [
//                                "goal_id": goalId.uuidString,
//                                "image_path": filePath
//                            ]
//                           ))
//                
//                if let verdict = try? response.data["verdict"] as? String {
//                    completion(.success(verdict))
//                } else {
//                    completion(.failure(NSError(domain: "", code: -1)))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
}
