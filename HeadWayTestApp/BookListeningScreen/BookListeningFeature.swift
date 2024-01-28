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
        var isPaused = false
    }
    
    enum Action: BindableAction {
        case pauseButtonTapped
        case nextButtonTapped
        case previousButtonTapped
        case goforwardButtonTapped
        case gobackwardButtonTapped
        case speedButtonTapped
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .pauseButtonTapped:
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
            }
        }
    }
}
