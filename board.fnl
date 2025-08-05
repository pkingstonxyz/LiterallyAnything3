(local fennel (require :lib.fennel))
(local push (require :lib.push))

{:grid [[:mt :mt :mt :mt]
        [:mt :mt :mt :mt]
        [:mt :mt :mt :mt]
        [:mt :mt :mt :mt]]
 :rows 4
 :cols 4
 :cellc 4
 :board-size-ratio 0.8
 :init
 (fn [self board]
   (set self.grid board)
   (set self.rows (length self.grid))
   (set self.cols (. (length self.grid) 1))
   (set self.cellc (math.max self.rows self.cols)))
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
 :draw
 (fn [self]
   (for [ri 1 self.rows]
     (for [ci 1 self.cols]
       (let [cell (. self.grid ri ci)
             (cx cy csize) (self:get-cell-coords-and-size ri ci)]
         ;(print cell)
         (case cell
           :wall :do-nothing
           :mt (do
                 (love.graphics.setColor 0.8 0.8 0.8 1)
                 (love.graphics.rectangle :fill cx cy csize csize))
           _ :no-match)))))}

