(local push (require :lib.push))
(local countdown-time 60)
(var counter 0)
(var time 0)

(local globals (require :globals))

(local titlefont globals.titlefont)
(local textfont globals.textfont)

(local (major minor revision) (love.getVersion))
(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

{:activate 
 (fn [])
 :draw 
 (fn [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   (love.graphics.clear globals.bgcolor)
   ; TODO: Add a simple unmerge example.
   (push.setCanvas :ui)
   ;(love.graphics.setColor 0.13 0.13 0.23 1)
   (love.graphics.printf
     "8402" titlefont 0 10 w :center)
   (love.graphics.printf 
     "2048, but upside down." textfont 0 200 w :center)
   (love.graphics.printf 
     "Slide tiles to unmerge them." textfont 0 250 w :center)
   (love.graphics.printf 
     "Press p to play" textfont 0 520 w :center))
 :update 
 (fn [_dt _set-mode])
 :keypressed 
 (fn [key set-mode]
   (if (= key :p)
     (set-mode :mode-menu)))}
