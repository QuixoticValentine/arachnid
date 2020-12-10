import deques, htmlparser, httpclient, objects, os, re, sets, xmltree

let urlRex = re"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"

proc scrape(crawler: var Crawler, url: string): (seq[string], seq[string]) =
    let content = crawler.client.getContent url
    result[0] = content.findAll crawler.target

    if not crawler.proxies.empty:
        let proxy = crawler.proxies.next
        crawler.client = newHttpClient(proxy = proxy)

    try:
        for a in parseHtml(content).findAll("a"):
            let url = a.attr "href"

            if url.match urlRex:
                result[1].add url
    except:
        discard

proc crawl*(crawler: var Crawler, roots: seq[string], limit: int) =
    var crawled = 0
    var queue = toDeque(roots)

    while queue.len > 0 and crawled < limit:
        sleep crawler.delay

        let url = queue.popLast()
        var hits, urls: seq[string]

        try:
            (hits, urls) = crawler.scrape url
        except HttpRequestError:
            let err = "failed to load " & url
            let file = open "log.txt", fmAppend
            f.writeLine err
            f.close
            continue

        crawler.hits &= hits

        for url in urls:
            if url notin crawler.visited:
                queue.addFirst url
                crawler.visited.incl url

        inc crawled
