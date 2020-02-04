class Cache(object):

    type = 'Cache'
    size = None
    assoc = None

    # Cache latencies
    tag_latency = None
    data_latency = None
    response_latency = None

    warmup_percentage = 0
    max_miss_count = 0
    
    # Maximum number of outstanding requests
    mshrs = None

    #MSHRs reserved for demand access
    demand_mshr_reserve = 1

    # Maximum number of accesses per MSHR
    tgts_per_mshr = None

    is_read_only = False

    prefetch_on_access = False

    replacement_policy = None

    # Whether tags and data are accessed sequentially
    sequential_access = False

    # Unassigned ports
    cpu_side = None
    mem_side = None

    addr_ranges = []

    def __init__(self):
        pass
