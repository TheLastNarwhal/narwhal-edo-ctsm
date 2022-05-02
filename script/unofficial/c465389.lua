--Witch of the Fen
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --On Summon add "Witch" Spell/Trap from Deck to hand
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  e1:SetCountLimit(1,id)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)
  --While "Witches' Domain" is on the field, "Witch" cards in your S&T Zone cannot be destroyed by card effects
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e3:SetRange(LOCATION_MZONE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetCondition(s.indcon)
  e3:SetTarget(s.indtg)
  e3:SetValue(1)
  c:RegisterEffect(e3)
  --During the Main Phase you can Special Summon 1 "Haunted Doll Token"
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,{id,1})
  e4:SetCondition(s.tkcon)
  e4:SetTarget(s.tktg)
  e4:SetOperation(s.tkop)
  c:RegisterEffect(e4)
  --Same effect as e4 but converted to Quick status if conditions met - sealed due to power
  --[[local e5=e4:Clone()
  e5:SetType(EFFECT_TYPE_QUICK_O)
  e5:SetCode(EVENT_FREE_CHAIN)
  local timing=TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON
  e5:SetHintTiming(timing,timing)
  e5:SetCondition(s.tkquickcon)
  c:RegisterEffect(e5)]]
  --Tribute 1 monster from hand or field, inflict damage to opponent equal to Tributed monster's ATK
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,1))
  e6:SetCategory(CATEGORY_DAMAGE)
  e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e6:SetType(EFFECT_TYPE_IGNITION)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCountLimit(1,{id,1})
  e6:SetCost(s.tribcost)
  e6:SetTarget(s.tribtg)
  e6:SetOperation(s.tribop)
  c:RegisterEffect(e6)
end
s.listed_series={0x197,0x2197}
s.listed_names={465386}
--On Summon add "Witch" Spell/Trap from Deck to hand
function s.thfilter(c)
  return c:IsSetCard(0x197) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--While "Witches' Domain" is on the field, "Witch" cards in your S&T Zone cannot be destroyed by card effects
function s.indcon(e)
  return Duel.IsEnvironment(465386)
end
function s.indtg(e,c)
  return c:IsSetCard(0x197) and not c:IsLocation(LOCATION_FZONE)
end
--
--
--------------Everything-below-this-line-is-token-related-------------
--
--
--Conditions to turn Token Summon into Quick - sealed due to power
--[[function s.tkquickcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() and Duel.IsEnvironment(465386)
end]]
--During the Main Phase you can Special Summon 1 "Demented Doll Token"
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() --and not Duel.IsEnvironment(465386)
end
function s.tkfilter(c)
  return c:IsCode(id+1)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) and not Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE,tp)<1 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp) then return end
  local token=Duel.CreateToken(tp,id+1)
  if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
    --There can only be 1 "Demented Doll Token" on the field
    token:SetUniqueOnField(1,1,id+1)
    --Cannot be Tributed for a Tribute Summon
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(3304)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(1)
    token:RegisterEffect(e1,true)
    --Cannot be used as material for Fusion, Synchro, or Link Summon
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO))
    token:RegisterEffect(e2,true)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e3:SetValue(1)
    token:RegisterEffect(e3,true)
    --Cannot be destroyed by battle
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetValue(1)
    token:RegisterEffect(e4,true)
    --You take no battle damage your opponent's attacks involving this card
    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e5:SetCondition(s.avoidcon)
    e5:SetValue(1)
    token:RegisterEffect(e5,true)
    --If attacked deal damage equal to ATK of attacker
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetCategory(CATEGORY_DAMAGE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_BATTLE_CONFIRM)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.damcon)
    e6:SetTarget(s.damtg)
    e6:SetOperation(s.damop)
    token:RegisterEffect(e6,true)
    --Shift type to effect, because it's clearly an effect monster even if it's a token
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e7:SetCode(EFFECT_REMOVE_TYPE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetValue(TYPE_NORMAL)
    token:RegisterEffect(e7,true)
    local e8=e7:Clone()
    e8:SetCode(EFFECT_ADD_TYPE)
    e8:SetValue(TYPE_EFFECT)
    token:RegisterEffect(e8,true)
  end
  Duel.SpecialSummonComplete()
end
--You take no battle damage your opponent's attacks involving this card
function s.avoidcon(e,tp,eg,ep,ev,re,r,rp)
  local d=Duel.GetAttackTarget()
  return d and d==e:GetHandler()
end
--If attacked deal damage equal to ATK of attacker
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler()==Duel.GetAttackTarget()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAttackPos() end
  Duel.SetTargetPlayer(1-tp)
  local atk=Duel.GetAttacker():GetAttack()
  Duel.SetTargetParam(atk)
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.witchfilter(c)
  return c:IsCode(465389)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  if Duel.Damage(p,d,REASON_EFFECT) then
    local atk=Duel.GetAttacker():GetAttack()
    local a=Duel.GetAttacker()
    local coin=Duel.SelectOption(tp,61,60)
    local res=Duel.TossCoin(tp,1)
    if coin==res then
      Duel.SendtoGrave(a,REASON_RULE)
    elseif coin~=res and Duel.IsExistingMatchingCard(s.witchfilter,tp,LOCATION_MZONE,0,1,nil) then
      Duel.Damage(tp,atk,REASON_EFFECT)
    else
      Duel.Damage(tp,atk*2,REASON_EFFECT)
    end
  end
end
--
--
--------------Everything-above-this-line-is-token-related-------------
--
--
--Tribute 1 monster from hand or field, inflict damage to opponent equal to Tributed monster's ATK
function s.tribfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsReleasable() and not c:IsCode(id)
end
function s.tribcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tribfilter,1,true,nil,nil,tp) end
  local sg=Duel.SelectReleaseGroupCost(tp,s.tribfilter,1,1,true,nil,nil,tp)
  e:SetLabel(sg:GetFirst():GetAttack())
  Duel.Release(sg,REASON_COST)
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetTargetPlayer(1-tp)
  Duel.SetTargetParam(e:GetLabel())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Damage(p,d,REASON_EFFECT)
end
