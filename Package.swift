// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "NYTPhotoViewer",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "NYTPhotoViewer",
            targets: ["NYTPhotoViewer"]
        ),
    ],
    targets: [
        .target(
            name: "NYTPhotoViewer",
            path: "NYTPhotoViewer"
        )
    ]
)
