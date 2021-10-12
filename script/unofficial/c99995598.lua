--Bastet, the Ancient Deity of Protection
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	--constant indestructable battle
  local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(s.target)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
  --token
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_TO_GRAVE)
  e2:SetCountLimit(1,id)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end
--constant no destroy battle
function s.target(e,c)
  return c~=e:GetHandler() and c:IsSetCard(0x194)
end
  s.listed_series={0x194}
  function s.indcon(e)
  	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
--token creation
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0x194,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) end
  Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,99995599,0x194,TYPES_TOKEN,2000,0,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
    local token=Duel.CreateToken(tp,id+1)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
  end
end
