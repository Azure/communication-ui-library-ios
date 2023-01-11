//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

protocol PermissionsManagerProtocol {
    func resolveStatus(for permission: AppPermission) -> AppPermission.Status
    func request(_ permission: AppPermission) -> Future<AppPermission.Status, Never>
}

class PermissionsManager: PermissionsManagerProtocol {
    private var audioPermission: AppPermission.Status?
    private var cameraPermission: AppPermission.Status?
    private let store: Store<AppState, Action>
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>) {
        self.store = store
        store.$state
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        let permissionState = state.permissionState
        if audioPermission != permissionState.audioPermission {
            audioPermission = permissionState.audioPermission
            handle(permission: .audioPermission,
                   state: permissionState.audioPermission)
        }
        if cameraPermission != permissionState.cameraPermission {
            cameraPermission = permissionState.cameraPermission
            handle(permission: .cameraPermission,
                   state: permissionState.cameraPermission)
        }
    }

    private func handle(permission: AppPermission, state: AppPermission.Status) {
        switch state {
        case .unknown:
            let state = resolveStatus(for: permission)
            self.setPermissionState(permission: permission, state: state)
        case .requesting:
            request(permission)
                .sink(receiveValue: { [weak self] state in
                    guard let self = self else {
                        return
                    }

                    self.setPermissionState(permission: permission, state: state)
                }).store(in: &cancellables)
        default:
            break
        }
    }

    private func setPermissionState(permission: AppPermission, state: AppPermission.Status) {
        let setPermission = PermissionAction.generateAction(permission: permission, state: state)
        self.store.dispatch(action: .permissionAction(setPermission))
    }

    func resolveStatus(for permission: AppPermission) -> AppPermission.Status {
        switch permission {
        case .audioPermission:
            return getAudioPermissionStatus()
        case .cameraPermission:
            return getVideoPermissionStatus()
        }
    }

    func request(_ permission: AppPermission) -> Future<AppPermission.Status, Never> {
        switch permission {
        case .audioPermission:
            return requestAudioPermissions()
        case .cameraPermission:
            return requestVideoPermissions()
        }
    }
}

// MARK: - Push Notifications

extension AVAudioSession.RecordPermission {
    var map: AppPermission.Status {
        switch self {
        case .denied:
            return .denied
        case .granted:
            return .granted
        case .undetermined:
            return .notAsked
        @unknown default:
            return .notAsked
        }
    }
}

extension AVAuthorizationStatus {
    var map: AppPermission.Status {
        switch self {
        case .denied,
             .restricted:
            return .denied
        case .authorized:
            return .granted
        case .notDetermined:
            return .notAsked
        @unknown default:
            return .notAsked
        }
    }
}

private extension PermissionsManager {

    func getAudioPermissionStatus() -> AppPermission.Status {
        let audioSession = AVAudioSession.sharedInstance().recordPermission
        return audioSession.map

    }

    func getVideoPermissionStatus() -> AppPermission.Status {
        let audioSession = AVCaptureDevice.authorizationStatus(for: .video)
        return audioSession.map

    }

    func requestAudioPermissions() -> Future<AppPermission.Status, Never> {
        return Future { promise in

            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] _ in
                promise(Result.success(self?.getAudioPermissionStatus() ?? .unknown))
            }
        }
    }

    func requestVideoPermissions() -> Future<AppPermission.Status, Never> {
        return Future { promise in

            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in

                promise(Result.success(self?.getVideoPermissionStatus() ?? .unknown))
            }
        }
    }
}
