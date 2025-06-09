(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))
(local push (require :lib.push))

;; setup mode switching infrastructure
(var (mode mode-name) nil)

(fn set-mode [new-mode-name ...]
  ;(set mode (require new-mode-name))
  ;(set mode-name new-mode-name)
  (set (mode mode-name) (values (require new-mode-name) new-mode-name))
  (when mode.activate
    (match (pcall mode.activate ...)
      (false msg) (print mode-name "activate error" msg))))

;; setup scaling resolution
(push.setupScreen 135 240 {:upscale :normal})

(fn love.resize [width height]
  (push.resize width height))

(fn love.load [args]
  (set-mode :mode-intro)
  (when (not= :web (. args 1)) (repl.start))) ; Start repl when not on the web

;; Allows us to run modal callbacks without errors breaking the whole system
(fn safely [f]
  (xpcall f #(set-mode :error-mode mode-name $ (fennel.traceback))))

(fn love.update [dt]
  (when mode.update
    (safely #(mode.update dt set-mode))))

;(fn love.keypressed [_key])
(fn love.keyreleased [key code isrepeat]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      ;; add what each keypress should do in each mode
      (not isrepeat)
      (safely #(mode.keypressed key set-mode))))

(fn love.draw []
  (push.start)
  (love.graphics.clear)
  (safely mode.draw)
  (love.graphics.setBackgroundColor 0.1 0.2 0.4)
  (love.graphics.rectangle :fill 0 0 2 2)
  (love.graphics.rectangle :fill 0 238 2 2)
  (love.graphics.rectangle :fill 133 0 2 2)
  (love.graphics.rectangle :fill 133 238 2 2)
  ;(let [(ran result) (pcall customdraw)]
  ;  (when (not ran)
  ;    (print result)))
  (push.finish))
