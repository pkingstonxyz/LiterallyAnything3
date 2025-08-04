(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))
(local push (require :lib.push))

;; setup mode switching infrastructure
(var (mode mode-name) nil)

(fn set-mode [new-mode-name ...]
  (set (mode mode-name) (values (require new-mode-name) new-mode-name))
  (when mode.activate
    (match (pcall mode.activate ...)
      (false msg) (print mode-name "activate error" msg))))

;; setup scaling resolution
(love.window.setMode (love.graphics.getWidth) (love.graphics.getHeight) {:resizable true})
(push.setupScreen 800 600 {:upscale :normal :canvas true :fullscreen true})

(fn love.resize [width height]
  (push.resize width height))

(fn love.load [args]
  (push.setupCanvas [{:name :foreground} {:name :ui}])
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
  ;; the canvas allows you to get sharp pixel-art style scaling; if you
  ;; don't want that, just skip that and call mode.draw directly.
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (push.start)
  (safely mode.draw)
  (push.finish)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1))
