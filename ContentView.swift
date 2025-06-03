//
//  ContentView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isAuthenticated = false
    @State private var showOnboarding = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView().onAppear{
                    checkAuthStatus()
                }
            } else if !isAuthenticated {
                AuthView(onLoginSuccess: {
                    isLoading = true
                    checkAuthStatus()
                })
            } else if showOnboarding {
                OnboardingView {
                    completeOnboarding()
                }
            } else {
                TabView(selection: $selectedTab) {
                    // Home Tab
                    NavigationStack {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    // Goals Tab
                    NavigationStack {
                        GoalsView()
                    }
                    .tabItem {
                        Label("Goals", systemImage: "target")
                    }
                    .tag(1)
                    
                    // Profile Tab
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(2)
                }
            }
        }
    }
    
    private func checkAuthStatus() {
        Task {
            do {
                print("Checking auth status...")
                let session = try await SupabaseService.shared.getCurrentSession()
                print("Got session: \(session)")
                let userId = session.user.id
                print("User ID: \(userId)")
                SupabaseService.shared.getUser(userId: userId) { result in
                    isLoading = false
                    switch result {
                    case .success(let user):
                        print("Got user: \(user)")
                        isAuthenticated = true
                        showOnboarding = !(user.is_onboarded ?? false)
                    case .failure(let error):
                        print("Failed to get user: \(error)")
                        isAuthenticated = false
                        showOnboarding = false
                    }
                }
            } catch {
                print("Error getting session: \(error)")
                isLoading = false
                isAuthenticated = false
                showOnboarding = false
            }
        }
    }
    
    private func completeOnboarding() {
        // Update user's onboarding status in Supabase
        Task {
            do {
                let user = try await SupabaseService.shared.getCurrentSession().user
                let client = try await SupabaseService.shared.getSupabaseClient()
                try await client
                    .from("profiles")
                    .update(["is_onboarded": true])
                    .eq("id", value: user.id)
                    .execute()
                showOnboarding = false
            } catch {
                print("Error updating onboarding status: \(error)")
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome Back!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track your progress and earn rewards")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Stats Section
                HStack(spacing: 15) {
                    StatCard(title: "Active Goals", value: "3", icon: "target")
                    StatCard(title: "Points Earned", value: "250", icon: "star.fill")
                }
                .padding(.horizontal)
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(1...3, id: \.self) { _ in
                        ActivityCard()
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Home")
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct ActivityCard: View {
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Completed Goal")
                    .font(.headline)
                Text("No social media for 2 hours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("+50 pts")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
    }
}

struct GoalsView: View {
    var body: some View {
        Text("Goals View")
            .navigationTitle("Goals")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
            .navigationTitle("Profile")
    }
}

#Preview {
    ContentView()
}

