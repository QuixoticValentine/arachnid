import arachnid/[objects, functions]

when isMainModule:
    import re, sets

    let target = re"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" # email regex
    var crawler = initCrawler(target, 10)

    let root = @["https://en.wikipedia.org/wiki/Nim_(programming_language)"] # root page

    crawler.crawl(root, 100)
    echo toHashSet(crawler.hits)