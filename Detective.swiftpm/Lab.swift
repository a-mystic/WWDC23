//
//  Lab.swift
//  Detective
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI

struct Lab: View {
    @EnvironmentObject var detective: Detective
        
    init() {
        DetectiveViewController().detectPlane()
    }
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Image") { ImageView() }
                NavigationLink("Memo") { MemoView() }
                NavigationLink("Facial Expression") { FacialExpressionView() }
                NavigationLink("Expression Analysis") { ExpressionAnalysisView() }
            }
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Close() } }
            .navigationTitle("Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
