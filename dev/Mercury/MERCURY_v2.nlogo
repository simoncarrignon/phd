;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; ICRATES PROJECT: TRADE-DISTRIBUTION-MODEL ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Created by Tom Brughmans
;; Acknowledgements: thanks to Iza Romanowska, Jan Christoph Athenstaedt, Mereke Van Garderen,
;; David Schoch, Arlind Nocaj and Jeroen Poblome for extensive comments on earlier versions of this model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extensions [ network nw ]
; two network extensions are used in this model.
; The 'network' extension comes packaged with Netlogo 5.0.5
; the 'nw' extension needs to be downloaded from the Netlogo website and added to the 'extensions' folder: https://github.com/NetLogo/NetLogo/wiki/Extensions
breed [ traders trader ] ; the agents in this model who are positioned on sites, are connected by commercial links, and trade products with each other over these links
breed [ sites site ] ; the sites, representing marketplaces on which traders are based, meet, and trade

globals
[
  trader-list ; a list used in step 4 of the connect-traders procedure to select traders with a probability proportional to Zi (Zi - 1)
  node-pairs ; reporter, parameter used to calculate and report the number of node pairs
  av-degree ; reporter, parameter used to calculate and report the average degree of the network during the setup procedure
  clustering-coefficient ; reporter, parameter used for calculating and reporting the clustering coefficient in the setup procedure
  neighbor-site-links ; reporter, parameter used for reporting the number of links between neighboring sites in the circular layout, step 1 of the connect-traders procedure
  random-inter-site-links ; reporter, parameter used for reporting the number of random inter site links in a setup of the model, step 2 of the connect-traders procedure
  random-intra-site-links ; reporter, parameter used for reporting the number of random intra site links in a setup of the model, step 3 of the connect-traders procedure
  mutual-neighbors-intra-site-links ; reporter, parameter used for reporting the number of mutual neighbors linked within sites in a setup of the model, step 4 of the connect-traders procedure
  random-component-links ; reporter, parameter used for reporting the number of random links added to join components, step 5 of the connect-traders procedure
  counter-trade ; reporter, parameter used in the trade procedures to keep track of how many transactions have already been attempted
  counter-transaction ; reporter, parameter used in the trade procedures to count the number of successful transactions
  counter-stock-redist ; reporter, parameter used in the trade procedures to count the number of items put in stock with redistribution in mind per tick
  counter-no-transaction; reporter, parameter used in the trade procedures to count the number of failed transactions per tick
]

sites-own
[
  target-distribution ; counter parameter used in the setup procedure to identify the number of traders that need to be present at a site under the selection distribution hypothesis
  production-site ;
  producer-A ; parameter used to indicate the production centre of product-A
  producer-B ; parameter used to indicate the production centre of product-B
  producer-C ; parameter used to indicate the production centre of product-C
  producer-D ; parameter used to indicate the production centre of product-D
  volume-A ; the volume of product A deposited at a site
  volume-B ; the volume of product B deposited at a site
  volume-C ; the volume of product C deposited at a site
  volume-D ; the volume of product D deposited at a site
]

traders-own
[
  comp ; parameter used to identify which connected component a trader is part of. Used when creating the initial trade network in the setup procedure
  trader-clustering-coefficient ; parameter used for calculating the clustering coefficient of traders
  moved? ; parameter used to keep track of the traders who have already moved to a site in the setup phase
  product-A ; the amount of product A an agent possesses
  product-B ; the amount of product B an agent possesses
  product-C ; the amount of product C an agent possesses
  product-D ; the amount of product D an agent possesses
  stock-A ; the amount of product A a trader saves for possible redistribution in the next tick
  stock-B ; the amount of product A a trader saves for possible redistribution in the next tick
  stock-C ; the amount of product A a trader saves for possible redistribution in the next tick
  stock-D ; the amount of product A a trader saves for possible redistribution in the next tick
  price ; the price a trader believes one item of the product is worth in his part of the network, float between 0 and 1
  demand ; the demand a trader believes he can supply products for
  average-demand ; parameter used to calculate the average demand of a trader's link neighbors
  site-number ; parameter used to keep track of what site this trader is located at, used to reposition traders after layout
  known-traders ; parameter used to store the agentset a trader receives commercial information from in each tick
  maximum-stock-size ; parameter used to calculate and store in each tick the number of items a trader is willing to obtain over his own demand for redistribution in the next tick
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; SETUP ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
to setup
  clear-all
  random-seed seed
  set-default-shape traders "person"
  set-default-shape sites "circle"
  create-sites num-sites [ set size 0.8 set color red set target-distribution 0 ]
  create-traders num-traders [ set size 0.3 set color blue set moved? false set demand 0 ] ; size of traders should be smaller than size of sites, since 'traders-here' is used which is very sensitive to patch and node size.
                                                                       ; Ensure the model knows at the setup stage that none of the traders have moved to any of the sites yet. Initialise demand per trader by setting it to 0.
  set node-pairs ( ( num-traders / 2 ) * (num-traders - 1) )
  layout-circle ( sort sites ) max-pxcor - 1 ; arrange sites according to a circular layout
  select-production-sites ; select which sites are production centres of each product. These production sites will be evenly spaced among the circular layout of sites
  distribute-traders-on-sites ; move all traders to a site following a uniform, normal, or exponential distribution
  ask traders [ set site-number [who] of one-of sites-here ] ; make a note of which site a trader is located at (needed to reposition traders after layout)
  nw:set-context traders links ; set the context the NW extension procedures will be working in
  connect-traders ; connect traders in five steps to create a representation of the hypothesised social network structure
                  ; OR create a random network with the same number of links
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; GO ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  ifelse layout?
  [ ; if layout is turned on, traders will be positioned following a spring-embedded layout algorithm.
    ; No other procedures take place and ticks don't increase, to allow for the experiment to continue from the point when layout was turned on
    layout
  ]
  [
    reposition-traders ; if layout was turned on before, then move the traders back to their sites.
    determine-demand ; each trader increases its demand by one (as long as it is lower than the number of traders at the site).
    discard-part-of-stock ; a fixed proportion of a trader's stock from last tick is deposited on its site, the rest can be traded again this tick
    produce ; each trader at a production site obtains X newly produced items of the locally produced product if its total number of
            ; items of all products is less or equal than its demand.
    trade-and-consume ; a single transaction will occur for each item of each product: after a successful transaction the item is deposited on the buyers' site
                      ; when the seller is not connected to any potential buyers it puts the item in its stock
                      ; when the buyer notices the average demand in its personal network is higher than its own demand it puts the item in its stock.
    tick
    if ticks = 20000 [get-ending-stats]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; SETUP PROCEDURES ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to select-production-sites ; select tableware production sites and space them evenly accross the circular layout
  ifelse equal-traders-production-site = "true"
  [
    let spacing round ( num-sites / 4 ) ; identify the spacing between production sites
    ; make each of these sites a producer of a certain product and move an equal number of traders to these sites
    ask site 0 [set production-site true set producer-A true set color blue set size 1.2]
    ask n-of traders-production-site traders with [moved? = false] [move-to site 0 set moved? true]
    ask site spacing [set production-site true set producer-B true set color blue set size 1.2]
    ask n-of traders-production-site traders with [moved? = false] [move-to site spacing set moved? true]
    ask site (spacing + spacing) [set production-site true set producer-C true set color blue set size 1.2]
    ask n-of traders-production-site traders with [moved? = false] [move-to site (spacing + spacing) set moved? true]
    ask site (spacing + spacing + spacing) [set production-site true set producer-D true set color blue set size 1.2]
    ask n-of traders-production-site traders with [moved? = false] [move-to site (spacing + spacing + spacing) set moved? true]
  ]
  [
    let spacing round ( num-sites / 4 ) ; identify the spacing between production sites
    ; make each of these sites a producer of a certain product and move an equal number of traders to these sites
    ask site 0 [set production-site true set producer-A true set color blue set size 1.2]
    ask site spacing [set production-site true set producer-B true set color blue set size 1.2]
    ask site (spacing + spacing) [set production-site true set producer-C true set color blue set size 1.2]
    ask site (spacing + spacing + spacing) [set production-site true set producer-D true set color blue set size 1.2]
  ]
end

to distribute-traders-on-sites
  ; the trader distribution (number of traders per site) is initialized depending on the hypothesis
  if traders-distribution = "uniform" ; uniform distribution of traders on sites
  [setup-uniform-distribution]
  if traders-distribution = "exponential" ; exponential distribution of traders on sites
  [setup-exponential-distribution]
end

to connect-traders
  if network-structure = "random" [connect-random-network] ; create a random network connecting traders. This option allows for comparing the results of the hypothesises being tested with those of the same processes working on a random network
  if network-structure = "hypothesis" ; The commercial network of traders is set up in five steps reflecting the hypotheses being tested
  [
    connect-traders-adjacent-sites ; 1) we ensure that at least one pair of traders is connected between every pair of adjacent sites in the circular layout
    connect-random-traders ; 2) a proportion of randomly selected pairs on different sites is connected
    ; 3) on each site a number of randomly selected pairs of traders are connected
    ; 4) on each site a number of pairs of traders with mutual contacts on the same site are connected
    connect-to-av-degree ; (steps 3 and 4 are looped until the average degree is reached)
    single-connected-component ; 5) we ensure that the network consists of one connected component, i.e. that there are no isolated traders and multiple components
  ] 
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; GO PROCEDURES ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to reposition-traders 
  if layout? = false [ask traders [move-to site site-number]] ; ensure the traders are located at the correct site
