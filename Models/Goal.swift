//
//  Goal.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var userId: String
    var title: String
    var proofType: String
    var isCompleted: Bool
}
