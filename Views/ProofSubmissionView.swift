//
//  ProofSubmissionView.swift
//  EarnMyScroll
//
//  Created by Srinidhi Yerraguntala on 5/18/25.
//

import SwiftUI
import PhotosUI

struct ProofSubmissionView: View {
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false

    var goalId: UUID

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }

            Button("Upload Photo") {
                isPickerPresented = true
            }

//            if selectedImage != nil {
//                Button("Submit Proof") {
//                    if let data = selectedImage?.jpegData(compressionQuality: 0.8) {
//                        SupabaseService.shared.uploadProof(goalId: goalId, imageData: data) { result in
//                            switch result {
//                            case .success(let verdict): print("Verdict: \(verdict)")
//                            case .failure(let error): print("Error: \(error)")
//                            }
//                        }
//                    }
//                }
//            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(image: $selectedImage)
        }
    }
}

#Preview {
    ProofSubmissionView(goalId: UUID())
}
