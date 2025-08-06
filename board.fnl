(local fennel (require :lib.fennel))
(local push (require :lib.push))
(local tile (require :tile))
(fn pp [x] (print (fennel.view x)))

(local baton (require :lib.baton))
(local input
  (baton.new
    {:controls
     {:left [:key:left :key:a :axis:leftx- :button:dpleft]
      :right [:key:right :key:d :axis:leftx+ :button:dpright]
      :up [:key:up :key:w :axis:lefty- :button:dpup]
      :down [:key:down :key:s :axis:lefty+ :button:dpdown]}
     :pairs
     {:move [:left :right :up :down]}}))

{:grid [[:mt :mt :mt :mt]
        [:mt :mt :mt :mt]
        [:mt :mt :mt :mt]
        [:mt :mt :mt :mt]]
 :goal [[:mt]]
 :rows 4
 :cols 4
 :cellc 4
 :board-size-ratio 0.8
 :init
 (fn [self board]
   (set self.grid [])
   (set self.goal [])
   (set self.rows (length board))
   (set self.cols (. (length board) 1))
   (set self.cellc (math.max self.rows self.cols))
   (for [ri 1 self.rows]
     (let [gridrow []
           goalrow []]
       (for [ci 1 self.cols]
         (let [cell (. board ri ci)]
           ;; Construct board
           (case cell
             :2 (table.insert gridrow (tile:new ri ci 2))
             :4 (table.insert gridrow (tile:new ri ci 4))
             :8 (table.insert gridrow (tile:new ri ci 8))
             :16 (table.insert gridrow (tile:new ri ci 16))
             :32 (table.insert gridrow (tile:new ri ci 32))
             :64 (table.insert gridrow (tile:new ri ci 64))
             :128 (table.insert gridrow (tile:new ri ci 128))
             :256 (table.insert gridrow (tile:new ri ci 256))
             :512 (table.insert gridrow (tile:new ri ci 512))
             :1024 (table.insert gridrow (tile:new ri ci 1024))
             :2048 (table.insert gridrow (tile:new ri ci 2048))
             :wall (table.insert gridrow :wall)
             _ (table.insert gridrow :mt))
           ;; Construct goal
           (if (= :number (type cell)) ; If it's a number
             (table.insert goalrow (tile:new-goaltile ri ci cell self)) ; Make a goal tile
             (if (not= cell :wall) ; the not-wall is important as it will match
               (table.insert goalrow :mt)
               (table.insert goalrow :wall)))))
       (table.insert self.goal goalrow)
       (table.insert self.grid gridrow)))
   (print "GRID")
   (pp self.grid)
   (print "GOAl")
   (pp self.goal))
 :get-bsize-and-coords
 (fn [self]
   (let [(wwidth wheight) (push.getDimensions)
         cellsize (/ wheight (+ 1 self.cellc))
         bsize (* cellsize self.cellc)
         bx (/ (- wwidth bsize) 2)
         by (/ (- wheight bsize (- 40)) 2)]
     (values bsize bx by)))
 :get-cell-coords-and-size
 (fn [self row col]
   (let [(bsize bx by) (self:get-bsize-and-coords)
         room (/ bsize (+ self.cellc 0.6))
         cellsize (/ bsize (+ self.cellc 1))
         celloffset (- room cellsize)]
     (values (+ (* (- col 1) (+ cellsize celloffset))
                bx celloffset)
             (+ (* (- row 1) (+ cellsize celloffset))
                by celloffset)
             cellsize)))
 :can-move
 (fn [self]
   (var all-idle? true)
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.grid ri ci)]
         (when (and (= :table (type cell)) (not= :idle cell.mode))
           ;(print cell)
           (set all-idle? false)))))
   all-idle?)
 :move
 (fn [self direction]
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.grid ri ci)]
         (case cell
           :wall :floor
           :mt :bar
           _ (cell:transition :moving 4 4)))))
   (print "Moving! " direction))
 :update
 (fn [self dt]
   ; Update input
   (input:update)
   ; Move cells
   (let [(x y) (input:get :move)
         direction (case [x y]
       [1 0] :right
       [-1 0] :left
       [0 1] :down
       [0 -1] :up
       _ nil)]
     (when (and direction (self:can-move))
       (self:move direction)))
   ; Update all cells
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.grid ri ci)
             (cx cy csize) (self:get-cell-coords-and-size ri ci)]
         (case cell
           :wall :do-nothing
           :mt   :do-nothing
           _ (cell:call :update dt))))))
 :draw
 (fn [self]
   ;; Draw the base floor
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.goal ri ci)
             (cx cy csize) (self:get-cell-coords-and-size ri ci)]
         (case cell
           :wall :do-nothing
           :mt (do
                 (love.graphics.setColor 0.7 0.7 0.7 1)
                 (love.graphics.rectangle :fill (- cx 6) (- cy 6) 
                                          (+ csize 12) (+ csize 12))
                 (love.graphics.setColor 0.8 0.8 0.8 1)
                 (love.graphics.rectangle :fill cx cy csize csize))
           _ (do
                 (love.graphics.setColor 0.7 0.7 0.7 1)
                 (love.graphics.rectangle :fill (- cx 6) (- cy 6) 
                                          (+ csize 12) (+ csize 12))
                 (love.graphics.setColor 0.8 0.8 0.8 1)
                 (love.graphics.rectangle :fill cx cy csize csize)
                 (cell:draw))))))
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.grid ri ci)
             (cx cy csize) (self:get-cell-coords-and-size ri ci)]
         (case cell
           :wall :do-nothing
           :mt   :do-nothing
           _ (cell:call :draw self)))))
   )}

