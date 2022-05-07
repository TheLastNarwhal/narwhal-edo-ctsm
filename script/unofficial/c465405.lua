--Acolyte of Fen
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Special Summon from your hand if you control "Witchinity" or "Ritual Doll" monster
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --Discard self and 1 "Witchinity" card, draw 2
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DRAW)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1,{id,1})
  e2:SetCost(s.drcost)
  e2:SetTarget(s.drtg)
  e2:SetOperation(s.drop)
  c:RegisterEffect(e2)
  --If a "Witchinity" monster you control would be destroyed by battle or card effect, you can banish this card from your GY instead
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EFFECT_DESTROY_REPLACE)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCountLimit(1,{id,2})
  e3:SetTarget(s.reptg)
  e3:SetValue(s.repval)
  e3:SetOperation(s.repop)
  c:RegisterEffect(e3)
end
s.listed_series={0x197,0x2197}
s.listed_names={465387}
--Special Summon from your hand if you control "Witchinity" or "Ritual Doll" monster
function s.spcfilter(c)
  return c:IsFaceup() and (c:IsSetCard(0x197) or c:IsSetCard(0x2197))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--Discard self and 1 "Witchinity" card, draw 2
function s.cfilter(c)
  return c:IsSetCard(0x197) and c:IsDiscardable()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDiscardable() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
  local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
  g:AddCard(e:GetHandler())
  Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(2)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Draw(p,d,REASON_EFFECT)
end
--If a "Witchinity" monster you control would be destroyed by battle or card effect, you can banish this card from your GY instead
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x197) and not c:IsSetCard(0x2197)) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
  return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
  return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
