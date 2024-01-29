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
        
        fileprivate var isSliderEditing = false
    }
    
    enum Action: BindableAction {
        case pauseButtonTapped
        case nextButtonTapped
        case previousButtonTapped
        case goforwardButtonTapped
        case gobackwardButtonTapped
        case speedButtonTapped
        case fetchAudioDuration
        case applyAudioDuration(TimeInterval)
        case subscribeToCurrentTime
        case updateCurrenTime(TimeInterval)
        case binding(BindingAction<State>)
        
        case sliderFinishedEditing
        case sliderStartedEditing
        case seekingFinished
    }
    
    private let playerSession = AudioPlayerSession(url: URL(string: "https://ia801301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_001_browning_128kb.mp3")!)
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .pauseButtonTapped:
                if state.isPaused  {
                    playerSession.play()
                } else {
                    playerSession.pause()
                }
                state.isPaused.toggle()
                return .none
            case .nextButtonTapped:
                return .none
            case .previousButtonTapped:
                return .none
            case .goforwardButtonTapped:
                return .none
            case .gobackwardButtonTapped:
                return .none
            case .speedButtonTapped:
                return .none
            case .fetchAudioDuration:
                return .run { send in
                    let time = try await playerSession.getDuration()
                    await send(.applyAudioDuration(time))
                }
            case let .applyAudioDuration(value):
                state.duration = value
                return .none
            case .subscribeToCurrentTime:
                return .publisher {
                    playerSession
                        .currentTime
                        .map { .updateCurrenTime($0) }
                }
            case let .updateCurrenTime(value):
                if !state.isSliderEditing {
                    state.currentTime = value
                }
                return .none
            case .sliderFinishedEditing:
                return .run { [currentTime = state.currentTime] send in
                    await playerSession.seek(to: currentTime)
                    await send(.seekingFinished)
                }
            case .seekingFinished:
                state.isSliderEditing = false
                return .none
            case .sliderStartedEditing:
                state.isSliderEditing = true
                return .none
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
