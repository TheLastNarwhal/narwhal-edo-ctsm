--Sansirenity Charybdis
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Fusion material
  c:EnableReviveLimit()
  Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x196),2)
  --Opponent's monsters must attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0,LOCATION_MZONE)
  e1:SetCode(EFFECT_MUST_ATTACK)
  c:RegisterEffect(e1)
  --Cannot be destroyed by battle/effect
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  c:RegisterEffect(e3)
  --If battled, send top 5 cards of opponent's deck to GY, deal dam equal to sent monster
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCode(EVENT_BATTLED)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(s.damcon)
  e4:SetTarget(s.damtg)
  e4:SetOperation(s.damop)
  c:RegisterEffect(e4)
end
s.listed_series={0x196}
--If battled, send top 5 cards of opponent's deck to GY, deal dam equal to sent monster
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetBattledGroupCount()>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)
end
function s.cfilter(c)
  return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardDeck(1-tp,5,REASON_EFFECT)~=0 then
    local g=Duel.GetOperatedGroup()
    local ct=g:Filter(s.cfilter,nil,tp)
    if #ct>0 then
      Duel.BreakEffect()
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
      local sc=ct:Select(tp,1,1,nil):GetFirst()
      Duel.Damage(1-tp,sc:GetAttack(),REASON_EFFECT)
    end
  end
end
