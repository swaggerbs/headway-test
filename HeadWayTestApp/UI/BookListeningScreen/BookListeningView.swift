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
                AsyncImage(url: viewStore.book.imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 300)
                        .clipped()
                } placeholder: {
                    Color.gray
                        .frame(width: 200, height: 300)
                }
                Text("KEY POINT \(viewStore.currentKeypointNumber) OF \(viewStore.keyPointCount)")
                    .foregroundStyle(.gray)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.top, 25)
                if viewStore.isReadyToPlay {
                    Text(viewStore.keypointTitle)
                        .padding(.horizontal, 40)
                        .padding(.top, 1)
                        .lineLimit(2)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .frame(height: 50, alignment: .center)
                } else {
                    ProgressView()
                        .frame(height: 50, alignment: .center)
                }
                slider
                    .disabled(!viewStore.isReadyToPlay)
                toolbar
                    .padding(.vertical, 40)
                modeToggle
            }
        }
        .onAppear {
            store.send(.viewDidAppear)
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
                store.send(.speedButtonTapped)
            } label: {
                Text("Speed \(viewStore.currentSpeed)")
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
            .disabled(viewStore.isFirstKeypoint)
            .disabled(!viewStore.isReadyToPlay)
            Button {
                store.send(.gobackwardButtonTapped)
            } label: {
                Image(systemName: "gobackward.5")
            }
            .font(.system(size: 32))
            .disabled(!viewStore.isReadyToPlay)
            Button {
                if viewStore.isErrorWhileLoading {
                    store.send(.refresh)
                } else {
                    store.send(.pauseButtonTapped)
                }
            } label: {
                if viewStore.isErrorWhileLoading {
                    Image(systemName: "arrow.clockwise")
                } else {
                    Image(systemName: viewStore.isPaused ? "play.fill" : "pause.fill")
                }
            }
            .font(.system(size: 40))
            .disabled(!viewStore.isReadyToPlay && !viewStore.isErrorWhileLoading)
            Button {
                store.send(.goforwardButtonTapped)
            } label: {
                Image(systemName: "goforward.10")
            }
            .font(.system(size: 32))
            
            .disabled(!viewStore.isReadyToPlay)
            Button {
                store.send(.nextButtonTapped)
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .font(.system(size: 28))
            .disabled(viewStore.isLastKeypoint)
            .disabled(!viewStore.isReadyToPlay)
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
    let store = Store(initialState: BookListeningFeature.State(book: BookModel(title: "", imageUrl: URL(fileURLWithPath: ""), keyPoints: []))) {
        BookListeningFeature()
    }
    return BookListeningView(store: store)
}
