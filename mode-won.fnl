(local push (require :lib.push))

(love.graphics.setNewFont 15)
(local titlefont (love.graphics.newFont 150))
(local textfont (love.graphics.newFont 40))
(local subtitlefont (love.graphics.newFont 20))

(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

(var level "")

(var board (require :board))


{:activate 
 (fn activate [params]
   (let [brd params.board
         title params.title]
     (set board brd)
     (set level title)))
 :draw 
 (fn draw [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   ;(love.graphics.setColor 1 1 1 1)
   ;(love.graphics.rectangle :fill 80 120 640 400)
   (board:draw)
   (push.setCanvas :ui)
   (love.graphics.setColor 1 1 1 1)
   (love.graphics.printf
     level textfont 0 10 w :center)
   (love.graphics.print
     "<- press m for menu" subtitlefont 0 0)
   (love.graphics.setColor 0 0 0 0.3)
   (love.graphics.rectangle :fill 0 0 w h)
   (love.graphics.setColor [1 1 1])
   (love.graphics.printf
     "You won!" titlefont 0 (/ h 2) w :center)
   )
 :update 
 (fn update [dt _set-mode]
   (board:update dt))
 :keypressed 
 (fn keypressed [key set-mode]
   (if (= key :m)
     (set-mode :mode-menu)))}
