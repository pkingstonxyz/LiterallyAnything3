(local push (require :lib.push))

(local globals (require :globals))

(local textfont globals.textfont)
(local subtitlefont globals.subtitlefont)

(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

(local levels (require :levels))
(local button (require :button))

(local buttons [])
(each [ind value (ipairs levels)]
  (let [{: title : board} value
        cellsize 100
        totalwidth 640 totalheight 400
        topx 80 topy 120
        rows (/ totalheight cellsize) cols (/ totalwidth cellsize)
        col (math.fmod (- ind 1) cols)
        row (math.floor (/ (- ind 1) rows))
        x (+ topx (* col cellsize))
        y (+ topy (* row cellsize))
        btn (button:new {:xpos x :ypos y :width (- cellsize 10) :height (- cellsize 10) :message title :board board :colorA [1 1 1 1] :colorB globals.bgcolor})]
    (table.insert buttons btn)))

{:activate 
 (fn [])
 :draw 
 (fn [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   (love.graphics.clear globals.bgcolor)
   (each [_idx btn (ipairs buttons)]
     (btn:draw))
   ;(love.graphics.rectangle :fill 80 120 640 400)
   (push.setCanvas :ui)
   (love.graphics.printf
     "menu" textfont 0 10 w :center)
   (love.graphics.printf 
     "select a level" textfont 0 50 w :center)
   (love.graphics.print
     "<-press t for the title screen" subtitlefont 0 0))
 :update 
 (fn [dt set-mode]
   (each [_idx btn (ipairs buttons)]
     (let [btnstatus (btn:update)]
       (if btnstatus
         (set-mode :mode-playing {:board btn.board 
                                  :title btn.message})))))
 :keypressed 
 (fn [key set-mode]
   (if (= key :t)
     (set-mode :mode-intro)))}
