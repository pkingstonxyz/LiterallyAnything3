(local push (require :lib.push))

(local globals (require :globals))
(local titlefont globals.titlefont)
(local textfont globals.textfont)
(local subtitlefont globals.subtitlefont)

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
   (love.graphics.clear globals.bgcolor)
   ;(love.graphics.setColor 1 1 1 1)
   ;(love.graphics.rectangle :fill 80 120 640 400)
   (board:draw)
   (push.setCanvas :ui)
   (love.graphics.printf
     level textfont 0 10 w :center)
   (love.graphics.print
     "<- press m for menu" subtitlefont 0 0)
   (love.graphics.setColor 0 0 0 0.7)
   (love.graphics.rectangle :fill 0 0 w h)
   (love.graphics.setColor [1 1 1])
   (love.graphics.printf
     "You won!" titlefont 0 0 w :center)
   
   (love.graphics.printf
     "Return to the menu to select the next level by pressing m" globals.textfont (* 0.1 w) (/ h 3) (* 0.8 w) :center)
   
   (love.graphics.printf
     "(Or if you won thanks for playing! Rate my game pls :)" globals.textfont (* 0.1 w) (/ (* 2 h) 3) (* 0.8 w) :center)
   )
 :update 
 (fn update [dt _set-mode]
   (board:update dt))
 :keypressed 
 (fn keypressed [key set-mode]
   (if (= key :m)
     (set-mode :mode-menu)))}
