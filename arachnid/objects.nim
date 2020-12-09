import httpclient, re, sets

type Crawler* = object
    client*: HttpClient
    target*: Regex
    delay*: int
    hits*: seq[string]
    visited*: HashSet[string]

proc initCrawler*(target: Regex, delay: int): Crawler =
    ## Initializes a new `Crawler` object.
    result.client = newHttpClient()
    result.target = target
    result.delay = delay
