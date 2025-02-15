---@diagnostic disable: undefined-global, undefined-field, lowercase-global

local io
local postalservice
local fontfactory
local scenemanager
local soundmanager
local entitymanager
local statemanager
local timemanager
local overlay

local keystate = {}
local ignore = { atack = true, stun = true, splaft = true, injury = true }

local hand
local slime

local score

local slime_seq = {
  stun = "idle",
  splaft = "stun"
}

function setup()
  _G.engine = EngineFactory.new()
      :with_title("Slime")
      :with_width(1920)
      :with_height(1080)
      :with_scale(3.0)
      :with_gravity(9.8)
      :with_fullscreen(false)
      :create()

  entitymanager = engine:entitymanager()
  fontfactory = engine:fontfactory()
  scenemanager = engine:scenemanager()
  soundmanager = engine:soundmanager()
  statemanager = engine:statemanager()
  overlay = engine:overlay()

  score = overlay:create(WidgetType.label)
  score.font = fontfactory:get("fixedsys")
  score:set("Score 9999", 540, 10)

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
    local next = slime_seq[name]
    if next then
      slime.action:set(next)
    end
  end)

  hand = entitymanager:spawn("hand")
  hand.action:set("idle")
  hand.placement:set(0, 0)

  hand:on_animationfinished(function(self)
    hand.action:set("idle")
    slime.action:set("idle")
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
        hand.action:set("attack")
        slime.action:set("splaft")
      else
        keystate[Player.one] = false
      end
    end
  end

  if ignore[slime.action:get()] or ignore[hand.action:get()] then
    return
  end

  if statemanager:player(Player.one):on(Controller.up) then
    slime.velocity.y = -80
  elseif statemanager:player(Player.one):on(Controller.down) then
    slime.velocity.y = 80
  end

  if statemanager:player(Player.one):on(Controller.left) then
    slime.velocity.x = -80
    slime.reflection:set(Reflection.horizontal)
  elseif statemanager:player(Player.one):on(Controller.right) then
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

  if statemanager:player(Player.two):on(Controller.up) then
    hand.velocity.y = -80
  elseif statemanager:player(Player.two):on(Controller.down) then
    hand.velocity.y = 80
  end
  if statemanager:player(Player.two):on(Controller.left) then
    hand.velocity.x = -80
  elseif statemanager:player(Player.two):on(Controller.right) then
    hand.velocity.x = 80
  end
end

function run()
  engine:run()
end
