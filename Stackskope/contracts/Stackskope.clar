;; StackScope Analytics Platform
;; A smart contract for collecting and managing blockchain analytics data

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-data (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var platform-fee uint u1000) ;; 0.1% in basis points
(define-data-var total-metrics-recorded uint u0)
(define-data-var analytics-enabled bool true)

;; Data Maps
(define-map authorized-reporters principal bool)

;; DeFi Protocol Metrics
(define-map protocol-tvl 
    { protocol: (string-ascii 50), height: uint }
    { 
        tvl-amount: uint,
        timestamp: uint,
        reporter: principal 
    }
)

;; Transaction Volume Metrics
(define-map daily-volume
    { date: (string-ascii 10) } ;; YYYY-MM-DD format
    {
        total-volume: uint,
        transaction-count: uint,
        unique-addresses: uint,
        last-updated: uint
    }
)

;; Token Analytics
(define-map token-metrics
    { token-contract: principal, height: uint }
    {
        price: uint, ;; in microSTX
        volume-24h: uint,
        market-cap: uint,
        holders-count: uint,
        timestamp: uint
    }
)

;; Protocol Analytics
(define-map protocol-analytics
    { protocol: (string-ascii 50) }
    {
        total-users: uint,
        total-transactions: uint,
        active-users-24h: uint,
        fees-collected: uint,
        creation-date: uint
    }
)

;; Network Health Metrics
(define-map network-health
    { metric-type: (string-ascii 30), height: uint }
    {
        value: uint,
        timestamp: uint,
        reporter: principal
    }
)

;; Read-only functions

;; Get protocol TVL at specific block height
(define-read-only (get-protocol-tvl (protocol (string-ascii 50)) (height uint))
    (map-get? protocol-tvl { protocol: protocol, height: height }))

;; Get daily volume metrics
(define-read-only (get-daily-volume (date (string-ascii 10)))
    (map-get? daily-volume { date: date }))

;; Get token metrics
(define-read-only (get-token-metrics (token-contract principal) (height uint))
    (map-get? token-metrics { token-contract: token-contract, height: height }))

;; Get protocol analytics
(define-read-only (get-protocol-analytics (protocol (string-ascii 50)))
    (map-get? protocol-analytics { protocol: protocol }))

;; Get network health metric
(define-read-only (get-network-health (metric-type (string-ascii 30)) (height uint))
    (map-get? network-health { metric-type: metric-type, height: height }))

;; Get platform statistics
(define-read-only (get-platform-stats)
    (ok {
        total-metrics: (var-get total-metrics-recorded),
        platform-fee: (var-get platform-fee),
        analytics-enabled: (var-get analytics-enabled)
    }))

;; Check if reporter is authorized
(define-read-only (is-authorized-reporter (reporter principal))
    (default-to false (map-get? authorized-reporters reporter)))

;; Public functions

;; Record protocol TVL
(define-public (record-protocol-tvl 
    (protocol (string-ascii 50)) 
    (tvl-amount uint)
    (height uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        (asserts! (> tvl-amount u0) err-invalid-data)
        
        (map-set protocol-tvl 
            { protocol: protocol, height: height }
            {
                tvl-amount: tvl-amount,
                timestamp: stacks-block-height,
                reporter: tx-sender
            })
        
        (var-set total-metrics-recorded 
            (+ (var-get total-metrics-recorded) u1))
        (ok true)))

;; Record daily volume
(define-public (record-daily-volume
    (date (string-ascii 10))
    (total-volume uint)
    (transaction-count uint)
    (unique-addresses uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        
        (map-set daily-volume
            { date: date }
            {
                total-volume: total-volume,
                transaction-count: transaction-count,
                unique-addresses: unique-addresses,
                last-updated: stacks-block-height
            })
        
        (var-set total-metrics-recorded 
            (+ (var-get total-metrics-recorded) u1))
        (ok true)))

;; Record token metrics
(define-public (record-token-metrics
    (token-contract principal)
    (height uint)
    (price uint)
    (volume-24h uint)
    (market-cap uint)
    (holders-count uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        
        (map-set token-metrics
            { token-contract: token-contract, height: height }
            {
                price: price,
                volume-24h: volume-24h,
                market-cap: market-cap,
                holders-count: holders-count,
                timestamp: stacks-block-height
            })
        
        (var-set total-metrics-recorded 
            (+ (var-get total-metrics-recorded) u1))
        (ok true)))

;; Update protocol analytics
(define-public (update-protocol-analytics
    (protocol (string-ascii 50))
    (total-users uint)
    (total-transactions uint)
    (active-users-24h uint)
    (fees-collected uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        
        (map-set protocol-analytics
            { protocol: protocol }
            {
                total-users: total-users,
                total-transactions: total-transactions,
                active-users-24h: active-users-24h,
                fees-collected: fees-collected,
                creation-date: (default-to stacks-block-height 
                    (get creation-date (map-get? protocol-analytics { protocol: protocol })))
            })
        
        (var-set total-metrics-recorded 
            (+ (var-get total-metrics-recorded) u1))
        (ok true)))

;; Record network health metrics
(define-public (record-network-health
    (metric-type (string-ascii 30))
    (value uint)
    (height uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        
        (map-set network-health
            { metric-type: metric-type, height: height }
            {
                value: value,
                timestamp: stacks-block-height,
                reporter: tx-sender
            })
        
        (var-set total-metrics-recorded 
            (+ (var-get total-metrics-recorded) u1))
        (ok true)))

;; Admin functions

;; Add authorized reporter
(define-public (add-authorized-reporter (reporter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-reporters reporter true)
        (ok true)))

;; Remove authorized reporter
(define-public (remove-authorized-reporter (reporter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-reporters reporter)
        (ok true)))

;; Update platform fee
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u10000) err-invalid-data) ;; Max 10%
        (var-set platform-fee new-fee)
        (ok true)))

;; Toggle analytics collection
(define-public (toggle-analytics (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set analytics-enabled enabled)
        (ok true)))

;; Bulk data recording function
(define-public (record-bulk-metrics
    (protocol (string-ascii 50))
    (tvl uint)
    (daily-vol uint)
    (tx-count uint)
    (height uint))
    (begin
        (asserts! (var-get analytics-enabled) (err u104))
        (asserts! (is-authorized-reporter tx-sender) err-unauthorized)
        
        ;; Record multiple metrics in one transaction
        (try! (record-protocol-tvl protocol tvl height))
        
        ;; Record network health
        (try! (record-network-health "daily-volume" daily-vol height))
        (try! (record-network-health "daily-transactions" tx-count height))
        
        (ok true)))

;; Initialize contract with owner as first authorized reporter
(map-set authorized-reporters contract-owner true)