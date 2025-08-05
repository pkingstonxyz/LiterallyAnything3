(local push (require :lib.push))
(local countdown-time 60)
(var counter 0)
(var time 0)

(love.graphics.setNewFont 15)
(local _titlefont (love.graphics.newFont 150))
(local textfont (love.graphics.newFont 40))
(local subtitlefont (love.graphics.newFont 20))

(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

(local levels (require :levels))
(local button (require :button))

(local buttons [])
(each [ind value (ipairs levels)]
  (let [{: title} value
        cellsize 100
        totalwidth 640 totalheight 400
        topx 80 topy 120
        rows (/ totalheight cellsize) cols (/ totalwidth cellsize)
        col (math.fmod (- ind 1) cols)
        row (math.floor (/ (- ind 1) rows))
        x (+ topx (* col cellsize))
        y (+ topy (* row cellsize))
        btn (button:new {:xpos x :ypos y :width (- cellsize 10) :height (- cellsize 10) :message title})]
    (table.insert buttons btn)))

{:activate 
 (fn [])
 :draw 
 (fn [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   (love.graphics.setColor 1 1 1 1)
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
