local scene = {}

local pool = {}
local keystate = {}
local ignore = { atack = true, stun = true, splaft = true, injury = true, attack = true }
local hits = 0
local game_over = false

function scene.on_enter()
  pool.slime = scene:get("slime", SceneType.object)
  pool.slime.action = "idle"
  pool.slime.placement = { x = 0, y = 0 }

  pool.hand = scene:get("hand", SceneType.object)
  pool.hand.action = "idle"
  pool.hand.placement = { x = 0, y = 0 }

  pool.label = overlay:create(WidgetType.label)
  pool.label.font = fontfactory:get("fixedsys")
  pool.label:set("Score 0", 540, 10)

  hits = 0
  game_over = false
end

function scene.on_loop(delta)
  if game_over then return end

  pool.slime.reflection = Reflection.none

  local colliding = world:collides(pool.slime, pool.hand)
  local pressing = statemanager:player(Player.one):on(Controller.south)
  if colliding then
    if pressing then
      if not keystate[Player.one] then
        keystate[Player.one] = true

        pool.hand.action = "attack"
        pool.slime.action = "splaft"

        hits = hits + 1
        local score = hits * 10
        pool.label:set("Score " .. score, 540, 10)

        local degrees = math.random(0, 35) * 10
        local radians = math.rad(degrees)
        local distance = math.random(0, 10) * 10
        local dx = math.cos(radians) * distance
        local dy = math.sin(radians) * distance

        pool.slime.x = pool.slime.x + dx
        pool.slime.y = pool.slime.y + dy

        if hits >= 5 then
          game_over = true
          timermanager:singleshot(1000, function()
            pool.slime.action = "atack"
          end)
        end
      end
    else
      keystate[Player.one] = false
    end
  end

  if ignore[pool.slime.action] or ignore[pool.hand.action] or game_over then
    return
  end

  local slime_moving = false
  local slime_action = "idle"

  if statemanager:player(Player.one):on(Controller.up) then
    pool.slime.y = pool.slime.y - 80 * delta
    slime_action = "up"
    slime_moving = true
  elseif statemanager:player(Player.one):on(Controller.down) then
    pool.slime.y = pool.slime.y + 80 * delta
    slime_action = "down"
    slime_moving = true
  end

  if statemanager:player(Player.one):on(Controller.left) then
    pool.slime.x = pool.slime.x - 80 * delta
    pool.slime.reflection = Reflection.horizontal
    if not slime_moving then
      slime_action = "side"
    end
    slime_moving = true
  elseif statemanager:player(Player.one):on(Controller.right) then
    pool.slime.x = pool.slime.x + 80 * delta
    if not slime_moving then
      slime_action = "side"
    end
    slime_moving = true
  end

  if slime_moving then
    pool.slime.action = slime_action
  else
    pool.slime.action = "idle"
  end

  if statemanager:player(Player.two):on(Controller.up) then
    pool.hand.y = pool.hand.y - 80 * delta
  elseif statemanager:player(Player.two):on(Controller.down) then
    pool.hand.y = pool.hand.y + 80 * delta
  end

  if statemanager:player(Player.two):on(Controller.left) then
    pool.hand.x = pool.hand.x - 80 * delta
  elseif statemanager:player(Player.two):on(Controller.right) then
    pool.hand.x = pool.hand.x + 80 * delta
  end
end

function scene.on_leave()
  for key in pairs(pool) do
    pool[key] = nil
  end

  for key in pairs(keystate) do
    keystate[key] = nil
  end

  hits = 0
  game_over = false
end

return scene
