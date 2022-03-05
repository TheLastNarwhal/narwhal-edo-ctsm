--Dine 'n Dash!
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activation
  local e1=Ritual.AddProcGreater({
    handler=c,
    filter=s.ritualfil,
    matfilter=s.forcedgroup,
    extrafil=s.extramat,
    --extratg=s.extratg --for some reason this wouldn't work
  })
  e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
  e1:SetCost(s.cost)
  c:RegisterEffect(e1)
end
s.listed_names={30243636}
s.listed_series={0x195}
--Allowed summons filter
function s.ritualfil(c)
  return c:IsSetCard(0x195) or c:IsCode(30243636)
end
--Activation cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
  Duel.SetChainLimit(aux.FALSE) --had to set up here for it to work
end
--Forces onfield monster use only
function s.forcedgroup(c,e,tp)
  return c:IsLocation(LOCATION_ONFIELD)
end
--Allows use of opponent's monsters for ritual
function s.matfilter(c)
  return c:HasLevel() and c:IsFaceup()
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
  return Duel.GetMatchingGroup(s.matfilter,tp,0,LOCATION_MZONE,nil)
end
--Cannot be responded to
--don't know why this didn't work
--function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
--  if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
--    Duel.SetChainLimit(aux.FALSE)
--	end
--end
