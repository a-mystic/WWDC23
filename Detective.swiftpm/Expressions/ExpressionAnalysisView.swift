//
//  SwiftUIView 2.swift
//  
//
//  Created by a mystic on 2023/04/12.
//

import SwiftUI
import Charts

struct ExpressionAnalysisView: View {
    @EnvironmentObject var detective: Detective
    
    @State private var expressions = ["😁" : 0, "🙂" : 0, "😡" : 0, "😠" : 0, "😛" : 0, "😮" : 0]
    @State private var maxRatio: CGFloat = 0
    @State private var maxKey = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                chart(size: geometry)
                Spacer().frame(height: geometry.size.height/20)
                analyzedResult
            }
        }.onAppear {
            if !needExpression {
                detective.expressions.forEach { key, value in
                    withAnimation(.easeInOut(duration: randomDuration())) {
                        expressions[key] = value
                    }
                }
                if let maxKey = maxExpression() {
                    self.maxKey = maxKey
                    let sum = expressions.values.reduce(0) { $0 + $1 }
                    maxRatio = (CGFloat(expressions[maxKey]!) / CGFloat(sum)) * 100
                }
                analyzeExpression()
            }
        }
    }
    
    func chart(size geometry: GeometryProxy) -> some View {
        Chart {
            ForEach(expressions.shuffled(), id: \.key) { key, value in
                BarMark(x: .value("expression", key), y: .value("count", value))
                    .foregroundStyle(Color.black.gradient)
                    .cornerRadius(10)
            }
        }
        .frame(height: geometry.frame(in: .local).size.height/2)
        .padding()
    }
    
    var analyzedResult: some View {
        VStack {
            if needExpression {
                Text("need some facial expressions, so please record facial expressions.")
            } else {
                List {
                    Text("the expression that appeared the most was \(maxKey) and the percentage of all expressions was \(maxRatio)%.")
                    Text("my analyzing is that \(description)")
                }
                .foregroundColor(.primary)
                .font(.body)
                Spacer()
                reset
                Spacer()
            }
        }
    }
    
    var reset: some View {
        Button {
            detective.resetExpressions()
            detective.expressions.keys.forEach { key in
                withAnimation(.easeInOut(duration: randomDuration())) {
                    expressions[key] = 0
            }
        }
        } label: {
            Text("Reset")
        }
    }
    
    private var needExpression: Bool {
        let sum = detective.expressions.values.reduce(0) { $0 + $1 }
        return sum <= 0
    }
    
    private func maxExpression() -> String? {
        let maximum = detective.expressions.max { $0.value < $1.value }
        if let maximum = maximum {
            return maximum.key
        }
        return nil
    }
    
    private func randomDuration() -> Double {
        return Double.random(in: 0..<Double(3.4))
    }
    
    @State private var description = ""
    
    private func analyzeExpression() {
        switch maxKey {
        case "😁": description = "this person looks very happy."
        case "🙂": description = "this person looks a little happy."
        case "😡": description = "this person looks very angry."
        case "😠": description = "this person looks a little angry."
        case "😛": description = "this person seems to be joking."
        case "😮": description = "this person looks surprised."
        default: break
        }
    }
}
