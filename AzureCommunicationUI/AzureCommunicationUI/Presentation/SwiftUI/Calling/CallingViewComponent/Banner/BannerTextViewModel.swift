//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BannerTextViewModel: ObservableObject {
    private let localizationProvider: LocalizationProvider
    var title: String = ""
    var body: String = ""
    var linkDisplay: String = ""
    var link: String = ""

    init(localizationProvider: LocalizationProvider) {
        self.localizationProvider = localizationProvider
    }

    func update(bannerInfoType: BannerInfoType?) {
        if let bannerInfoType = bannerInfoType {
            self.title = localizationProvider.getLocalizedString(bannerInfoType.title)
            self.body = localizationProvider.getLocalizedString(bannerInfoType.body)
            self.linkDisplay = localizationProvider.getLocalizedString(bannerInfoType.linkDisplay)
            self.link = bannerInfoType.link
        } else {
            self.title = ""
            self.body = ""
            self.linkDisplay = ""
            self.link = ""
        }
        objectWillChange.send()
    }
}
