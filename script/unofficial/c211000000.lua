--Sakashima's Masquerade
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --List of counters to better enable copy effects
  for _,counter in ipairs({0x1,0x3,0x8,0xa,0xf,0x10,0x11,0x14,0x16,0x17,0x1f,0x22,0x23,0x26,0x27,0x28,0x29,0x2c,0x2e,0x2b,0x34,0x36,0x40,0x42,0x43,0x44,0x4a,0x147,0x14a,0x202,0x203,0x59,0x20a}) do
    c:EnableCounterPermit(counter,LOCATION_MZONE)
end
  --Copy opponent's monster
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  e1:SetCountLimit(1,id)
  c:RegisterEffect(e1)
end
s.listed_series={0x1990}
--Copy opponent's monster
function s.filter(c,e,tp)
  return c:IsFaceup() and c:GetLevel()>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1990,0x21,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
  local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  local tc=Duel.GetFirstTarget()
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) or not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
  if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1990,0x21,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
  c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL)
  if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
    c:AddMonsterAttributeComplete()
    local code=tc:GetCode()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(tc:GetDefense())
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_SET_BASE_ATTACK)
    e3:SetValue(tc:GetAttack())
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EFFECT_CHANGE_RACE)
    e4:SetValue(tc:GetRace())
    c:RegisterEffect(e4)
    local e5=e1:Clone()
    e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e5:SetValue(tc:GetAttribute())
    c:RegisterEffect(e5)
    local e6=e1:Clone()
    e6:SetCode(EFFECT_CHANGE_LEVEL)
    e6:SetValue(tc:GetLevel())
    c:RegisterEffect(e6)
    c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
    c:SetCardTarget(tc)
  end
  Duel.SpecialSummonComplete()
end