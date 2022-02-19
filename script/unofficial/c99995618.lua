--Olga the Terrible
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  c:SetSPSummonOnce(id)
  --Special Summon
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
  e1:SetTargetRange(POS_FACEUP_ATTACK,0)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1)
  e1:SetCondition(s.spcon)
  c:RegisterEffect(e1)
 --Apply appropriate effect, depending on dice results
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,0))
 e2:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1)
 e2:SetTarget(s.target)
 e2:SetOperation(s.operation)
 c:RegisterEffect(e2)
end
--Special Summon
s.listed_names={15744417}
function s.spfilter(c)
  return c:IsFaceup() and c:IsCode(15744417)
end
function s.spcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
    and	Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
s.roll_dice=true

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,3)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res,atk={0,0,0,0,0,0,0,false,false,false,false},0
	for _,i in ipairs({Duel.TossDice(tp,3)}) do
		atk=atk-(i*100)
		res[i]=res[i]+1
		if res[i]>=2 then
			res[(i+1)//2+7]=true
		end
		res[11]=res[i]==3
	end
  --Drop opponent ATK/DEF based on dice roll
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(atk)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0,LOCATION_MZONE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e2)
  if res[1+7] or res[11] then
    --Cannot be destroyed by battle or card effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(3008)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)
  end
  if res[2+7] or res[11] then
  --Opponent discards 2 random cards
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetCondition(s.condition)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    c:RegisterEffect(e3)
  end
  function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp
  end
  function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
  end
  function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
    local sg=g:RandomSelect(ep,2)
    Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
  end
  if res[3+7] or res[11] then
  --SS Orgoth from hand, GY, or banished
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1)
  e4:SetTarget(s.sptg2)
  e4:SetOperation(s.spop2)
  e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
  c:RegisterEffect(e4)
end
function s.spfilter2(c,e,tp)
	return c:IsCode(15744417) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  if e:GetHandler():GetSequence()<5 then ft=ft+1 end
  if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
  end
end
end
