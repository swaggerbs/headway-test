//
//  BookListeningView.swift
//  HeadWayTestApp
//

import SwiftUI

struct BookListeningView: View {
    
    @State var sliderValue: Double = 0
    
    var body: some View {
        ZStack {
            Color.brown.opacity(0.15)
                .ignoresSafeArea()
            VStack {
                Rectangle()
                    .frame(width: 200, height: 300)
                Text("KEY POINT 2 OF 10")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 25)
                Text("Design is not how a thing looks, but how it works")
                    .padding(.horizontal, 40)
                    .padding(.top, 1)
                    .lineLimit(2)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                slider
                toolbar
                    .padding(.vertical, 40)
                modeToggle
            }
        }
    }
    
    @ViewBuilder
    private var slider: some View {
        VStack {
            Slider(value: $sliderValue, in: 0...300) {
            } minimumValueLabel: {
                sliderLabel(sliderValue.asString())
            } maximumValueLabel: {
                sliderLabel(300.asString())
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            Button {
                
            } label: {
                Text("Speed x1")
                    .padding(10)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.primary)
            .background(.gray.secondary.opacity(0.3))
            .clipShape(.rect(cornerRadius: 6))
            .padding(.top, 5)
        }
    }
    
    @ViewBuilder
    private var toolbar: some View {
        HStack(spacing: 26) {
            Button {
                
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .font(.system(size: 28))
            Button {
                
            } label: {
                Image(systemName: "gobackward.5")
            }
            .font(.system(size: 32))
            Button {
                
            } label: {
                Image(systemName: "pause.fill")
            }
            .font(.system(size: 40))
            Button {
                
            } label: {
                Image(systemName: "goforward.10")
            }
            .font(.system(size: 32))
            Button {
                
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .font(.system(size: 28))
        }
        .buttonStyle(.plain)
    }
    
    @State var isSound: Bool = true
    
    @ViewBuilder
    private var modeToggle: some View {
        Toggle(isOn: $isSound, label: {
            Text("Active")
        })
        .toggleStyle(ListeningModeToggleStyle())
    }
    
    @ViewBuilder
    private func sliderLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(.gray)
    }
    
}

fileprivate extension Double {
    
    func asString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? ""
    }
    
}

#Preview {
    BookListeningView()
}
