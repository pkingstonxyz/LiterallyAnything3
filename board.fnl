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
   (print "=====MADE NEW BOARD======")
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
   )
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
 :order-cells
 (fn order-cells [self direction]
   (local cells [])
   (let [(row-start row-end row-inc
          col-start col-end col-inc)
         (case direction
           :left  (values 1 self.rows 1
                          1 self.cols 1)
           :right (values 1 self.rows 1
                          self.cols 1 -1)
           :up    (values 1 self.rows 1
                          1 self.cols 1)
           :down  (values self.rows 1 -1
                          1 self.cols 1))]
     (for [row row-start row-end row-inc]
       (for [col col-start col-end col-inc]
         (let [cell (. self.grid row col)]
           (when (= :table (type cell))
             (table.insert cells cell)))))
     cells))
 :plan-and-move
 (fn [self cell direction]
  (let [
        {: row : col : value} cell
        
    is-empty (fn [r c]
      (and (>= r 1) (>= c 1)
           (<= r self.rows)
           (<= c self.cols)
           (= (. self.grid r c) :mt)))

    ; Find the final destination by sliding
    [dr dc] (case direction
              :up [-1 0]
              :down [1 0]
              :left [0 -1]
              :right [0 1])

    slide (fn slide [curr-r curr-c]
            (let [
              next-r (+ curr-r dr)
              next-c (+ curr-c dc)]
              (if (is-empty next-r next-c)
                  (slide next-r next-c)
                  [curr-r curr-c])))

    [final-row final-col] (slide row col)

    ; Calculate the coordinates for the split neighbor
    split-neighbor-row (- final-row dr)
    split-neighbor-col (- final-col dc)
    
    ; Check if that specific tile is empty
    has-split-space (or (and (= split-neighbor-row row) (= split-neighbor-col col))
                      (is-empty split-neighbor-row split-neighbor-col))

    ; Do the plan
    do-plan (fn [command]
              (print "Doing plan:")
              (pp command)
              (case command
                [:move cell targrow targcol]
                (let [{: row : col} cell]
                    (set (. self :grid row col) :mt)
                    (set (. self :grid targrow targcol) cell)
                    (cell:transition :moving targrow targcol))
                [:split cell targrow targcol freerow freecol]
                (let [{: row : col : value} cell
                      targtile (tile:new row col (/ value 2))
                      _ (targtile:transition :splitting-up targrow targcol)
                      freetile (tile:new row col (/ value 2))
                      _ (freetile:transition :splitting-up freerow freecol)]
                  (set (. self :grid row col) :mt)
                  (set (. self :grid targrow targcol) targtile)
                  (set (. self :grid freerow freecol) freetile)
                  )))]
    
    (print "Split-neighbs: " split-neighbor-row split-neighbor-col)
    ; Main logic
    (when (or (not= final-row row) (not= final-col col))
      ;When there's enough room and:
      (if (and (> value 2) has-split-space)
        ; If value > 2 and there is enough room, split
        (do-plan
          [:split cell final-row final-col split-neighbor-row split-neighbor-col])
        ; Otherwise, just move
        (do-plan 
          [:move cell final-row final-col])))))
 
 :move
 (fn [self direction]
   (let [cells (self:order-cells direction)]
     (each [_ cell (ipairs cells)]
       (self:plan-and-move cell direction))))
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