end

to determine-demand ; demand increases at a constant rate up to max-demand (representing new demand due to e.g. pots breaking)
  ask traders ; if a trader's demand is lower than the max-demand variable, increase its demand by 1
  [if demand < max-demand
    [set demand demand + 1]]
end

to discard-part-of-stock
  ; traders discard a constant proportion of their stock as a cost/risk/punishment of redistributing items
  ; all of their remaining stock is added to their volume of the product and the stock is set to 0
  ; NOTE that increasing the amount of product at the end of the tick ensures it does not decrease the demand of the agent
  ; Next tick the agent will have the same demand as always and will strive to satisfy this demand as well as being able to sell the items he obtained to other traders who have a positive demand.
  ask traders
  [
    let discard-A round(stock-A * 0.14)
    let discard-B round(stock-B * 0.14)
    let discard-C round(stock-C * 0.14)
    let discard-D round(stock-D * 0.14)
    set product-A product-A + (stock-A - discard-A)
    set product-B product-B + (stock-B - discard-B)
    set product-C product-C + (stock-C - discard-C)
    set product-D product-D + (stock-D - discard-D)
    set stock-A 0
    set stock-B 0
    set stock-C 0
    set stock-D 0
    ask sites-here
    [
      set volume-A volume-A + discard-A
      set volume-B volume-B + discard-B
      set volume-C volume-C + discard-C
      set volume-D volume-D + discard-D
    ]
  ]
end

to produce
  ask sites with [producer-A = true]
  [ask traders-here ; all traders on the production site obtain X newly produced items...
    [if (product-A + product-B + product-C + product-D) < demand ; ... if their total possession of all products is less than their demand
      [set product-A product-A + round(demand - (product-A + product-B + product-C + product-D))]]] ; increase product by however much it differs from demand
  
  ask sites with [producer-B = true]
  [ask traders-here ; all traders on the production site obtain newly produced items...
    [if (product-A + product-B + product-C + product-D) < demand ; ... if its total possession of all products is less than its demand
      [set product-B product-B + round(demand - (product-A + product-B + product-C + product-D))]]] ; increase product by however much it differs from demand
  
  ask sites with [producer-C = true]
  [ask traders-here ; all traders on the production site obtain newly produced items...
    [if (product-A + product-B + product-C + product-D) < demand ; ... if its total possession of all products is less than its demand
      [set product-C product-C + round(demand - (product-A + product-B + product-C + product-D))]]] ; increase product by however much it differs from demand
  
  ask sites with [producer-D = true]
  [ask traders-here ; all traders on the production site obtain newly produced items...
    [if (product-A + product-B + product-C + product-D) < demand ; ... if its total possession of all products is less than its demand
      [set product-D product-D + round(demand - (product-A + product-B + product-C + product-D))]]] ; increase product by however much it differs from demand
end

to trade-and-consume
  ask traders
  [ ; determine the neighboring traders each trader obtains commercial information from in this tick
    identify-known-traders
    price-setting ; estimate the price for one item
    set maximum-stock-size round(average-demand - demand) ; determine how many items a trader is willing to obtain over his own demand for redistribution in the next tick
  ]
  ; each item in all traders' possessions will be considered in turn in a random order. Each item is either deposited as a result of a successful transaction, or it is added to a trader's stock
  let product-on-market sum [ product-A + product-B + product-C + product-D] of traders ; count the total number of items of all products
  set counter-trade 0 ; counter used to keep track of the total  number of items considered in each tick
  set counter-transaction 0 ; counter to report the number of successful transactions per tick
  set counter-stock-redist 0 ; counter to report the number of items put in stock with redistribution in mind per tick
  set counter-no-transaction 0 ; counter to report the number of failed transactions per tick
  while [counter-trade < product-on-market] ; repeat until all items on the market have been considered for trade
  [ ; for each potential transaction randomly select whether an item of product A, B, C or D will be traded
    let p random 4 
    if p = 0
    [trade-product-A]
    if p = 1 
    [trade-product-B]
    if p = 2
    [trade-product-C]
    if p = 3
    [trade-product-D]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; TRADE PROCEDURES ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; the trade-product procedures are exactly the same for each product with the exception that only agent parameters relevant to one specific product are updated in each procedure

to trade-product-A
  if count traders with [product-A > 0] > 0 ; if there are traders with this product ...
  [ask one-of traders with [product-A > 0] ; select a seller at random
    [let potential-buyers link-neighbors with [(demand > 0) or (maximum-stock-size > 0)] ; trade can only happen with link neighbors that have a positive demand or are willing to stock items for redistribution
      ifelse count potential-buyers = 0
      [ ; if there are no buyers for the item then put all of your items in stock
        set stock-A stock-A + product-A
        set maximum-stock-size maximum-stock-size - product-A
        set counter-trade counter-trade + product-A
        set counter-no-transaction counter-no-transaction + product-A
        set product-A 0
      ]
      [ ; if there are potential buyers for the item then consider selling it
        let seller-price price
        let buyer-price 0
        let likely-buyer one-of potential-buyers with-max [price] ; select the buyer that offers the highest profit (the most likely buyer of the item)
        ask likely-buyer [set buyer-price price]
        ifelse buyer-price >= seller-price ; if the seller can make a profit or breaks-even then complete the transaction
        [
          set counter-transaction counter-transaction + 1
          set product-A product-A - 1 ; process the transaction for the seller
          set counter-trade counter-trade + 1
          ask likely-buyer ; process the transaction for the buyer, two possible actions...
          [
            ifelse demand = 0 ; ... 1) if the buyer's demand is 0 and the average demand is higher than its own demand (captured by a positive maximum-stock-size) then store the item for redistribution in the next tick (with the prospect of trading it for a higher profit)
            [
              set stock-A stock-A + 1
              set maximum-stock-size maximum-stock-size - 1
              set counter-stock-redist counter-stock-redist + 1
            ]
            [ ; ... 2) if the buyer's demand is not 0 then sell it to a consumer who deposits the item at a site
              set demand demand - 1
              ask one-of sites-here [set volume-A volume-A + 1]
            ]
          ]
        ]
        [ ; if the seller cannot make a profit then move all items in stock
          set stock-A stock-A + product-A
          set maximum-stock-size maximum-stock-size - product-A
          set counter-trade counter-trade + product-A
          set counter-no-transaction counter-no-transaction + product-A
          set product-A 0
        ] 
      ]
    ]
  ]
