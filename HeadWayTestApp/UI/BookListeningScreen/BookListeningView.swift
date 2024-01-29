//
//  BookListeningView.swift
//  HeadWayTestApp
//

import SwiftUI
import ComposableArchitecture

struct BookListeningView: View {
    
    let store: StoreOf<BookListeningFeature>
    @ObservedObject var viewStore: ViewStoreOf<BookListeningFeature>
    
    init(store: StoreOf<BookListeningFeature>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: { $0 })
    }
    
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
        .onAppear {
            if viewStore.duration == 0 {
                store.send(.fetchAudioDuration)
            }
            store.send(.subscribeToCurrentTime)
        }
    }
    
    @ViewBuilder
    private var slider: some View {
        VStack {
            Slider(value: viewStore.$currentTime, in: 0...viewStore.duration) {
            } minimumValueLabel: {
                sliderLabel(viewStore.currentTimeLocalized)
                    .frame(width: 40, alignment: .leading)
            } maximumValueLabel: {
                sliderLabel(viewStore.durationLocalized)
                    .frame(width: 40, alignment: .trailing)
            } onEditingChanged: { editing in
                if !editing {
                    store.send(.sliderFinishedEditing)
                } else if editing {
                    store.send(.sliderStartedEditing)
                }
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
                store.send(.previousButtonTapped)
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .font(.system(size: 28))
            Button {
                store.send(.gobackwardButtonTapped)
            } label: {
                Image(systemName: "gobackward.5")
            }
            .font(.system(size: 32))
            Button {
                store.send(.pauseButtonTapped)
            } label: {
                Image(systemName: viewStore.isPaused ? "play.fill" : "pause.fill")
            }
            .font(.system(size: 40))
            Button {
                store.send(.goforwardButtonTapped)
            } label: {
                Image(systemName: "goforward.10")
            }
            .font(.system(size: 32))
            Button {
                store.send(.goforwardButtonTapped)
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .font(.system(size: 28))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var modeToggle: some View {
        Toggle(
            isOn: viewStore.$isSoundMode
        ) {
            EmptyView()
        }
        .toggleStyle(ListeningModeToggleStyle())
    }
    
    @ViewBuilder
    private func sliderLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(.gray)
    }
    
}

#Preview {
    let store = Store(initialState: BookListeningFeature.State()) {
        BookListeningFeature()
    }
    return BookListeningView(store: store)
}
