//
//  NaverReverseGeocodingResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import Foundation

// MARK: - 역지오코딩 응답 모델
struct NaverReverseGeocodingResponse: Codable {
    let status: Status
    let results: [Result]

    struct Status: Codable {
        let code: Int
        let name: String
        let message: String
    }

    struct Result: Codable {
        let name: String
        let code: Code
        let region: Region?
        let land: Land?

        struct Code: Codable {
            let id: String
            let type: String
            let mappingId: String
        }

        struct Region: Codable {
            let area0: Area?
            let area1: Area?
            let area2: Area?
            let area3: Area?
            let area4: Area?

            struct Area: Codable {
                let name: String
                let coords: Coords
                let alias: String?

                struct Coords: Codable {
                    let center: Center

                    struct Center: Codable {
                        let crs: String
                        let x: Double
                        let y: Double
                    }
                }
            }
        }

        struct Land: Codable {
            let type: String
            let number1: String?
            let number2: String?
            let addition0: Addition?
            let addition1: Addition?
            let addition2: Addition?
            let addition3: Addition?
            let addition4: Addition?
            let coords: Coords?

            struct Addition: Codable {
                let type: String
                let value: String
            }

            struct Coords: Codable {
                let center: Center

                struct Center: Codable {
                    let crs: String
                    let x: Double
                    let y: Double
                }
            }
        }
    }
}
