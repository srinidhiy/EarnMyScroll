//
//  OnboardingView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var title = ""
    @State private var proofType = "Photo"
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Your Daily Goal")
                .font(.title)

            TextField("Goal Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Proof Type", selection: $proofType) {
                Text("Photo").tag("Photo")
                Text("GPS").tag("GPS")
                Text("Health").tag("Health")
            }

            Button("Save Goal") {
                let goal = Goal(
                    id: UUID(),
                    userId: "mock-user-id",
                    title: title,
                    proofType: proofType,
                    isCompleted: false
                )
                SupabaseService.shared.createGoal(goal) { result in
                    switch result {
                    case .success():
                        print("Saved!")
                        onComplete()
                    case .failure(let error):
                        print("Failed: \(error)")
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
