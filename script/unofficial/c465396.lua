--Witch's Oven
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activation
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  e0:SetHintTiming(0,TIMING_END_PHASE)
  c:RegisterEffect(e0)
  --Tribute 1 monster from your hand or field, each player draws 1 card, then gains 1000 LP, also neither player takes damage until the end of your opponent's next turn
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCost(s.tribcost)
  e1:SetTarget(s.tribtg)
  e1:SetOperation(s.tribop)
  c:RegisterEffect(e1)
end
s.listed_series={0x197}
--Tribute 1 monster from your hand or field, each player draws 1 card, then gains 1000 LP, also neither player takes damage until the end of your opponent's next turn
function s.tribfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
function s.tribcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tribfilter,1,true,nil,nil,tp) end
  local sg=Duel.SelectReleaseGroupCost(tp,s.tribfilter,1,1,true,nil,nil,tp)
  Duel.Release(sg,REASON_COST)
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
  local d1=Duel.Draw(tp,1,REASON_EFFECT)
  local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
  local lp1=Duel.Recover(tp,1000,REASON_EFFECT)
  local lp2=Duel.Recover(1-tp,1000,REASON_EFFECT)
  if (d1==0 or d2==0) or (lp1==0 or lp2==0) then return end
  --No damage until end of the next turn
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CHANGE_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,1)
  e1:SetValue(0)
  e1:SetReset(RESET_PHASE+PHASE_END,2)
  Duel.RegisterEffect(e1,tp)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
  e2:SetReset(RESET_PHASE+PHASE_END,2)
  Duel.RegisterEffect(e2,tp)
  local e3=Effect.CreateEffect(e:GetHandler())
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetReset(RESET_PHASE+PHASE_END,2)
  e3:SetTargetRange(1,1)
  Duel.RegisterEffect(e3,tp)
  --Your "Witch" monsters cannot be destroyed by battle
  local e4=Effect.CreateEffect(e:GetHandler())
  e4:SetDescription(aux.Stringid(id,2))
  e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e4:SetTargetRange(LOCATION_MZONE,0)
  e4:SetReset(RESET_PHASE+PHASE_END)
  e4:SetTarget(s.witchfilter)
  e4:SetValue(1)
  Duel.RegisterEffect(e4,tp)
end
function s.witchfilter(e,c)
  return c:IsSetCard(0x197)
end
