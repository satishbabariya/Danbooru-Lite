//
//  RESTUtils.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Alamofire
import Foundation
import SwiftMessages

struct RESTMeta {
    let statusCode : Int
    let title: String
    let message: String
    let type: Theme
    
    init(statusCode : Int){

        self.statusCode = statusCode
        switch statusCode {
        case 200:
            self.title = Localizations.ok
            self.message = Localizations.reqyestwassucess
            self.type = .success
        case 204:
            self.title = Localizations.nocontent
            self.message = Localizations.reqyestwassucess
            self.type = .success
        case 400:
            self.title = Localizations.badrequest
            self.message = Localizations.thegivanparamcouldnot
            self.type = .error
        case 401:
            self.title = Localizations.unauthorized
            self.message = Localizations.authendicationfailed
            self.type = .error
        case 403:
            self.title = Localizations.forbidden
            self.message = Localizations.authendicationfailed
            self.type = .error
        case 404:
            self.title = Localizations.notfound
            self.message = Localizations.notfound
            self.type = .error
        case 410:
            self.title = Localizations.gone
            self.message = Localizations.paginationliit
            self.type = .error
        case 420:
            self.title = Localizations.invalidrecord
            self.message = Localizations.recordcouldnot
            self.type = .error
        case 422:
            self.title = Localizations.locked
            self.message = Localizations.resourceislocke
            self.type = .error
        case 423:
            self.title = Localizations.alreadyexist
            self.message = Localizations.resourcealreadyexist
            self.type = .error
        case 424:
            self.title = Localizations.invalidparam
            self.message = Localizations.thegivanparamcouldnot
            self.type = .error
        case 429:
            self.title = Localizations.userthrottled
            self.message = Localizations.useristhrottled
            self.type = .error
        case 500:
            self.title = Localizations.internalservererror
            self.message = Localizations.adatabasetimeout
            self.type = .error
        case 503:
            self.title = Localizations.serviceunailable
            self.message = Localizations.servercannot
            self.type = .error
        default:
            self.title = Localizations.serviceunailable
            self.message = Localizations.servercannot
            self.type = .error
        }
    }
    
}

struct RESTError: Error {
    let statusCode : Int
    let title: String
    let message: String
    let type: Theme
}


