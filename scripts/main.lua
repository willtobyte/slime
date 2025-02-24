---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine = EngineFactory.new()
    :with_title("Slime")
    :with_width(1920)
    :with_height(1080)
    :with_scale(3.0)
    :with_gravity(9.8)
    :with_fullscreen(false)
    :create()

local fontfactory = engine:fontfactory()
local scenemanager = engine:scenemanager()
local soundmanager = engine:soundmanager()
local entitymanager = engine:entitymanager()
local statemanager = engine:statemanager()
local overlay = engine:overlay()

local keystate = {}
local ignore = { atack = true, stun = true, splaft = true, injury = true }

local hand
local slime
local label

local slime_seq = {
  stun = "idle",
  splaft = "stun"
}

function setup()
  label      = overlay:create(WidgetType.label)
  label.font = fontfactory:get("fixedsys")
  label:set("Score 0", 540, 10)

  slime = entitymanager:spawn("slime")
  slime.action:set("idle")
  slime.placement:set(0, 0)
  slime:on_mail(function(self, message)
    local behavior = behaviors[message]
    if behavior then
      behavior(self)
    end
  end)
  slime:on_animationfinished(function(self, name)
    local nextAction = slime_seq[name]
    if nextAction then
      slime.action:set(nextAction)
    end
  end)

  hand = entitymanager:spawn("hand")
  hand.action:set("idle")
  hand.placement:set(0, 0)
  hand:on_animationfinished(function(self)
    local idle = "idle"
    for _, object in ipairs({ hand, slime }) do
      object.action:set(idle)
    end
  end)
  hand.kv:set("score", 0)
  hand.kv:subscribe("score", function(value)
    label:set("Score " .. value)

    if value > 30 then
      slime.action:unset()
      hand.action:set("injury")
      hand.kv:set("score", 0)
    end
  end)
  scenemanager:set("default")
end

function loop()
  hand.velocity.x, hand.velocity.y = 0, 0
  slime.velocity.x, slime.velocity.y = 0, 0
  slime.reflection:unset()

  if statemanager:collides(slime, hand) then
    if statemanager:player(Player.one):on(Controller.cross) then
      if not keystate[Player.one] then
        keystate[Player.one] = true
        local actions = {
          [hand] = "attack",
          [slime] = "splaft"
        }
        for object, action in pairs(actions) do
          object.action:set(action)
        end

        hand.kv:set("score", hand.kv:get("score") + 10)

        local degrees = math.random(0, 35) * 10
        local radians = math.rad(degrees)

        local distance = math.random(0, 10) * 10
        local dx = math.cos(radians) * distance
        local dy = math.sin(radians) * distance

        local p = slime.placement:get()

        slime.placement:set(p.x + dx, p.y + dy)
      else
        keystate[Player.one] = false
      end
    end
  end

  if ignore[slime.action:get()] or ignore[hand.action:get()] then
    return
  end

  if statemanager:player(Player.two):on(Controller.up) then
    slime.velocity.y = -80
  elseif statemanager:player(Player.two):on(Controller.down) then
    slime.velocity.y = 80
  end

  if statemanager:player(Player.two):on(Controller.left) then
    slime.velocity.x = -80
    slime.reflection:set(Reflection.horizontal)
  elseif statemanager:player(Player.two):on(Controller.right) then
    slime.velocity.x = 80
  end

  local action = "idle"
  if slime.velocity.y > 0 then
    action = "down"
  elseif slime.velocity.y < 0 then
    action = "up"
  elseif slime.velocity.x ~= 0 then
    action = "side"
  end
  slime.action:set(action)

  if statemanager:player(Player.one):on(Controller.up) then
    hand.velocity.y = -80
  elseif statemanager:player(Player.one):on(Controller.down) then
    hand.velocity.y = 80
  end

  if statemanager:player(Player.one):on(Controller.left) then
    hand.velocity.x = -80
  elseif statemanager:player(Player.one):on(Controller.right) then
    hand.velocity.x = 80
  end
end

function run()
  engine:run()
end
