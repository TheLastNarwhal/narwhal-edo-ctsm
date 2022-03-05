 --Hungry Hot Dog
 --Scripted by Narwhal
 local s,id=GetID()
 function s.initial_effect(c)
   c:EnableReviveLimit()
   --Register summon w/ "Hot Dog Recipe"
   local e0=Effect.CreateEffect(c)
   e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
   e0:SetCode(EVENT_SPSUMMON_SUCCESS)
   e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
   e0:SetCondition(s.regcon)
   e0:SetOperation(s.regop)
   c:RegisterEffect(e0)
   --Add counters when ritual summoned w/ "Hot Dog Recipe"
   local e1=Effect.CreateEffect(c)
   e1:SetCategory(CATEGORY_COUNTER)
   e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
   e1:SetProperty(EFFECT_FLAG_DELAY)
   e1:SetCode(EVENT_SPSUMMON_SUCCESS)
   e1:SetCondition(s.regcon)
   e1:SetOperation(s.addc)
   c:RegisterEffect(e1)
   --Remove counters for bounce if summoned w/ "Hot Dog Recipe"
   local e2=Effect.CreateEffect(c)
   e2:SetCategory(CATEGORY_TOHAND)
   e2:SetType(EFFECT_TYPE_IGNITION)
   e2:SetRange(LOCATION_MZONE)
   e2:SetCondition(s.flagcheck)
   e2:SetCost(s.bcost)
   e2:SetTarget(s.btg)
   e2:SetOperation(s.bop)
   c:RegisterEffect(e2)
   --Allows the BK Hungry Burger tribute dodge to work
   	Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsCode,99995628))
 end
s.listed_names={99995620,30243636}
s.counter_place_list={0x1042}
--Register ritual summon by Hot Dog Recipe
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
  if not re and e then return false end
  return re:GetHandler():IsCode(99995620) and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
  e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
--Counters on ritual summon if ritual summoned with Hot Dog Recipe
function s.cfilter(c)
  return c:IsFaceup() and c:IsSetCard(0x195) or c:IsCode(30243636)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
  if e:GetHandler():IsRelateToEffect(e) then
    local
    ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil)
    e:GetHandler():AddCounter(0x1042,ct)
  end
end
--Check to see if summoned w/ "Hot Dog Recipe"
function s.flagcheck(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end
--Remove counters for bounce if summoned w/ "Hot Dog Recipe"
function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1042,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x1042,2,REASON_COST)
end
function s.bfilter(c)
  return c:IsAbleToHand()
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.bfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
    --No activation and effects of returned monster 'til end of turn
    local tc=g:GetFirst()
    if tc:IsLocation(LOCATION_HAND,LOCATION_HAND) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
      e1:SetCode(EFFECT_CANNOT_ACTIVATE)
      e1:SetTargetRange(1,1)
      e1:SetValue(s.aclimit)
      e1:SetLabelObject(tc)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end
end
function s.aclimit(e,re,tp)
  local tc=e:GetLabelObject()
  return re:GetHandler():IsCode(tc:GetCode())
end
