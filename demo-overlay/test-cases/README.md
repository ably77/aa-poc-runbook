-Single cluster route tls
```
routing-tls-single-upstream.sh
```

-Canary (optional)
```
routing-weighted-canary-reviews-v1.sh
routing-weighted-canary-reviews-v2.sh
```

-Routing across cluster to single service on cluster 2
```
routing-federation-reviews.sh
```

-Locality and failover: sticky, failover on 1 by scaling deployment to 0. Use outlier detection to failover/failback
```
routing-federation-failover.sh
```

-Show open trust
-Show zero trust
```
security-zero-trust.sh
```