# Giraffe

[![CI Status](http://img.shields.io/travis/derekcoder@gmail.com/Giraffe.svg?style=flat)](https://travis-ci.org/derekcoder@gmail.com/Giraffe)
[![Version](https://img.shields.io/cocoapods/v/Giraffe.svg?style=flat)](http://cocoapods.org/pods/Giraffe)
[![License](https://img.shields.io/cocoapods/l/Giraffe.svg?style=flat)](http://cocoapods.org/pods/Giraffe)
[![Platform](https://img.shields.io/cocoapods/p/Giraffe.svg?style=flat)](http://cocoapods.org/pods/Giraffe)

## Features

- [x] HTTP Method
    - [x] GET
    - [x] POST
    - [x] PUT
    - [x] PATCH
    - [x] DELETE
- [x] HTTP headers
- [x] Cancel request
- [ ] Complete Documentation

## Requirements

- iOS 10.0+
- Swift 5+
- Xcode 10.2+

## Installation

Giraffe is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Giraffe'
```

## Usage

```swift
struct Post {
    let id: Int
    let title: String
    let body: String
}

extension Post {
    static let endPoint = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    init?(json: JSONDictionary) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let body = json["body"] as? String else { return nil }
        self.id = id
        self.title = title
        self.body = body
    }
}

let webservice = Webservice()
```

### GET

```swift
extension Post {
    static var postsResource: Resource<[Post]> {
        return Resource<[Post]>(url: Post.endPoint, parseJSON: { obj in
            guard let json = obj as? [JSONDictionary] else {
                return Result.failure(.invalidResponse)
            }
            let posts = json.compactMap(Post.init)
            return Result.success(posts)
        })
    }
}

webservice.load(Post.postsResource) { response in 
    switch response {
    case .failure(let error): // handle error
    case .success(let posts): // posts: [Post]
    }
}
```

### POST

```swift
extension Post {
    static func createResource(title: String, body: String) -> Resource<Post> {
        let data: JSONDictionary = ["title": title, "body": body]
        return Resource(url: Post.endPoint, jsonMethod: .post(data: data), parseJSON: { obj in
            guard let json = obj as? JSONDictionary,
                let post = Post(json: json) else {
                return Result.failure(.invalidResponse)
            }
            return Result.success(post)
        })
    }
}

let resource = Post.createResource(title: "xxx", body: "xxx")
webservice.load(resource) { response in 
    switch response {
    case .failure(let error): // handle error
    case .success(let post):  // post: Post
    }
}
```

### PUT

```swift
extension Post {
    var updateResource: Resource<Post> {
        let url = Post.endPoint.appendingPathComponent("\(id)")
        let data: JSONDictionary = ["id": id, "title": title, "body": body]
        return Resource(url: url, jsonMethod: .put(data: data), parseJSON: { obj in
            guard let json = obj as? JSONDictionary,
                let post = Post(json: json) else {
                return Result.failure(.invalidResponse)
            }
            return Result.success(post)
        })
    }
}

let post = Post(id: xxx, title: "xxx", body: "xxx")
webservice.load(post.updateResource) { response in 
    switch response {
    case .failure(let error): // handle error
    case .success(let post):  // post: Post
    }
}
```

### PATCH

```swift
extension Post {
    var udpateTitleResource: Resource<Post> {
        let url = Post.endPoint.appendingPathComponent("\(id)")
        let data: JSONDictionary = ["title": title]
        return Resource(url: url, jsonMethod: .patch(data: data), parseJSON: { obj in
            guard let json = obj as? JSONDictionary,
                let post = Post(json: json) else {
                return Result.failure(.invalidResponse)
            }
            return Result.success(post)
        })
    }
}

let post = Post(id: xxx, title: "xxx", body: "xxx")
webservice.load(post.udpateTitleResource) { response in 
    switch response {
    case .failure(let error): // handle error
    case .success(let post):  // post: Post
    }
}
```

### DELETE

```swift
extension Post {
  var deleteResource: Resource<Bool> {
        let url = Post.endPoint.appendingPathComponent("\(id)")
        return Resource(url: url, method: .delete, parse: { _ in
            return Result.success(true)
        })
    }
}

let post = Post(id: xxx, title: "xxx", body: "xxx")
webservice.load(post.deleteResource) { response in 
    switch response {
    case .failure(let error): // handle error
    case .success(let flag):  // flag: Bool
    }
}
```

## Apps Using Giraffe

|<img alt="Coderx" src="https://is2-ssl.mzstatic.com/image/thumb/Purple113/v4/2a/dd/cc/2addccec-4e19-0c9e-49c7-ca9032af70f5/source/100x100bb.jpg" width="48">| 
| :---: |
| [Coderx for GitHub](https://itunes.apple.com/app/apple-store/id1371929193?mt=8) | 

## References

- [Swift Talk](https://talk.objc.io) - [Tiny Networking Library](https://talk.objc.io/episodes/S01E1-tiny-networking-library).
- [@onevcat](https://github.com/onevcat) - [Result<T> 还是 Result<T, E: Error>](https://onevcat.com/2018/10/swift-result-error/)

## License

Giraffe is available under the MIT license. See the LICENSE file for more info.