end

to trade-product-B
  if count traders with [product-B > 0] > 0 ; if there are traders with this product ...
  [ask one-of traders with [product-B > 0] ; select a seller at random
    [let potential-buyers link-neighbors with [(demand > 0) or (maximum-stock-size > 0)] ; trade can only happen with link neighbors that have a positive demand
      ifelse count potential-buyers = 0
      [ ; if there are no buyers for the item then put all items in stock
        set stock-B stock-B + product-B
        set maximum-stock-size maximum-stock-size - product-B
        set counter-trade counter-trade + product-B
        set counter-no-transaction counter-no-transaction + product-B
        set product-B 0
      ]
      [ ; if there are potential buyers for the item consider selling it
        let seller-price price
        let buyer-price 0
        let likely-buyer one-of potential-buyers with-max [price] ; select the buyer that offers the highest profit (the most likely buyer of the item)
        ask likely-buyer [set buyer-price price]
        ifelse buyer-price >= seller-price ; if the seller can make a profit then complete the transaction
        [
          set counter-transaction counter-transaction + 1
          set product-B product-B - 1 ; process the transaction for the seller
          set counter-trade counter-trade + 1
          ask likely-buyer ; process the transaction for the buyer, two possible actions...
          [
            ifelse demand = 0 ; ... 1) if the buyer's demand is 0 and the average demand is higher than its own demand (captured by a positive maximum-stock-size) then store the item for redistribution in the next tick (with the prospect of trading it for a higher profit)
            [
              set stock-B stock-B + 1
              set maximum-stock-size maximum-stock-size - 1
              set counter-stock-redist counter-stock-redist + 1
            ]
            [ ; ... 2) if the average demand is lower than my own demand then sell it to a consumer who deposits the item at a site
              set demand demand - 1
              ask one-of sites-here [set volume-B volume-B + 1]
            ]
          ]
        ]
        [ ; if the seller cannot make a profit then move this item in stock
          set stock-B stock-B + product-B
          set maximum-stock-size maximum-stock-size - product-B
          set counter-trade counter-trade + product-B
          set counter-no-transaction counter-no-transaction + product-B
          set product-B 0
        ]
      ]
    ]
  ]
end

to trade-product-C
  if count traders with [product-C > 0] > 0 ; if there are traders with this product ...
  [ask one-of traders with [product-C > 0] ; select a seller at random
    [let potential-buyers link-neighbors with [(demand > 0) or (maximum-stock-size > 0)] ; trade can only happen with link neighbors that have a positive demand
      ifelse count potential-buyers = 0
      [ ; if there are no buyers for the item then put all items in stock
        set stock-C stock-C + product-C
        set maximum-stock-size maximum-stock-size - product-C
        set counter-trade counter-trade + product-C
        set counter-no-transaction counter-no-transaction + product-C
        set product-C 0
      ]
      [ ; if there are potential buyers for the item consider selling it
        let seller-price price
        let buyer-price 0
        let likely-buyer one-of potential-buyers with-max [price] ; select the buyer that offers the highest profit (the most likely buyer of the item)
        ask likely-buyer [set buyer-price price]
        ifelse buyer-price >= seller-price ; if the seller can make a profit then complete the transaction
        [
          set counter-transaction counter-transaction + 1
          set product-C product-C - 1 ; process the transaction for the seller
          set counter-trade counter-trade + 1
          ask likely-buyer ; process the transaction for the buyer, two possible actions...
          [
            ifelse demand = 0 ; ... 1) if the buyer's demand is 0 and the average demand is higher than its own demand (captured by a positive maximum-stock-size) then store the item for redistribution in the next tick (with the prospect of trading it for a higher profit)
            [
              set stock-C stock-C + 1
              set maximum-stock-size maximum-stock-size - 1
              set counter-stock-redist counter-stock-redist + 1
            ]
            [ ; ... 2) if the average demand is lower than my own demand then sell it to a consumer who deposits the item at a site
              set demand demand - 1
              ask one-of sites-here [set volume-C volume-C + 1]
            ]
          ]
        ]
        [ ; if the seller cannot make a profit then move this item in stock
          set stock-C stock-C + product-C
          set maximum-stock-size maximum-stock-size - product-C
          set counter-trade counter-trade + product-C
          set counter-no-transaction counter-no-transaction + product-C
          set product-C 0
        ]
      ]
    ]
  ]
end

