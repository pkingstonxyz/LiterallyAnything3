(local push (require :lib.push))

(local
  button-prototype
  {:pressed false
   :xpos 140
   :ypos 300
   :width (- 600 (* 150 2))
   :height 60
   :message "Play"
   :colorA [1 1 1]
   :colorB [0 0 0]
   :board [:mt]
   :new
   (fn [self params]
     (let [btn (setmetatable (or params {}) {:__index self})]
       (when (?. params :xpos) (set btn.xpos params.xpos))
       (when (?. params :ypos) (set btn.ypos params.ypos))
       (when (?. params :width) (set btn.width params.width))
       (when (?. params :height) (set btn.height params.height))
       (when (?. params :message) (set btn.message params.message))
       (when (?. params :colorA) (set btn.colorA params.colorA))
       (when (?. params :colorB) (set btn.colorB params.colorB))
       (when (?. params :board) (set btn.board params.board))
       btn))
   :update
   (fn [self]
     (let [mousedown (love.mouse.isDown 1)
           rawmousex (love.mouse.getX)
           rawmousey (love.mouse.getY)
           (mouseX mouseY) (push.toGame rawmousex rawmousey)
           over (and mouseX mouseY
                     (>= mouseX self.xpos)
                     (<= mouseX (+ self.xpos self.width))
                     (>= mouseY self.ypos)
                     (<= mouseY (+ self.ypos self.height)))
           waspressed self.pressed]
       (set self.pressed (and over mousedown))
       (and over (not mousedown) waspressed)))
   :draw
   (fn [self]
     (love.graphics.setColor (if self.pressed self.colorA self.colorB))
     (love.graphics.rectangle :fill self.xpos self.ypos self.width self.height)
     (love.graphics.setColor (if self.pressed self.colorB self.colorA))
     (love.graphics.rectangle :line self.xpos self.ypos self.width self.height)
     (love.graphics.print self.message (+ self.xpos 10) (+ self.ypos 10))
     (love.graphics.setColor self.colorA))})

button-prototype
