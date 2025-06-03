//
//  ConfirmEmailView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 6/3/25.
//

import SwiftUI

struct ConfirmEmailView: View {
    let email: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "envelope.badge")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 50)
            
            Text("Check Your Email")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We've sent a confirmation email to:")
                .foregroundColor(.secondary)
            
            Text(email)
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Please check your email and click the confirmation link to activate your account.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: onComplete) {
                Text("Return to Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ConfirmEmailView(email: "test@example.com") {}
}