to trade-product-D
  if count traders with [product-D > 0] > 0 ; if there are traders with this product ...
  [ask one-of traders with [product-D > 0] ; select a seller at random
    [let potential-buyers link-neighbors with [(demand > 0) or (maximum-stock-size > 0)] ; trade can only happen with link neighbors that have a positive demand
      ifelse count potential-buyers = 0
      [ ; if there are no buyers for the item then put it in stock
        set stock-D stock-D + product-D
        set maximum-stock-size maximum-stock-size - product-D
        set counter-trade counter-trade + product-D
        set counter-no-transaction counter-no-transaction + product-D
        set product-D 0
      ]
      [ ; if there are potential buyers for the item consider selling it
        let seller-price price
        let buyer-price 0
        let likely-buyer one-of potential-buyers with-max [price] ; select the buyer that offers the highest profit (the most likely buyer of the item)
        ask likely-buyer [set buyer-price price]
        ifelse buyer-price >= seller-price ; if the seller can make a profit then complete the transaction
        [
          set counter-transaction counter-transaction + 1
          set product-D product-D - 1 ; process the transaction for the seller
          set counter-trade counter-trade + 1
          ask likely-buyer ; process the transaction for the buyer, two possible actions...
          [
            ifelse demand = 0 ; ... 1) if the buyer's demand is 0 and the average demand is higher than its own demand (captured by a positive maximum-stock-size) then store the item for redistribution in the next tick (with the prospect of trading it for a higher profit)
            [
              set stock-D stock-D + 1
              set maximum-stock-size maximum-stock-size - 1
              set counter-stock-redist counter-stock-redist + 1
            ]
            [ ; ... 2) if the average demand is lower than my own demand then sell it to a consumer who deposits the item at a site
              set demand demand - 1
              ask one-of sites-here [set volume-D volume-D + 1]
            ]
          ]
        ]
        [ ; if the seller cannot make a profit then move this item in stock
          set stock-D stock-D + product-D
          set maximum-stock-size maximum-stock-size - product-D
          set counter-trade counter-trade + product-D
          set counter-no-transaction counter-no-transaction + product-D
          set product-D 0
        ]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; DISTRIBUTE TRADERS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-uniform-distribution
  ifelse equal-traders-production-site = "true"
  [
    ask sites with [production-site != true]
    [set target-distribution ceiling ((count traders with [moved? = false]) / num-sites)] ; determine the number of traders that should be present at each site. Round up, this ensures we have as many sites with the target number of traders as possible.
    ask traders with [moved? = false] ; ask each trader that has not been moved to a site yet in turn
    [ifelse count sites with [count traders-here < target-distribution] = 0
      [ ; move to a randomly selected site if all sites already reached their desired number of traders
        move-to one-of sites with [production-site != true]
        set moved? true
      ]
      [ ; if some sites did not yet reach their desired number of traders then move to one of these sites 
        move-to one-of sites with [count traders-here < target-distribution]
        set moved? true
      ]
    ]
  ]
  [
    ask sites
    [set target-distribution ceiling ((count traders with [moved? = false]) / num-sites)] ; determine the number of traders that should be present at each site. Round up, this ensures we have as many sites with the target number of traders as possible.
    ask traders with [moved? = false] ; ask each trader that has not been moved to a site yet in turn
    [ifelse count sites with [count traders-here < target-distribution] = 0
      [ ; move to a randomly selected site if all sites already reached their desired number of traders
        move-to one-of sites with [production-site != true]
        set moved? true
      ]
      [ ; if some sites did not yet reach their desired number of traders then move to one of these sites 
        move-to one-of sites with [count traders-here < target-distribution]
        set moved? true
      ]
    ]
  ]
end

to setup-exponential-distribution
  ifelse equal-traders-production-site = "true"
  [
    ask sites with [production-site != true]
    [set target-distribution ceiling (random-exponential ((count traders with [moved? = false]) / num-sites))] ; round up, this ensures we have as many sites with the target number of traders as possible.
      ; an exponential distribution is created with a mean equal to the mean number of traders per site (excluding traders that have already been moved to the four production sites)
    ask traders with [moved? = false] ; ask each trader that has not been moved to a site yet in turn
    [ifelse count sites with [count traders-here < target-distribution] = 0
      [ move-to one-of sites with [production-site != true] set moved? true ] ; move to a randomly selected site if all sites already reached their desired number of traders
      [ move-to one-of sites with [count traders-here < target-distribution] set moved? true ] ; if some sites did not yet reach their desired number of traders then move to one of these sites
    ]
  ]
  [
    ask sites
    [set target-distribution ceiling (random-exponential ((count traders with [moved? = false]) / num-sites))] ; round up, this ensures we have as many sites with the target number of traders as possible.
      ; an exponential distribution is created with a mean equal to the mean number of traders per site (excluding traders that have already been moved to the four production sites)
    ask traders with [moved? = false] ; ask each trader that has not been moved to a site yet in turn
    [ifelse count sites with [count traders-here < target-distribution] = 0
      [ move-to one-of sites with [production-site != true] set moved? true ] ; move to a randomly selected site if all sites already reached their desired number of traders
      [ move-to one-of sites with [count traders-here < target-distribution] set moved? true ] ; if some sites did not yet reach their desired number of traders then move to one of these sites
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; CONNECT TRADERS ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if the experiments representing the hypotheses are compared with a random network with the same density then do the following procedure
to connect-random-network
  connect-traders-adjacent-sites connect-random-traders connect-to-av-degree single-connected-component
  let num-links count links
  ask links [die]
  repeat num-links [ask one-of traders [create-link-with one-of other traders with [link-with myself = nobody]]]
  single-connected-component
end

; if the experiments represent the hypotheses then do the following five steps:
to connect-traders-adjacent-sites
  ;; FIRST, connect one trader on each site to a trader on the next site in the circuar layout
  set neighbor-site-links num-sites
  let num-sites-minus-one ( num-sites - 1 )
  let site-counter 0
  while [site-counter < num-sites-minus-one ]
  [
    ask one-of traders with [site-number = site-counter] [create-link-with (one-of traders with [site-number = (site-counter + 1)])]
    set site-counter site-counter + 1
  ]
  ; connect a trader on the first site to one on the last site (since this is not done in the previous step)
  ask one-of traders with [site-number = 0]
  [create-link-with (one-of traders with [site-number = num-sites-minus-one])]
end

to connect-random-traders
  ; SECOND, create a variable number of inter-site links by randomly selecting a pair of traders on different sites and connecting them
  ; in order for the proportion of inter-site links to be similar irrespective of the number of traders I adopt the approach by Jin et al 2001
  ;"at each time-step, we choose np * r0 pairs of vertices uniformly at random from the network to meet.
  ; if a pair meet who do not have a pre-existing connection, and if neither of them already has the maximum number of connections
  ; then a new connection is established between them."
  ; np = 1/2*N *(N-1) (in this procedure called node-pairs)
  ; s0 is a variable (called r0 by Jin et al.; in this procedure called proportion-inter-site-links)
  ; In this procedure pairs of nodes are not selected uniformly at random, only nodes that fulfil the criteria to create an inter-site-link are selected
  set random-inter-site-links ceiling(node-pairs * proportion-inter-site-links) ; show the number of random links in this setup of the model
  let inter-site-links-counter 0
  while [inter-site-links-counter < random-inter-site-links] ; np * s0 pairs of vertices are selected at random
  [ask one-of traders with [count link-neighbors < maximum-degree]; select node1
    [
      let node2 one-of other traders with [ (link-with myself = nobody) and [site-number] of self != [site-number] of myself and count link-neighbors < maximum-degree] ; identify a node that is not myself, is not a link-neighbor, and is located on another site
      create-link-with node2
      set inter-site-links-counter inter-site-links-counter + 1]]
end

to connect-to-av-degree
  set random-intra-site-links 0
  set mutual-neighbors-intra-site-links 0
  let approximate-maximum-average-degree (maximum-degree - ((maximum-degree / 100) * 10))
  while [report-av-degree <= approximate-maximum-average-degree] ; the following two processes of link creation are looped until the maximum average degree is approximated
  [
  ; THIRD, create links between pairs of randomly selected traders on the same site
  ; step 1 of the Jin etal 2001 simplified model starts here, but modified to only select traders on the same site
  ; "at each time-step, we choose np * r0 pairs of vertices uniformly at random from the network to meet.
  ; if a pair meet who do not have a pre-existing connection, and if neither of them already has the maximum number of connections
  ; then a new connection is established between them."
  ; np = 1/2*N *(N-1) (called node-pairs in this procedure)
  ; r0 is a variable (called proportion-intra-site-links in this procedure)
    repeat round (node-pairs * proportion-intra-site-links) ; np * r0 pairs of vertices are selected at random
    [if any? traders with [count link-neighbors < maximum-degree]
      [ask one-of traders ; select a random trader
        [if count link-neighbors < maximum-degree and count traders-here > 1
          [ask one-of traders-here with [self != myself] ; select a random other trader on the same site
            [if link-with myself = nobody and count link-neighbors < maximum-degree
              [ ; identify a node that is not myself, is not a link-neighbor, does not have the maximum degree, and is located at the same site as node1
                create-link-with myself
                set random-intra-site-links random-intra-site-links + 1
                ]]]]]]
 
    ; FOURTH, nodes with a mutual contact on the same site are invited to become connected
    ; step 2 of the Jin etal 2001 simplified model starts here
    ; at each time-step, we choose NmR1 vertices at random, with probabilities proportional to Zi ( Zi - 1 ).
    ; for each vertex chosen we randomly choose one pair of its neighbors to meet, and establish a new connection between them
    ; if they do not have a pre-existing connection and if neither of them already has the maximum number of connections.
    ; mutual-neighbors = 1/2 * SUMi ( Zi * ( Zi - 1) ). Parameter Nm in Jin etal 2001 and represents the number of mutual neighbors.
    ; proportion-mutual-neighbors (r1 in Jin et al 2001)
    let mutual-neighbors ((0.5 * sum([( count link-neighbors ) * ( ( count link-neighbors ) - 1 )] of traders))) ; calculate nm
    list-traders ; make a list reflecting a probability distribution proportional to Zi (Zi - 1)
    repeat (mutual-neighbors * proportion-mutual-neighbors) ; repeat nm * r1 times
    [ask selected-trader ; each time randomly select a trader with probability proportional to Zi ( Zi - 1 )
      [let possible-mutual-neighbors link-neighbors with [[site-number] of self = [site-number] of myself and count link-neighbors < maximum-degree]
        if any? possible-mutual-neighbors
        [
          let node1 one-of possible-mutual-neighbors
          ask node1
            [
              let possible-node2 possible-mutual-neighbors with [self != node1 and (link-with node1 = nobody)]
              if any? possible-node2
              [
              create-link-with one-of possible-node2
              set mutual-neighbors-intra-site-links (mutual-neighbors-intra-site-links + 1)
              ]]]]]]
end

to list-traders
  set trader-list [] ; create an empty list
  ask traders [ repeat ((count link-neighbors) * ((count link-neighbors) - 1)) [set trader-list lput who trader-list]] ; put a trader's ID in the list as often as Zi (Zi - 1)
end

to-report selected-trader
  let selected random length trader-list ; determine the total number of items in the probability distribution, select a random integer from this sum
  let winner trader (item selected trader-list)
  report winner
end

to single-connected-component
  ; FIFTH, we ensure that the network consists of one connected component, i.e. that there are no isolated traders and multiple components
  ; this to reflect the theoretical possibility in the static network that objects produced anywhere can end up in any site
  ; to enforce this the network nodes need to be able to be connected by a path
  set random-component-links 0
  let length-c length nw:weak-component-clusters ; calculate the number of components and save this as length-c
  let components nw:weak-component-clusters ; identify the components as a list of different agentsets
  let number-components n-values length-c [?] ; create a list of length-c counting from 0 to (length-c - 1). This list will be used to give each component a different number
  ; loop through the two lists just created: the components and the numbers
  (foreach components number-components
    [
      let cluster ?1
      let cluster-no ?2
      ask cluster ; for each trader in the component
      [set comp cluster-no] ; give them a number according to the component they are in
    ]
  )
  let count-components length-c
  while [count-components > 1] ; repeat the following process of link creation between pairs of traders located on the same site but in different network components as long as there are multiple connected components
  [ask one-of sites ; randomly select a site
    [
      let f min [comp] of traders-here
      let g max [comp] of traders-here
      if f != g ; if there is a difference in the components its traders belong to ...
      [ask one-of traders-here with [comp = f] ; ... select two traders in different components and create a link between them 
        [ask one-of other traders-here with [comp = g]
          [
            create-link-with myself
            set random-component-links random-component-links + 1
          ]
        ]
      ]
    ]
    ; re-calculate the number of components
    set length-c length nw:weak-component-clusters ; calculate the number of components and save this as length-c
    set count-components length-c
    set components nw:weak-component-clusters ; identify the components as a list of different agentsets
    set number-components n-values length-c [?] ; create a list of length-c counting from 0 to (length-c - 1). This list will be used to give each component a different number
    ; loop through the two lists just created: the components and the numbers
    (
      foreach components number-components
      [
        let cluster ?1
        let cluster-no ?2
        ask cluster ; for each trader in the component
        [set comp cluster-no] ; give them a number according to the component they are in
      ]
    )
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; PRICE SETTING ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to identify-known-traders ; every tick each trader will only have commercial information available from a fraction of its link neighbors. These traders are identified here to ensure they remain the same throughout the tick.
  set known-traders n-of ceiling((count link-neighbors) * local-knowledge) link-neighbors
end

to price-setting
  ; the trader estimates what the current price for one item of a product is, based on the demand and supply of a proportion of his link-neighbors.
  find-average-demand ; determine the average demand of this fraction of neighbors
  let sum-prod sum[product-A + product-B + product-C + product-D] of known-traders ; determine the total supply of this fraction of neighbors
  let average-supply ((sum-prod + product-A + product-B + product-C + product-D) / ((count known-traders) + 1)) ; determine the average supply of this fraction of neighbors + myself
  set price (average-demand / (average-supply + average-demand)) ; determine the trader's price estimate
  ; the price of the product as perceived by the actor is the average demand divided by the average supply plus the average demand (to normalise the result)
end

to find-average-demand
  let sum-demand sum[demand] of known-traders ; determine the total demand of this fraction of neighbors
  set average-demand ((sum-demand + demand) / ((count known-traders) + 1)) ; determine the average demand of this fraction of neighbors + myself
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; LAYOUT ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to layout 
  ; the number 3 here is arbitrary; more repetitions slows down the
  ; model, but too few gives poor layouts
  repeat 3 [
    ; the more nodes we have to fit into the same amount of space,
    ; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count traders
    ; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring traders links (1 / factor) (7 / factor) (1 / factor)
    display  ;; for smooth animation
  ]
  ; don't bump the edges of the world
  let x-offset max [xcor] of traders + min [xcor] of traders
  let y-offset max [ycor] of traders + min [ycor] of traders
  ; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask traders [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; NETWORK MEASURES AND REPORTERS ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report report-neighbor-site-links
  report neighbor-site-links
end

to-report report-random-inter-site-links
  report random-inter-site-links
end

to-report report-random-intra-site-links
  report random-intra-site-links
end

to-report report-mutual-neighbors-intra-site-links
  report mutual-neighbors-intra-site-links
end

to-report report-random-component-links
  report random-component-links
end

to-report report-av-degree
  set av-degree sum([count link-neighbors] of traders) / num-traders
  report av-degree
end

to-report number-tlinks
  report count links
end

to-report average-shortest-path-length
  report network:mean-link-path-length traders links
end


; clustering coefficient (cc) measure, based on small-world model in Netlogo library
; for an alternative calculation see:
; http://www.ladamic.com/netlearn/NetLogo4/SmallWorldWS.nlogo
to-report in-neighborhood? [ hood ]
  report ( member? end1 hood and member? end2 hood )
end

to-report find-clustering-coefficient
  let traders-with-links traders with [ count link-neighbors != 0 ]
  ifelse all? traders-with-links [count link-neighbors <= 1]
  [
    ; it is undefined
    ; what should this be?
    set clustering-coefficient 0
  ]
  [
    let total 0
    ask traders-with-links with [ count link-neighbors <= 1]
    [
        set trader-clustering-coefficient "undefined"
    ]
    ask traders-with-links with [ count link-neighbors > 1] ;; only when more than one neighbor exists will cc be calculated
    [
      let hood link-neighbors
      set trader-clustering-coefficient (2 * count links with [ in-neighborhood? hood ] /
                                         ((count hood) * (count hood - 1)) )
      ; find the sum for the value at turtles
      set total total + trader-clustering-coefficient
    ]
    ; take the average
    set clustering-coefficient total / count traders-with-links with [count link-neighbors > 1]
    report clustering-coefficient
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; EXPORT EXPERIMENT STATS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to get-ending-stats
  
  ; export values for all variables, a screenshot of the interface and all plots
  export-world (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_world.csv")
  export-interface (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_interface.png")
  export-all-plots (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_plots.csv")
  
  ; export the independent variable settings and the number of sites on which each product is deposited, in .csv format
  file-open (word "C:/XYZ/ending-stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD.csv")
  file-type seed file-type "," 
  file-type num-traders file-type "," 
  file-type num-sites file-type "," 
  file-type traders-distribution file-type "," 
  file-type traders-production-site file-type "," 
  file-type proportion-inter-site-links file-type "," 
  file-type local-knowledge file-type "," 
  file-type max-demand file-type "," 
  file-type (count sites with [volume-A > 0]) file-type ","
  file-type (count sites with [volume-B > 0]) file-type ","
  file-type (count sites with [volume-C > 0]) file-type ","
  file-print (count sites with [volume-D > 0])
  file-close
  
  ; export a list of all sites with the average closeness and betweenness centrality of the traders on each site, the total number of links on a site, and the total volume of each product on each site. In .csv format
  file-open (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_allsites.csv")
  file-print "SiteID,AverageCloseness,MaxCloseness,AverageBetweenness,MaxBetweenness,InterSiteLinks,TradersHere,A,B,C,D,TotalVolume"
  ask sites
  [
    file-type who file-type ","
    file-type (sum [nw:closeness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:closeness-centrality] of traders-here) file-type "," 
    file-type (sum [nw:betweenness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:betweenness-centrality] of traders-here) file-type ","
    file-type sum[count link-neighbors with [site-number != [site-number] of myself]] of traders-here file-type ","
    file-type count traders-here file-type ","
    file-type volume-A file-type ","
    file-type volume-B file-type ","
    file-type volume-C file-type ","
    file-type volume-D file-type ","
    file-print (volume-A + volume-B + volume-C + volume-D)
  ]
  file-close
  
  ; export a list of all sites, excluding the production sites, with the average closeness and betweenness centrality of the traders on each site, the total number of links on a site, and the total volume of each product on each site. In .csv format
  file-open (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_noprodsites.csv")
  file-print "SiteID,AverageCloseness,MaxCloseness,AverageBetweenness,MaxBetweenness,InterSiteLinks,TradersHere,A,B,C,D,TotalVolume"
  ask sites with [production-site != true]
  [
    file-type who file-type ","
    file-type (sum [nw:closeness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:closeness-centrality] of traders-here) file-type "," 
    file-type (sum [nw:betweenness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:betweenness-centrality] of traders-here) file-type ","
    file-type sum[count link-neighbors with [site-number != [site-number] of myself]] of traders-here file-type ","
    file-type count traders-here file-type ","
    file-type volume-A file-type ","
    file-type volume-B file-type ","
    file-type volume-C file-type ","
    file-type volume-D file-type ","
    file-print (volume-A + volume-B + volume-C + volume-D)
  ]
  file-close
  
  ; export a list of all production sites only, with the average closeness and betweenness centrality of the traders on each site, the total number of links on a site, and the total volume of each product on each site. In .csv format
  file-open (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_prodsites.csv")
  file-print "SiteID,AverageCloseness,MaxCloseness,AverageBetweenness,MaxBetweenness,InterSiteLinks,TradersHere,A,B,C,D,TotalVolume"
  ask sites with [production-site = true]
  [
    file-type who file-type ","
    file-type (sum [nw:closeness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:closeness-centrality] of traders-here) file-type "," 
    file-type (sum [nw:betweenness-centrality] of traders-here) / (count traders-here) file-type ","
    file-type (max [nw:betweenness-centrality] of traders-here) file-type ","
    file-type sum[count link-neighbors with [site-number != [site-number] of myself]] of traders-here file-type ","
    file-type count traders-here file-type ","
    file-type volume-A file-type ","
    file-type volume-B file-type ","
    file-type volume-C file-type ","
    file-type volume-D file-type ","
    file-print (volume-A + volume-B + volume-C + volume-D)
  ]
  file-close
  
  ; export a list of all traders, their ID, the Id of the site they are located on, the number of traders at that site, and the trader's closeness and betweenness centrality scores. In .csv format
  file-open (word "C:/XYZ/stats_" proportion-inter-site-links"L_" local-knowledge "K_" traders-production-site "TPS_" max-demand "MD_" seed"_traders.csv")
  file-print "AgentID,SiteNumber,ClosenessCentrality,BetweennessCentrality,TradersHere"
  ask traders
  [
    file-type who file-type "," 
    file-type site-number file-type "," 
    file-type nw:closeness-centrality file-type "," 
    file-type nw:betweenness-centrality file-type "," 
    file-print count traders-here
  ]
  file-close
  
  stop
end
@#$#@#$#@
GRAPHICS-WINDOW
200
10
623
454
40
40
5.1
1
10
1
1
1
0
0
0
1
-40
40
-40
40
0
0
1
ticks
30.0

SLIDER
3
132
175
165
num-traders
num-traders
1
2000
1000
1
1
NIL
HORIZONTAL

SLIDER
3
164
175
197
num-sites
num-sites
12
100
100
4
1
NIL
HORIZONTAL

BUTTON
3
10
58
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1097
28
1297
178
Distribution traders on sites
#traders
#sites
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "let max-count-traders max [count traders-here] of sites\nset-plot-x-range 0 (max-count-traders + 1)\nhistogram [count (traders-here)] of sites"

SWITCH
3
49
175
82
layout?
layout?
1
1
-1000

BUTTON
58
10
113
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
3
450
184
483
proportion-intra-site-links
proportion-intra-site-links
0
0.001
5.0E-4
0.0001
1
NIL
HORIZONTAL

CHOOSER
3
240
175
285
traders-distribution
traders-distribution
"uniform" "exponential"
1

SLIDER
3
384
185
417
maximum-degree
maximum-degree
1
10
5
1
1
NIL
HORIZONTAL

SLIDER
3
417
185
450
proportion-inter-site-links
proportion-inter-site-links
0
0.0048
0.0010
0.0001
1
NIL
HORIZONTAL

SLIDER
3
482
184
515
proportion-mutual-neighbors
proportion-mutual-neighbors
0
5
2
1
1
NIL
HORIZONTAL

BUTTON
113
10
174
43
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
794
28
1098
178
Distribution products
ticks
sites with wares
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Product-A" 1.0 0 -16777216 true "" "plot count sites with [volume-A > 0]"
"Product-B" 1.0 0 -2674135 true "" "plot count sites with [volume-B > 0]"
"Product-C" 1.0 0 -10899396 true "" "plot count sites with [volume-C > 0]"
"Product-D" 1.0 0 -13345367 true "" "plot count sites with [volume-D > 0]"

SLIDER
3
540
183
573
local-knowledge
local-knowledge
0.1
1
0.1
0.1
1
NIL
HORIZONTAL

PLOT
1097
177
1297
327
Demand distribution
demand
# traders
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "let maxi-demand max [demand] of traders\nset-plot-x-range 0 (maxi-demand + 1)\nhistogram [demand] of traders"
"pen-1" 1.0 0 -2674135 true "" ""
"pen-2" 1.0 0 -10899396 true "" ""
"pen-3" 1.0 0 -13345367 true "" ""

SLIDER
3
80
175
113
seed
seed
0
100
10
1
1
NIL
HORIZONTAL

TEXTBOX
5
115
155
133
Trader distribution variables
11
0.0
1

TEXTBOX
6
322
156
340
Network variables
11
0.0
1

TEXTBOX
5
521
155
539
Trade variables
11
0.0
1

CHOOSER
3
340
185
385
network-structure
network-structure
"hypothesis" "random"
0

SLIDER
3
572
183
605
max-demand
max-demand
1
20
5
1
1
NIL
HORIZONTAL

SLIDER
3
284
175
317
traders-production-site
traders-production-site
1
30
10
1
1
NIL
HORIZONTAL

MONITOR
634
28
795
73
av degree
report-av-degree
4
1
11

MONITOR
634
73
795
118
clustering coefficient
find-clustering-coefficient
4
1
11

MONITOR
634
116
795
161
av shortest path length
average-shortest-path-length
4
1
11

MONITOR
634
160
795
205
total links
number-tlinks
0
1
11

MONITOR
634
203
795
248
neighbor site links
report-neighbor-site-links
0
1
11

MONITOR
634
247
795
292
inter site links
report-random-inter-site-links
0
1
11

MONITOR
634
291
795
336
random intra-site links
report-random-intra-site-links
0
1
11

MONITOR
634
335
795
380
mutual neighbors intra-site links
report-mutual-neighbors-intra-site-links
0
1
11

MONITOR
634
379
795
424
inter-component links
report-random-component-links
0
1
11

TEXTBOX
636
10
786
28
Network measures
11
0.0
1

TEXTBOX
635
428
785
446
Trade measures
11
0.0
1

MONITOR
635
446
795
491
successful transactions
counter-transaction
0
1
11

MONITOR
635
490
795
535
failed transactions
counter-no-transaction
0
1
11

MONITOR
635
534
795
579
stocked for redistribution
counter-stock-redist
0
1
11

PLOT
197
462
629
594
Count transactions
ticks
# transactions
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Successful transactions" 1.0 0 -10899396 true "" "plot counter-transaction"
"Failed transactions" 1.0 0 -2674135 true "" "plot counter-no-transaction"
"Stocked for redistribution" 1.0 0 -13345367 true "" "plot counter-stock-redist"
"Total items stocked" 1.0 0 -16777216 true "" "plot sum[stock-A + stock-B + stock-C + stock-D] of traders"

PLOT
1097
326
1297
476
price
price
# traders
0.1
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 2 -16777216 true "" "histogram [price] of traders"

PLOT
794
177
1098
327
Traders with stock
ticks
# traders
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Stock-A" 1.0 0 -16777216 true "" "plot count traders with [stock-A > 0]"
"Stock-B" 1.0 0 -2674135 true "" "plot count traders with [stock-B > 0]"
"Stock-C" 1.0 0 -10899396 true "" "plot count traders with [stock-C > 0]"
"Stock-D" 1.0 0 -13345367 true "" "plot count traders with [stock-D > 0]"

PLOT
794
327
1098
448
Distribution maximum stock size
maximum stock size
# traders
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "let max-stock max [maximum-stock-size] of traders\nlet min-stock min [maximum-stock-size] of traders\nset-plot-x-range (min-stock - 1) (max-stock + 2)\nhistogram [maximum-stock-size] of traders"

CHOOSER
3
196
175
241
equal-traders-production-site
equal-traders-production-site
"true" "false"
1

@#$#@#$#@
## WHAT IS IT?

This agent-based model aims to represent and explore two descriptive models of the functioning of the Roman trade system that explain the observed strong differences in the wideness of distributions of Roman tableware.

A detailed technical description of the model is published as:
Brughmans, T., & Poblome, J. (in review). MERCURY: an agent-based model of tableware trade in the Roman East. Journal of Artificial Societies and Social Simulation.

The archaeological research context and interpretation of experiments' results are published as:
Brughmans, T., & Poblome, J. (in press). Roman bazaar or market economy? Explaining tableware distributions in the Roman East through computational modelling. Antiquity.

The tablewares (fine thin-walled ceramics with shapes including bowls, plates, cups, and goblets; each ware has a distinct production centre or region) produced in the Eastern Mediterranean between 25BC and 150AD show an intriguing distribution pattern. Some wares like Eastern Sigillata A (ESA) were distributed very widely all accross the Mediterranean, whilst others (ESB, ESC, ESD) had a more limited regional distribution. Archaeologists and historians have suggested many aspects of the Roman trade system as the key to explaining tableware distribution patterns: physical transport mechanisms, tributary political systems, military supply systems, connectivity. In this model we focus on exploring the potential role of social networks as a driving force. The concept of social networks is here used as an abstraction of the commercial opportunities of traders, acting as a medium for the flow of information and the trade in tableware vessels between traders. We aim to formalise and evaluate two very different hypotheses of the Roman trade system in which such social networks are key: Peter Bang’s ‘The Roman Bazaar’ (2008) and Peter Temin’s ‘The Roman Market Economy’ (2013). In his model, Bang considers three factors crucial to understanding trade and markets in Roman Imperial times: bazaar-style markets, the tributary nature of the Roman Empire, and the agrarianate nature of ancient societies. The engine of the model, however, is clearly the concept of the bazaar: local markets distinguished by a high uncertainty of information, relative unpredictability of supply and demand, leading to poorly integrated markets throughout the empire. Bang argues that different circuits for the flow of goods could emerge as the result of different circuits for the flow of information. In other words, the observed distribution patterns of tablewares and different workshops’ products (when these can be identified) are at least in part a reflection of the structure and functioning of past social networks as defined above. Temin agrees with Bang that the information available to individuals was limited and that local markets are structuring factors. However, contrary to Bang he believes that the Roman economy was a well-functioning integrated market where prices are determined by supply and demand. Temin’s model can be considered to offer an alternative approach, where the structure of social networks as a channel for the flow of information must have allowed for integrated markets.

This model is designed to illustrate that certain aspects of Bang's and Temin's hypotheses can be tested through computational modelling.

## HOW IT WORKS

Traders are located at different sites and within sites connected in a social network with a ‘small-world’ structure (Watts and Strogatz 1998). A variable proportion of pairs of traders located on different sites are also connected. Four products are produced at four different sites, and are distributed through commercial transactions between pairs of traders connected in the social network. Two variables represent the availability of information and reflect key differences between Bang’s and Temin’s hypotheses: ‘random-inter-site-links’ and ‘local-knowledge’.

Setup procedures:
The model is initialised by creating sites and traders, and distributing the traders among the sites. Four sites which are equally spaced along a circular layout are selected to become tableware production sites. A fixed number of traders determined by the variable 'traders-production-site' is moved to each of the four production sites. The remaining traders are distributed on these sites following an exponential or uniform frequency distribution, determined by the variable 'traders-distribution'.

Traders are subsequently connected to each other to form a social network. In our model the social networks between traders at each site have a ‘small-world’ structure, with a high clustering coefficient and a low average shortest-path-length. This is suitable since a feature of ‘small-world’ networks is the efficient spread of information within clusters whilst few intermediary traders will allow information to flow between clusters. These clusters represent the ‘communities’ of traders in Bang’s model who are more likely to limit commercial information to their members. We further ensure that at least one pair of traders is connected between every pair of adjacent sites along the circular layout (this ensures that in experiments with a value of 0 for 'random-inter-site-links' each site is connected through pairs of traders to only two other sites) and that the network consists of one connected component (this guarantees that each trader can theoretically obtain an item of each product). This results in a high average shortest-path-length between traders at different sites. The average shortest-path-length is reduced in the experiments by the variable ‘random-inter-site-links’, which determines the proportion of randomly selected pairs of traders located at different sites to be connected. This variable therefore increases the ability for commercial information to be shared between communities at different sites: increasing this variable relaxes Bang’s extreme hypothesis. The procedure to create a network with a ‘small-world’ structure is inspired by the model for the growth of social networks by Jin, Girvan and Newman (2001), previously applied in an archaeological model of exchange by Bentley, Lake and Shennan (2005).

Distribution procedures:
In every time step traders perform the following tasks in sequence: they determine their demand, discard part of their stock (due to broken or unfashionable items), traders on tableware production sites obtain new items if their current possession is less than their demand, traders obtain commercial information from their neighbours in the network, they determine what they believe to be the current price of an item using this commercial information, and then all items owned by all traders in that turn are considered for trade once.

Every time step each trader will only have commercial information available from a proportion of its link neighbours. This proportion is determined by the variable ‘local-knowledge’. The trader then calculates the average demand and average supply of this proportion of neighbours, including his own supply and demand. Using this commercial information available to him he then determines what he believes is the price of one item of any product as follows: 
price=  (average-demand)/(average-supply+average-demand). A seller will only agree to sell an item if the buyer’s price is equal to or higher than this price.
Each item is considered for trade once per time step. An item is put in a trader’s stock if he cannot make a profit or if none of his neighbours in the network requires an item (i.e. their demand = 0). Items in stock can be redistributed in the next time step. An item is sold to a buyer if the buyer’s price promises a profit or break-even for the seller. The buyer either places the obtained item in stock for redistribution if the average-demand is higher than his demand (i.e. if redistribution holds the promise of a higher profit), or if this is not the case he sells it to a consumer (the buyer’s demand is decreased by 1, the item is taken out of the trade system, and the volume of the product in question deposited on the buyer’s site is increased by 1).


## HOW TO USE IT

A list of all variables and their tested settings are available for download from OpenABM as a tab delimited text file.

The model runs slowly due to a large number of reporters, counters, and graphs in this version. These can be removed to make the model much faster. Please refer to the list of all variables to identify which reporters and counters can be removed.

The experiments this model was designed for were run with the following default independent variable settings:

Num-traders: 1000 (computationally doable)
Num-sites: 100 (similar to average number of sites in archaeological database)
Maximum-degree: 5 (adopted from Jin etal. 2001)
Proportion-intra-site-links: 0.0005 (adopted from Jin etal. 2001)
Proportion-mutual-neighbors: 2 (adopted from Jin etal. 2001)

In experiments the following variables are modified to explore their effect on the distribution of the four products:

Proportion-inter-site-links
Local-knowledge
Traders-distribution
Traders-production-site
Network-structure
Max-demand

Click the setup button to initialise the model (this takes a long time).
Click the go button to run the model.

The main pattern of interest is shown in the 'distribution products' graph which shows the number of sites at which each of the four products is deposited.

## THINGS TO NOTICE

The model is designed to observe differences in the wideness of tableware distributions with different settings for the variables ‘random-inter-site-links’ and ‘local-knowledge’ in particular. Strong differences can be observed in the 'distribution products' graph when these variable settings are changed.

By increasing the proportion of random links between all pairs of traders on different sites, the average shortest-path-length becomes shorter. This enables products to spread throughout the network in a lower number of steps.

A higher ‘local-knowledge’ will give traders more accurate information of supply and demand of their potential transaction partners. Increasing this variable does not lead to strong differences in the wideness of products’ distributions, but it did have a strong impact on the proportion of failed and successful transactions.

In addition to these variables a number of other independent variables can be varied. Low values for 'traders-production-site' and 'max-demand' give rise to limited distributions of wares, whilst high values give rise to wide distributions. However, neither of these variables give rise to strong differences in the wideness of wares' distributions.

Changing 'traders-distribution' to 'uniform' will give rise to more limited distributions.

Changing 'network-structure' to 'random' allows one to replace the hypothesised 'small-world' network structure with a Bernoulli random graph with the same number of edges as the hypothesised graph with the same variable settings would have. Random graphs give rise to more widely distributed wares but with very little difference between the wideness of different wares' distributions.

When the variable 'traders-production-site' is excluded, all traders are distributed following an exponential distribution, and when the maximum demand of a trader equals the number of traders at its site, then the observed wideness and range of wares' distributions can be reproduced.

## EXTENDING THE MODEL

In future work this model could be extended by considering different types of traders, evaluating possible correlations between prices with network distance away from the production centre and incorporating transport costs, considering different valuations for different products, and introduce 'haggling' and market-clearing mechanisms. Crucially, a comparison of this model with a significantly simplified mathematical model of the spread of objects over network structures would be of interest, although this mathematical model would not form the basis of future extensions of the current model that incorporate different types of traders.

## NETLOGO FEATURES

The nw extension is used: https://github.com/NetLogo/NetLogo/wiki/Extensions

## RELATED MODELS

Bentley, R., M. Lake & S. Shennan. 2005. Specialisation and wealth inequality in a model of a clustered economic network Journal of Archaeological Science 32: 1346–56.

Graham, S., & Weingart, S. (2015). The Equifinality of Archaeological Networks: An Agent Based Exploratory Lab Approach. Journal of Archaeological Method and Theory, 22: 248–74.

Jin, E.M., M. Girvan & M.E. Newman. 2001. Structure of growing social networks. Physical review. E, Statistical, nonlinear, and soft matter physics 64: 046132.

Wilensky, U. 2005. NetLogo Small Worlds model. http://ccl.northwestern.edu/netlogo/models/SmallWorlds Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## CREDITS AND REFERENCES

Acknowledgements:
Thanks to Jeroen Poblome, Iza Romanowska, Jan Christoph Athenstaedt, Benjamin Davies, Mereke Van Garderen, David Schoch, Arlind Nocaj, David O'Sullivan and Viviana Amati for extensive comments on earlier versions of this model. These colleagues are not responsible for the final version of this model.
The model was created by Tom Brughmans.

The clustering coefficient (cc) measure used here is based on the small-world model in the Netlogo library
For an alternative calculation see http://www.ladamic.com/netlearn/NetLogo4/SmallWorldWS.nlogo

References:
Bang, P.F. 2008. The Roman bazaar, a comparative study of trade and markets in a tributary empire. Cambridge: Cambridge university press.

Bentley, R., M. Lake & S. Shennan. 2005. Specialisation and wealth inequality in a model of a clustered economic network Journal of Archaeological Science 32: 1346–56.

Jin, E.M., M. Girvan & M.E. Newman. 2001. Structure of growing social networks. Physical review. E, Statistical, nonlinear, and soft matter physics 64: 046132.

Temin, P. 2013. The Roman Market Economy. Princeton: Princeton University Press.

Watts, D.J. & S.H. Strogatz. 1998. Collective dynamics of “small-world” networks. Nature 393: 440–42. http://www.ncbi.nlm.nih.gov/pubmed/9623998.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment24-7-14" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20001"/>
    <steppedValueSet variable="seed" first="1" step="1" last="100"/>
    <enumeratedValueSet variable="network-structure">
      <value value="&quot;hypothesis&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-traders">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sites">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traders-distribution">
      <value value="&quot;exponential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transport-cost">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="local-knowledge">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-degree">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-inter-site-links">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-intra-site-links">
      <value value="5.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-mutual-neighbors">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layout?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-demand">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traders-production-site">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentTEST2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1"/>
    <steppedValueSet variable="seed" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="local-knowledge">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-inter-site-links">
      <value value="0.0010"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transport-cost">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-degree">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-mutual-neighbors">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-structure">
      <value value="&quot;hypothesis&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="traders-distribution">
      <value value="&quot;exponential&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="site-X">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-traders">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-intra-site-links">
      <value value="5.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-sites">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layout?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
