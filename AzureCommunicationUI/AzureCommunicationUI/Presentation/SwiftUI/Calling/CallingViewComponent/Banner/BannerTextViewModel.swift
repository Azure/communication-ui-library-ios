//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BannerTextViewModel: ObservableObject {
    var title: String = ""
    var body: String = ""
    var linkDisplay: String = ""
    var link: String = ""

    func update(bannerInfoType: BannerInfoType?) {
        if let bannerInfoType = bannerInfoType {
            self.title = bannerInfoType.title
            self.body = bannerInfoType.body
            self.linkDisplay = bannerInfoType.linkDisplay
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
