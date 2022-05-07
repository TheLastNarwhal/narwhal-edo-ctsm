--Trickster of the Witchinity
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Synchro Summon
  c:EnableReviveLimit()
  Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
  --Target 1 monster on the field, banish it until the start of the next phase
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_REMOVE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,{id,1})
  e1:SetRange(LOCATION_MZONE)
  e1:SetCondition(s.actcon)
  e1:SetTarget(s.rmtg)
  e1:SetOperation(s.rmop)
  c:RegisterEffect(e1)
  --Flag Operation so return works properly in M1
  aux.GlobalCheck(s,function()
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_REMOVE)
    ge1:SetOperation(s.checkbanisheffect)
    Duel.RegisterEffect(ge1,0)
  end)
  --Conditional damage based on flag so return works properly in M1
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e2:SetRange(LOCATION_REMOVED|LOCATION_MZONE)
  e2:SetCode(EVENT_ADJUST)
  e2:SetCondition(s.banishflagcheck)
  e2:SetLabelObject(e1)
  e2:SetOperation(s.returnop)
  c:RegisterEffect(e2)
  --If this face-up card in owner's control is sent to the GY by opponent or banished by opponent, Special Summon in face-down Defense Position
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetCountLimit(1,{id,2})
  e3:SetCondition(s.spcon)
  e3:SetTarget(s.sptg)
  e3:SetOperation(s.spop)
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EVENT_REMOVE)
  c:RegisterEffect(e4)
end
s.listed_series={0x197}
--Can treat a "Witchinity" monster as a Tuner
function s.matfilter(c,scard,sumtype,tp)
return c:IsSetCard(0x197,scard,sumtype,tp)
end
--Flag operation for banish so the return works properly in the M1
function s.checkbanisheffect(e,tp,eg,ep,ev,re,r,rp)
  --Debug.Message("[current banishflag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  local rc=re:GetHandler()
  if rc and ((r&REASON_EFFECT)~=0) then
    Duel.RegisterFlagEffect(0,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
    --Debug.Message("[set banishflag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  end
end
--Conditional flag based on own banish so return works properly in M1
function s.banishflagcheck(e,tp,eg,ep,ev,re,r,rp)
  local cur=Duel.GetCurrentPhase()
  --Debug.Message("[current phase ] is "..tostring(cur))
  --- Draw Phase Special Summon ---
  if e:GetLabel()==cur then
    return Duel.GetFlagEffect(tp,id)>0
  end
  --- Draw Phase Activation ---
  if cur==PHASE_DRAW then
    e:SetLabel(2)
  end
  --- Standby Phase Special Summon ---
  if e:GetLabel()==cur then
    return Duel.GetFlagEffect(tp,id)>0
  end
  --- Stanby Phase Activation ---
  if cur==PHASE_STANDBY then
    e:SetLabel(4)
  end
  --- Main Phase 1 Special Summon ---
  if e:GetLabel()==cur then
    return Duel.GetFlagEffect(tp,id)>0
  end
  --- Main Phase 1 Activation ---
  if cur==PHASE_MAIN1 then
    e:SetLabel(8)
  end
  --- Battle Phase Special Summon ---
  if e:GetLabel()==cur then
    return Duel.GetFlagEffect(tp,id)>0
  end
  --- Main Phase 2 Activation ---
  if cur==PHASE_MAIN2 then
    e:SetLabel(512)
  end
  --- End Phase Activation ---
  if cur==PHASE_END then
    e:SetLabel(1)
  end
  --- End Phase Special Summon --
  if e:GetLabel()==cur then
    return Duel.GetFlagEffect(tp,id)>0
  end
  --Debug.Message("[set phase ] is "..tostring(e:GetLabel()))
end
--Actual damage operation
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
  --Debug.Message("[recieved label object] is "..tostring(e:GetLabelObject()))
  local tc=e:GetLabelObject():GetLabelObject()
    Duel.ReturnToField(tc)
    --Debug.Message("[pre-return label] is "..tostring(e:GetLabel()))
    --Debug.Message("[pre-return banishflag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
    --Debug.Message("[pre-return label object] is "..tostring(e:GetLabelObject()))
    e:SetLabel(0)
    Duel.ResetFlagEffect(tp,id)
    --Debug.Message("[post return set label] is "..tostring(e:GetLabel()))
    --Debug.Message("[post return banishflag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
    --Debug.Message("[post return label object] is "..tostring(e:GetLabelObject()))
  --end
end
--Target 1 monster on the field, banish it until the start of the next phase
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
  return not (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:IsAbleToRemove() end
  if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
    --Debug.Message("[pre-set label object] is "..tostring(e:GetLabelObject()))
    tc:CreateRelation(e:GetHandler(),RESET_EVENT+RESETS_STANDARD)
    e:SetLabelObject(tc)
    --Debug.Message("[set label object] is "..tostring(e:GetLabelObject()))
  end
end
--If this face-up card in owner's control is sent to the GY by opponent or banished by opponent, Special Summon in face-down Defense Position
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
    Duel.ConfirmCards(1-tp,c)
  end
end
