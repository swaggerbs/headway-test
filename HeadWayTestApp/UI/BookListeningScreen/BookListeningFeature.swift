//
//  BookListeningFeature.swift
//  HeadWayTestApp
//

import Foundation
import ComposableArchitecture

@Reducer
struct BookListeningFeature {
    
    struct State: Equatable {
        @BindingState var isSoundMode = true
        var isPaused = true
        
        @BindingState var currentTime: TimeInterval = 0
        var currentTimeLocalized: String {
            currentTime.asString()
        }
        
        var duration: TimeInterval = 0
        var durationLocalized: String {
            duration.asString()
        }
    
        var isReadyToPlay = false
        var isErrorWhileLoading = false
        
        var keyPointCount: Int {
            book.keyPoints.count
        }
        var isLastKeypoint: Bool {
            book.keyPoints.count == currentKeypointIndex + 1
        }
        var isFirstKeypoint: Bool {
            currentKeypointIndex == 0
        }
        var keypointTitle: String {
            book.keyPoints[currentKeypointIndex].title
        }
        var currentKeypointNumber: Int {
            currentKeypointIndex + 1
        }
        var currentSpeed = ""

        fileprivate var currentKeypointIndex = 0
        fileprivate var isSliderEditing = false
        
        var book: BookModel
        
        init(book: BookModel) {
            self.book = book
        }
    }
    
    enum Action: BindableAction {
        case pauseButtonTapped
        case nextButtonTapped
        case previousButtonTapped
        case goforwardButtonTapped
        case gobackwardButtonTapped
        case speedButtonTapped
        
        case applyAudioDuration(TimeInterval)
        case updateCurrentTime(TimeInterval)
        case updateCurrentStatus(AudioPlayerSession.Status)
        
        case binding(BindingAction<State>)
        
        case viewDidAppear
        
        case startNewAudio(URL)
        
        case sliderFinishedEditing
        case sliderStartedEditing
        case seekingFinished
        case refresh
    }
    
    private let audioSession = AudioPlayerSession()
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .pauseButtonTapped:
                if state.isPaused  {
                    audioSession.play()
                } else {
                    audioSession.pause()
                }
                state.isPaused.toggle()
                return .none
            case .nextButtonTapped:
                guard !state.isLastKeypoint else {
                    return .none
                }
                state.isReadyToPlay = false
                state.currentKeypointIndex += 1
                let newUrl = state.book.keyPoints[state.currentKeypointIndex].url
                audioSession.replaceItem(assetUrl: newUrl)
                return .send(.startNewAudio(newUrl))
            case .previousButtonTapped:
                guard !state.isFirstKeypoint else {
                    return .none
                }
                state.isReadyToPlay = false
                state.currentKeypointIndex -= 1
                let newUrl = state.book.keyPoints[state.currentKeypointIndex].url
                return .send(.startNewAudio(newUrl))
            case .goforwardButtonTapped:
                return .run { _ in
                    await audioSession.seekForward(for: 10)
                } catch: { error, send in
                    print(error)
                }
            case .gobackwardButtonTapped:
                return .run { _ in
                    await audioSession.seekBackward(for: 5)
                } catch: { error, send in
                    print(error)
                }
            case .speedButtonTapped:
                audioSession.nextSpeed()
                state.currentSpeed = audioSession.currentSpeedLocalized
                return .none
            case let .applyAudioDuration(value):
                state.duration = value
                return .none
            case .viewDidAppear:
                guard let keyPointUrl = state.book.keyPoints.first?.url else {
                    return .none
                }
                state.currentSpeed = audioSession.currentSpeedLocalized
                return .concatenate(
                    .send(.startNewAudio(keyPointUrl)),
                    .publisher {
                        audioSession
                            .currentTime
                            .map { .updateCurrentTime($0) }
                    }
                )
            case let .startNewAudio(url):
                audioSession.replaceItem(assetUrl: url)
                guard let state = audioSession.state else {
                    return .none
                }
                return .merge(
                    .run { send in
                        let time = try await audioSession.getDuration()
                        await send(.applyAudioDuration(time))
                    } catch: { error, send in
                        print(error)
                    },
                    .publisher {
                        state
                            .map { .updateCurrentStatus($0) }
                    }
                )
            case let .updateCurrentTime(value):
                if !state.isSliderEditing {
                    state.currentTime = value
                }
                return .none
            case let .updateCurrentStatus(status):
                if status == .readyToPlay {
                    state.isReadyToPlay = true
                    state.isErrorWhileLoading = false
                } else if status == .failed {
                    state.isErrorWhileLoading = true
                } else {
                    state.isReadyToPlay = false
                }
                return .none
            case .sliderFinishedEditing:
                return .run { [currentTime = state.currentTime] send in
                    await audioSession.seek(to: currentTime)
                    await send(.seekingFinished)
                }
            case .seekingFinished:
                state.isSliderEditing = false
                return .none
            case .sliderStartedEditing:
                state.isSliderEditing = true
                return .none
            case .refresh:
                let url = state.book.keyPoints[state.currentKeypointIndex].url
                return .send(.startNewAudio(url))
            }
        }
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
