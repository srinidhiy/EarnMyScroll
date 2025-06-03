//
//  AuthView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/27/25.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isRegistering = false
    @State private var showConfirmEmail = false
    @Environment(\.dismiss) private var dismiss
    var onLoginSuccess: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Logo or App Name
                        Text("EarnMyScroll")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.top, 50)
                        
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                TextField("", text: $email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                SecureField("", text: $password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Confirm Password Field (only in register mode)
                            if isRegistering {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Confirm Password")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    SecureField("", text: $confirmPassword)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding(.top, 5)
                            }
                            
                            // Action Button
                            Button(action: {
                                Task {
                                    if isRegistering {
                                        if password != confirmPassword {
                                            errorMessage = "Passwords do not match"
                                            return
                                        }
                                        
                                        isLoading = true
                                        await AuthService.shared.register(email: email, password: password) { success, error in
                                            isLoading = false
                                            if success {
                                                showConfirmEmail = true
                                            } else {
                                                errorMessage = error?.localizedDescription
                                            }
                                        }
                                    } else {
                                        isLoading = true
                                        await AuthService.shared.login(email: email, password: password) { success, error in
                                            isLoading = false
                                            if success {
                                                onLoginSuccess()
                                                dismiss()
                                            } else {
                                                errorMessage = error?.localizedDescription
                                            }
                                        }
                                    }
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isRegistering ? "Create Account" : "Sign In")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
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
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .disabled(isLoading)
                            .padding(.top, 10)
                            
                            // Additional Options
                            VStack(spacing: 15) {
                                if !isRegistering {
                                    Button(action: {
                                        // TODO: Implement forgot password
                                    }) {
                                        Text("Forgot your password?")
                                            .foregroundColor(.blue)
                                            .font(.subheadline)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        isRegistering.toggle()
                                        errorMessage = nil
                                    }
                                }) {
                                    Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Register")
                                        .foregroundColor(.blue)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showConfirmEmail) {
                ConfirmEmailView(email: email) {
                    showConfirmEmail = false
                    isRegistering = false
                    email = ""
                    password = ""
                    confirmPassword = ""
                }
            }
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    AuthView(onLoginSuccess: {})
}
