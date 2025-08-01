//
//  AuthConfiguration.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/1/25.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: "GkDDtvymFKHbCwm_PaAZD2VrF3yCzhdy2AXkq2f1jcU",
            secretKey: "KPPMv8Hgjw8zF_liQS4ZX6GELcYuDhFnHVq4WnNgu8A",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize"
        )
    }
}


