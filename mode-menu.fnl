(local push (require :lib.push))
(local countdown-time 60)
(var counter 0)
(var time 0)

(love.graphics.setNewFont 15)
(local titlefont (love.graphics.newFont 150))
(local textfont (love.graphics.newFont 40))

(local (major minor revision) (love.getVersion))
(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

{:activate 
 (fn [])
 :draw 
 (fn [_message]
   (local (w h) (push.getDimensions))
   (push.setCanvas :foreground)
   ; TODO: Add a simple unmerge example.
   (push.setCanvas :ui)
   (love.graphics.clear 0 0 0.1 1)
   (push.setCanvas :ui)
   (love.graphics.printf
     "menu" textfont 0 10 w :center)
   (love.graphics.printf 
     "select a level" textfont 0 50 w :center))
 :update 
 (fn [dt _set-mode]
   (if (< counter 65535)
     (set counter (+ counter 1))
     (set counter 0))
   (set time (+ time dt))
   (when (> time countdown-time)
     (set time 0)
     (love.event.quit)))
 :keypressed 
 (fn [key set-mode])}
