(local push (require :lib.push))
(local countdown-time 60)
(var counter 0)
(var time 0)

(love.graphics.setNewFont 15)

(local (major minor revision) (love.getVersion))
(local fennel (require :lib.fennel))
(fn pp [x] (print (fennel.view x)))

{:activate (fn activate [])
 :draw (fn draw [message]
         (local (w h) (push.getDimensions))
         (love.graphics.printf
          (: "Love Version: %s.%s.%s"
             :format  major minor revision) 0 10 w :center)
         (love.graphics.printf
          (: "This window should close in %0.1f seconds"
             :format (math.max 0 (- countdown-time time)))
          0 (- (/ h 2) 15) w :center))
 :update (fn update [dt set-mode]
             (if (< counter 65535)
                 (set counter (+ counter 1))
                 (set counter 0))
             (set time (+ time dt))
             (when (> time countdown-time)
               (set time 0)
               (love.event.quit)))
 :keypressed (fn keypressed [key set-mode])}
