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

(var level "")

{:activate 
 (fn [{: board : title}]
   (pp board)
   (set level title)
   )
 :draw 
 (fn [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   (love.graphics.setColor 1 1 1 1)
   ;(love.graphics.rectangle :fill 80 120 640 400)
   (push.setCanvas :ui)
   (love.graphics.printf
     level textfont 0 10 w :center)
   (love.graphics.print
     "<- press m for menu" subtitlefont 0 0)
   )
 :update 
 (fn [dt set-mode])
 :keypressed 
 (fn [key set-mode]
   (if (= key :m)
     (set-mode :mode-menu)))}
