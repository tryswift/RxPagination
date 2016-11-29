# RxPagination

This is the demo project for my presentation at try! Swift conference 2016. 

- Slides: https://speakerdeck.com/ishkawa/protocol-oriented-programming-in-networking
- Video: To be uploaded

## Set Up

- `carthage bootstrap --platform iOS`

## Requirements

- Swift 3.0.1
- Xcode 8.1

## Summary

`PaginationViewModel<Element>` is a view model for pagination. It has an initializer with type parameter `Request` which is constrained to conform to `PaginationRequest` protocol. When `PaginationViewModel<Element>` is instantiate via `init<Request>(baseRequest:)`, the type of its property that represents pagination elements will be inferred as `Observable<[Request.Response.Element]>`.

```swift
final class PaginationViewModel<Element: Decodable> {
    let loading: Observable<Bool>
    let elements: Observable<[Element]>

    init<Request: PaginationRequest>(baseRequest: Request) where Request.Response.Element == Element {...}
}
```

## Contact

Twitter: https://twitter.com/_ishkawa

