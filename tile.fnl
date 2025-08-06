(local fennel (require :lib.fennel))

;(local colorkey
   ;  {2    {:light [1.00 0.60 0.60] :dark [0.87 0.00 0.00]}
       ;   4    {:light [1.00 0.89 0.76] :dark [0.32 0.74 0.32]}
       ;   8    {:light [0.74 0.93 0.93] :dark [0.18 0.77 0.77]}
       ;   16   {:light [0.77 0.91 0.77] :dark [0.94 0.55 0.00]}
       ;   32   {:light [0.71 0.69 0.90] :dark [0.30 0.25 0.78]}
       ;   64   {:light [0.87 0.00 0.00] :dark [1.00 0.60 0.60]}
       ;   128  {:light [0.32 0.74 0.32] :dark [1.00 0.89 0.76]}
       ;   256  {:light [0.18 0.77 0.77] :dark [0.74 0.93 0.93]}
       ;   512  {:light [0.94 0.55 0.00] :dark [0.77 0.91 0.77]}
       ;   1024 {:light [0.30 0.25 0.78] :dark [0.71 0.69 0.90]}
       ;   2048 {:light [1 1 1] :dark [0 0 0]}})
(local colorkey
  {2   {:light [0.95 0.98 0.99] :dark [0.24 0.45 0.60]}
   4   {:light [0.85 0.94 0.97] :dark [0.24 0.45 0.60]}
   8   {:light [0.70 0.88 0.92] :dark [0.00 0.00 0.00]}
   16  {:light [0.55 0.81 0.88] :dark [0.00 0.00 0.00]}
   32  {:light [0.40 0.74 0.83] :dark [0.00 0.00 0.00]}
   64  {:light [0.25 0.67 0.77] :dark [0.00 0.00 0.00]}
   128 {:light [0.65 0.55 0.75] :dark [1.00 1.00 1.00]}
   256 {:light [0.78 0.45 0.79] :dark [1.00 1.00 1.00]}
   512 {:light [0.89 0.35 0.78] :dark [1.00 1.00 1.00]}
   1024 {:light [0.96 0.25 0.75] :dark [1.00 1.00 1.00]}
   2048 {:light [0.99 0.90 0.95] :dark [0.60 0.24 0.45]}
   })


(local GoalTile
  {:new
   (fn [self row col val board]
     (let [(xpos ypos csize) (board:get-cell-coords-and-size row col)
           tile {:xpos xpos
                 :ypos ypos
                 :csize csize
                 :val val
                 :lightcolor (. colorkey val :light)
                 :darkcolor (. colorkey val :dark)}]
       (setmetatable tile {:__index self})
       tile))
   :draw
   (fn [self]
     (let [(lr lg lb) (unpack self.lightcolor)
           (dr dg db) (unpack self.darkcolor)]
       (love.graphics.setColor lr lg lb 0.6)
       (love.graphics.rectangle :fill self.xpos self.ypos self.csize self.csize)
       (love.graphics.setColor dr dg db 1)
       (love.graphics.print self.val self.xpos self.ypos)
       ))})

(local Tile 
  {:base-move-duration 0.16
   :new-goaltile
   (fn [_self row col val board]
     (GoalTile:new row col val board))
   :new ; Make a new tile
   (fn [self row col val]
     (let [tile {:row row
                 :col col
                 :value val
                 :just-merged false
                 :mode :spawning}]
       (setmetatable tile {:__index self})
       (tile:transition :spawning row col)
       tile))
   :call 
   (fn [self callback ...]
     (let [currentmode self.mode
           modalcallbacks (. self currentmode)
           callbackfn (?. modalcallbacks callback)]
       (when callbackfn
         (callbackfn self ...))))
   :transition
   (fn [self tostate ...]
     (let [currentmodalcallbacks (?. self self.mode)
           nextmodalcallbacks (?. self tostate)
           entryfn (?. nextmodalcallbacks :entry)
           exitfn (?. currentmodalcallbacks :exit)]
       (when exitfn
         (exitfn self ...))
       (when entryfn
         (entryfn self ...))))})

