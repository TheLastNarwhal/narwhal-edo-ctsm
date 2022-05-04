--Witch of the Moor
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --On Summon add "Witch" monster from Deck to hand
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
  --While "Witches' Domain" is on the field, "Witch" monsters you control cannot be destroyed by card effects
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e3:SetRange(LOCATION_MZONE)
  e3:SetTargetRange(LOCATION_ONFIELD,0)
  e3:SetCondition(s.indcon)
  e3:SetTarget(s.indtg)
  e3:SetValue(1)
  c:RegisterEffect(e3)
  --During the Main Phase you can Special Summon 1 "Demented Doll Token"
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,1))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,{id,1})
  e4:SetCondition(s.tkcon)
  e4:SetTarget(s.tktg)
  e4:SetOperation(s.tkop)
  c:RegisterEffect(e4)
  --Same effect as e4 but converted to Quick status if conditions met
  local e5=e4:Clone()
  e5:SetType(EFFECT_TYPE_QUICK_O)
  e5:SetCode(EVENT_FREE_CHAIN)
  local timing=TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON
  e5:SetHintTiming(timing,timing)
  e5:SetCondition(s.tkquickcon)
  c:RegisterEffect(e5)
  --During the End Phase, if you gained LP this turn, your opponent sends 1 monster they control to the GY, and if they do, add 1 monster from your GY to your hand
  local e6=Effect.CreateEffect(c)
  e6:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
  e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCode(EVENT_PHASE+PHASE_END)
  e6:SetCountLimit(1,{id,1})
  e6:SetCondition(s.sendcon)
  e6:SetTarget(s.sendtg)
  e6:SetOperation(s.sendop)
  c:RegisterEffect(e6)
  if not GhostBelleTable then GhostBelleTable={} end
  table.insert(GhostBelleTable,e6)
  --Sets flag for above effect
  local e7=Effect.CreateEffect(c)
  e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e7:SetCode(EVENT_RECOVER)
  e7:SetRange(LOCATION_MZONE)
  e7:SetCondition(s.flagcon)
  e7:SetOperation(s.flagop)
  c:RegisterEffect(e7)
end
s.listed_series={0x197,0x2197}
s.listed_names={465386,465388}
--On Summon add "Witch" monster from Deck to hand
function s.thfilter(c)
  return c:IsSetCard(0x197) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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
--While "Witches' Domain" is on the field, "Witch" monsters you control cannot be destroyed by card effects
function s.indcon(e)
  return Duel.IsEnvironment(465386)
end
function s.indtg(e,c)
  return (c:IsSetCard(0x197) and c:IsType(TYPE_MONSTER)) and not c:IsSetCard(0x2197)
end
--
--
--------------Everything-below-this-line-is-token-related-------------
--
--
--Conditions to turn Token Summon into Quick
function s.tkquickcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() and Duel.IsEnvironment(465386)
end
--During the Main Phase you can Special Summon 1 "Demented Doll Token"
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase() and not Duel.IsEnvironment(465386)
end
function s.tkfilter(c)
  return c:IsCode(id+1)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp) and not Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<1 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2197,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then return end
  local token=Duel.CreateToken(tp,id+1)
  if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
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
    --Cannot be destroyed card effects
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    token:RegisterEffect(e4,true)
    --Declare 1 card type, reveal top card of Deck, if card of that type, add to hand, else, send to the GY, then take 500 damage.
    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_DAMAGE+CATEGORY_HANDES)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EVENT_PREDRAW)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.condition)
    e5:SetTarget(s.target)
    e5:SetOperation(s.operation)
    token:RegisterEffect(e5,true)
    --Shift type to effect, because it's clearly an effect monster even if it's a token
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e6:SetCode(EFFECT_REMOVE_TYPE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetValue(TYPE_NORMAL)
    token:RegisterEffect(e6,true)
    local e7=e6:Clone()
    e7:SetCode(EFFECT_ADD_TYPE)
    e7:SetValue(TYPE_EFFECT)
    token:RegisterEffect(e7,true)
  end
  Duel.SpecialSummonComplete()
end
--Token related functions
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
  local op=Duel.SelectOption(tp,70,71,72)
  if op==0 then
    e:SetLabel(TYPE_MONSTER)
  elseif op==1 then
    e:SetLabel(TYPE_SPELL)
  else
    e:SetLabel(TYPE_TRAP)
  end
end
function s.discfilter(c)
  return c:IsCode(465387)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
  if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local rc=Duel.GetDecktopGroup(tp,1):GetFirst()
  if not rc then return end
  Duel.ConfirmDecktop(tp,1)
  if rc:IsType(e:GetLabel()) then
    Duel.DisableShuffleCheck()
    Duel.SendtoHand(rc,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,rc)
    Duel.ShuffleHand(tp)
  else
    Duel.DisableShuffleCheck()
    if Duel.SendtoGrave(rc,REASON_EFFECT+REASON_REVEAL) then
      if Duel.Damage(tp,500,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
        if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
        local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local sg1=g1:Select(tp,1,1,nil)
        Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_DISCARD)
        Duel.ConfirmCards(1-tp,sg1)
        Duel.ShuffleHand(tp)
      end
    end
  end
end
--
--
--------------Everything-above-this-line-is-token-related-------------
--
--
--Sets flag for LP gain
function s.flagcon(e,tp,eg,ep,ev,re,r,rp)
  return ep==tp
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
  e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
end
--During your End Phase, if you gained LP this turn, your opponent sends 1 monster they control to the GY, and if they do, add 1 monster from your GY to your hand
function s.gyfilter(c,ty)
  return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetFlagEffect(id)>0
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
function s.sendfilter(c)
  return not c:IsSetCard(0x2197)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(s.sendfilter,1-tp,LOCATION_MZONE,0,1,nil)
  if #g>0 then
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
    local sg=g:Select(1-tp,1,1,nil)
    Duel.HintSelection(sg)
    if Duel.SendtoGrave(sg,REASON_RULE) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local th=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,1,nil)
      if #th>0 then
        Duel.SendtoHand(th,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,th)
        Duel.ShuffleHand(tp)
      end
    end
  end
end
