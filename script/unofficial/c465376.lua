--Sirenity Raidne
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Opponent's monsters must attack
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0,LOCATION_MZONE)
  e1:SetCode(EFFECT_MUST_ATTACK)
  e1:SetCondition(s.con)
  c:RegisterEffect(e1)
  --Battle protection
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e2:SetCountLimit(1)
  e2:SetValue(s.valcon)
  c:RegisterEffect(e2)
  --If attacked return 1 card from opponent's hand to top or bottom of deck
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TODECK)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_BATTLED)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCondition(s.tdcon)
  e3:SetTarget(s.tdtg)
  e3:SetOperation(s.tdop)
  c:RegisterEffect(e3)
end
--Opponent's monsters must attack
function s.con(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
--Battle protection
function s.valcon(e,re,r,rp)
  return (r&REASON_BATTLE)~=0
end
--If attacked return 1 card from opponent's hand to top or bottom of deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttackTarget()==e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
  Duel.SetTargetPlayer(tp)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
  if #g>0 then
    Duel.ConfirmCards(p,g)
    local sg=g:FilterSelect(p,Card.IsAbleToDeck,1,1,nil)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
      Duel.ShuffleHand(1-p)
    else
      Duel.SendtoDeck(sg,nil,1,REASON_EFFECT)
      Duel.ShuffleHand(1-p)
    end
  end
end