(set
  Tile.spawning
  {:entry
   (fn [self row col]
     (set self.mode :spawning)
     (set self.row row)
     (set self.col col)
     (set self.spawning-data
          {:duration (* 6 Tile.base-move-duration)
           :elapsed 0
           :scale 0}))
   :update
   (fn [self dt]
     (set self.spawning-data.elapsed (+ self.spawning-data.elapsed dt))
     (let [progress (/ self.spawning-data.elapsed self.spawning-data.duration)]
       (set self.spawning-data.scale progress)
       (when (<= 1.0 progress)
         (set self.spawning-data {})
         (self:transition :idle self.row self.col))))
   :draw
   (fn [self board]
     (let [{: row : col : value} self
           (cx cy csize) (board:get-cell-coords-and-size row col)
           new-csize (* csize self.spawning-data.scale)
           cx (- cx (/ (- new-csize csize) 2))
           cy (- cy (/ (- new-csize csize) 2))]
       (love.graphics.setColor (. colorkey value :dark))
       (love.graphics.setLineWidth 5)
       (love.graphics.rectangle :line cx cy new-csize new-csize)
       (love.graphics.setColor (. colorkey value :light))
       (love.graphics.rectangle :fill cx cy new-csize new-csize)
       (when (> self.spawning-data.scale 0.3)
         (love.graphics.setColor (. colorkey value :dark))
         (love.graphics.print value cx cy))))})

(set
  Tile.idle
  {:entry
   (fn [self row col]
     (set self.mode :idle)
     (set self.row row)
     (set self.col col))
   ;:update
   ;(fn [self dt]
      ;  (let [key (love.keypressed)]))
   :draw
   (fn [self board]
     (let [{: row : col : value} self
           (cx cy csize) (board:get-cell-coords-and-size row col)]
       (love.graphics.setColor (. colorkey value :dark))
       (love.graphics.setLineWidth 5)
       (love.graphics.rectangle :line cx cy csize csize)
       (love.graphics.setColor (. colorkey value :light))
       (love.graphics.rectangle :fill cx cy csize csize)
       (love.graphics.setColor (. colorkey value :dark))
       (love.graphics.print value cx cy)))})

(set
  Tile.moving
  {
   :entry
   (fn [self targetrow targetcol]
     ;(print "Now moving to:" targetrow targetcol)
     (let [distance (math.max (math.abs (- self.row targetrow))
                              (math.abs (- self.col targetcol)))
           originrow self.row
           origincol self.col]
       (when (< 0 distance) ;There's distance to move
         (set self.mode :moving)
         (set self.row targetrow)
         (set self.col targetcol)
         (set self.moving-data
              {:originrow originrow
               :origincol origincol
               :intermediaterow originrow
               :intermediatecol origincol
               :elapsed 0
               ;:duration (* distance self.base-move-duration)
               :duration self.base-move-duration
               }))))
   :update
   (fn [self dt]
     ;(print "Elapsed:" self.moving.elapsed)
     (set self.moving-data.elapsed (+ self.moving-data.elapsed dt))
     (let [progress (/ self.moving-data.elapsed self.moving-data.duration)
           {: row : col} self
           originrow self.moving-data.originrow
           origincol self.moving-data.origincol
           ;eased-progress (- 1 (math.pow (- 1 progress) 3))
           nextintermediaterow (+ originrow (* (- row originrow) progress))
           nextintermediatecol (+ origincol (* (- col origincol) progress))]
       ;(print "Duration:" self.moving.duration)
       ;(print "Progress:" progress)
       (set self.moving-data.intermediaterow nextintermediaterow)
       (set self.moving-data.intermediatecol nextintermediatecol)
       (when (<= 1.0 progress)
         ;(print "Done moving")
         ;(pp self)
         (set self.moving-data {})
         (self:transition :idle self.row self.col))))
   :draw
   (fn [self board]
     (let [{: value} self
           {: intermediaterow : intermediatecol} self.moving-data
           (cx cy csize) (board:get-cell-coords-and-size intermediaterow intermediatecol)]
       (love.graphics.setColor (. colorkey value :dark))
       (love.graphics.setLineWidth 5)
       (love.graphics.rectangle :line cx cy csize csize)
       (love.graphics.setColor (. colorkey value :light))
       (love.graphics.rectangle :fill cx cy csize csize)
       (love.graphics.setColor (. colorkey value :dark))
       (love.graphics.print value cx cy)
       ;(pp self)
     ))
   })
   
Tile
