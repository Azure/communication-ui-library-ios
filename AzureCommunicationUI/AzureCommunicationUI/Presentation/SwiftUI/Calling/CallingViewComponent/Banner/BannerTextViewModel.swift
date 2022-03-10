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
            self.title = bannerInfoType.getTitle(localizationProvider)
            self.body = bannerInfoType.getBody(localizationProvider)
            self.linkDisplay = bannerInfoType.getLinkDisplay(localizationProvider)
            self.link = bannerInfoType.getLink()
        } else {
            self.title = ""
            self.body = ""
            self.linkDisplay = ""
            self.link = ""
        }
        objectWillChange.send()
    }
}
