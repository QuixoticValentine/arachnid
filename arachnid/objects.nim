import httpclient, options, re, sets

type
    ProxyCycle* = object
        data: seq[Proxy]
        idx: int

    Crawler* = object
        client*: HttpClient
        target*: Regex
        delay*: int
        hits*: seq[string]
        visited*: HashSet[string]
        proxies*: Option[ProxyCycle]

proc initProxyCycle*(arr: openArray[Proxy] = []): ProxyCycle =
    ## Initializes a new `ProxyCycle` object.
    for it in arr:
        result.data.add it

proc next*(cyc: var ProxyCycle): Proxy =
    result = cyc.data[cyc.idx]
    inc cyc.idx

    if cyc.idx > cyc.data.high:
        cyc.idx = 0

proc initCrawler*(target: Regex, delay: int, proxies: seq[string] = @[]): Crawler =
    ## Initializes a new `Crawler` object.
    result.client = newHttpClient()
    result.target = target
    result.delay = delay

    if proxies.len > 0:
        result.proxies = some initProxyCycle()

        for proxy in proxies:
            result.proxies.get.data.add newProxy(proxy)
