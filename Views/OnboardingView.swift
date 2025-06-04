//
//  OnboardingView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var username = ""
    @State private var fullName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var goals: [Goal] = []
    @State private var newGoalTitle = ""
    @State private var selectedApps: Set<String> = []
    @State private var showingPhotoPicker = false
    
    let availableApps = [
        "Instagram", "TikTok", "Facebook", "Twitter", "YouTube",
        "Reddit", "Pinterest", "Snapchat", "WhatsApp", "LinkedIn"
    ]
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Step content
                TabView(selection: $currentStep) {
                    // Step 1: Profile Setup
                    profileSetupView
                        .tag(0)
                    
                    // Step 2: Goals Setup
                    goalsSetupView
                        .tag(1)
                    
                    // Step 3: App Selection
                    appSelectionView
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            saveOnboardingData()
                        }
                    }) {
                        Text(currentStep == 2 ? "Complete" : "Next")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 120)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Step 1: Profile Setup
    private var profileSetupView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Create Your Profile")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Profile Picture
                VStack {
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 7)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Text("Add Photo")
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                }
                .onChange(of: selectedPhoto) { newValue, _ in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            profileImage = Image(uiImage: uiImage)
                        }
                    }
                }
                
                // Username Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    TextField("", text: $username)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                // Full Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    TextField("", text: $fullName)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 2: Goals Setup
    private var goalsSetupView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Set Your Goals")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Add Goal Section
                VStack(spacing: 15) {
                    TextField("Enter goal title", text: $newGoalTitle)
                        .textFieldStyle(OnboardingTextFieldStyle())
                    
                    Button(action: addGoal) {
                        Label("Add Goal", systemImage: "plus.circle.fill")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                }
                
                // Goals List
                VStack(spacing: 15) {
                    ForEach(goals) { goal in
                        HStack {
                            Text(goal.title)
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: { removeGoal(goal) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 3: App Selection
    private var appSelectionView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Select Apps to Monitor")
                    .font(.title)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(availableApps, id: \.self) { app in
                        AppSelectionCard(
                            appName: app,
                            isSelected: selectedApps.contains(app),
                            action: { toggleApp(app) }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    private func addGoal() {
        guard !newGoalTitle.isEmpty else { return }
        let goal = Goal(
            id: UUID(),
            userId: "mock-user-id",
            title: newGoalTitle,
            proofType: "Photo",
            isCompleted: false
        )
        goals.append(goal)
        newGoalTitle = ""
    }
    
    private func removeGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
    }
    
    private func toggleApp(_ app: String) {
        if selectedApps.contains(app) {
            selectedApps.remove(app)
        } else {
            selectedApps.insert(app)
        }
    }
    
    private func saveOnboardingData() {
        // TODO: Save all onboarding data to Supabase
        // This would include:
        // - Profile information (username, fullName, profileImage)
        // - Goals
        // - Selected apps
        onComplete()
    }
}

// MARK: - Supporting Views
struct AppSelectionCard: View {
    let appName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "app.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(appName)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
    }
}

// MARK: - Custom TextField Style
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
