import httpclient
import deques, sets
import os, strformat
import htmlparser, xmltree, re

let client = newHttpClient()
let urlRex = re"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"

proc scrape(url: string, target: Regex): (seq[string], seq[string]) =
    let content = client.getContent url
    result[0] = content.findAll target

    try:
        for a in parseHtml(content).findAll("a"):
            let url = a.attr "href"

            if url.match urlRex:
                result[1].add url
    except:
        discard

proc crawl*(root: string, target: Regex, limit: int, delay: int): HashSet[string] =
    var crawled = 0

    var queue = toDeque([root])
    var visited = initHashSet[string]()

    while queue.len > 0 and crawled < limit:
        sleep(delay)

        let url = queue.popLast()
        var hits, urls: seq[string]
        
        try:
            (hits, urls) = url.scrape target
            echo &"scraped {url}"
        except HttpRequestError:
            echo &"failed to scrape {url}"

        for hit in hits:
            result.incl hit

        for url in urls:
            if url notin visited:
                queue.addFirst url
                visited.incl url

        inc crawled

when isMainModule:
    let root = "https://en.wikipedia.org/wiki/Nim_(programming_language)" # root page
    let target = re"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" # email regex
    echo root.crawl(target, 50, 50)