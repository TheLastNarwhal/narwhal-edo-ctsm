--Fry Cook's Revenge
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Ritual Summon and if 3 or more mats gains effect
  e1=Ritual.CreateProc({
    handler=c,
    lvtype=RITPROC_EQUAL,
    filter=aux.FilterBoolFunction(Card.IsSetCard,0x195),
    location=LOCATION_HAND|LOCATION_DECK,
    stage2=s.stage2
  })
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  c:RegisterEffect(e1)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
  if tc:GetMaterialCount()>2 then
    --Cannot be destryed by battle with a monster of equal or greater Level
    local e1=Effect.CreateEffect(tc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(s.indval)
    tc:RegisterEffect(e1,true)
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
    --When your opponent activates a card or effect, place 1 Grease Counter on 1 card your opponent controls
    local e2=Effect.CreateEffect(tc)
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(_,tp,_,ep)return ep==1-tp end)
    e2:SetTarget(s.addctg)
    e2:SetOperation(s.addcop)
    tc:RegisterEffect(e2,true)
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
    --If you opponent activates card/effect w/ Grease Counter, change effect to return to hand
    local e3=Effect.CreateEffect(tc)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.chcon1)
    e3:SetOperation(s.chop1)
    tc:RegisterEffect(e3,true)
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
    local e4=Effect.CreateEffect(tc)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_ACTIVATING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.chcon2)
    e4:SetOperation(s.chop2)
    tc:RegisterEffect(e4,true)
    if not tc:IsType(TYPE_EFFECT) then
      --Becomes an Effect Monster if it wasn't already one
      local e5=Effect.CreateEffect(e:GetHandler())
      e5:SetType(EFFECT_TYPE_SINGLE)
      e5:SetCode(EFFECT_ADD_TYPE)
      e5:SetValue(TYPE_EFFECT)
      e5:SetReset(RESET_EVENT+RESETS_STANDARD)
      tc:RegisterEffect(e5,true)
    end
  end
end
--Cannot be destryed by battle with a monster of equal or greater Level
function s.indval(e,c)
  return c:IsLevelAbove(e:GetHandler():GetLevel())
end
--When your opponent activates a card or effect, place 1 Grease Counter on 1 card your opponent controls
function s.addctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.addcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1042,1)
	end
end
--If you opponent activates card/effect w/ Grease Counter, change effect to return to hand
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP) or re:IsActiveType(TYPE_MONSTER)) and re:GetHandler():GetCounter(0x1042)>0
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return ev==1 and e:GetHandler():GetFlagEffect(id+1)>0
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.ChangeChainOperation(1,s.rep_op)
end
function s.rep_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
