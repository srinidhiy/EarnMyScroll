//
//  User.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 6/3/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var email: String?
    var full_name: String?
    var username: String?
    var avatar_url: String?
    var is_onboarded: Bool?
    var goals_id: [Int8]?
}