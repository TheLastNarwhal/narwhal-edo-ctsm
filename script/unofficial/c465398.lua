--Grimmdancer, the Faceless Horror
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x197),4,2,nil,nil,99)
  --Must first be Xyz Summoned
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e0:SetCode(EFFECT_SPSUMMON_CONDITION)
  e0:SetValue(s.splimit)
  c:RegisterEffect(e0)
  --Gains 1000 ATK/DEF for each material attached
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetValue(s.atkval)
  c:RegisterEffect(e1)
  e2=e1:Clone()
  e2:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e2)
  --Once per turn, target Attack Position monster, attach as material
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1,{id,1})
  e3:SetTarget(s.attchtg)
  e3:SetOperation(s.attchop)
  c:RegisterEffect(e3)
  --If attacks and monster wasn't destroyed, attach as material --sealed for balance
  --[[local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,2))
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_DAMAGE_STEP_END)
  e4:SetCondition(s.battlecon)
  e4:SetOperation(s.battleop)
  c:RegisterEffect(e4)
  --Cannot be destroyed by battle when it declares an attack --sealed for balance
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e5:SetCode(EVENT_ATTACK_ANNOUNCE)
  e5:SetTarget(s.indestg)
  e5:SetOperation(s.indesop)
  c:RegisterEffect(e5)]]
  --Target 1 other monster on the field, equip this card to it, gain control if don't control
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,3))
  e6:SetCategory(CATEGORY_EQUIP)
  e6:SetType(EFFECT_TYPE_QUICK_O)
  e6:SetCode(EVENT_FREE_CHAIN)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCountLimit(1,{id,2})
  e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
  e6:SetCondition(s.eqcon)
  e6:SetTarget(s.eqtg)
  e6:SetOperation(s.eqop)
  c:RegisterEffect(e6)
  --While equipped to monster that monster gains 1000 ATK/DEF
  local e7=Effect.CreateEffect(c)
  e7:SetType(EFFECT_TYPE_EQUIP)
  e7:SetCode(EFFECT_UPDATE_ATTACK)
  e7:SetValue(1000)
  c:RegisterEffect(e7)
  local e8=e7:Clone()
  e8:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e8)
  --Granted Effect - discard 1 card, equip opponent's monster to this card, gains ATK equal to equipped monsters' ATK
  --[[local e9=Effect.CreateEffect(c)
  e9:SetDescription(aux.Stringid(id,4))
  e9:SetType(EFFECT_TYPE_IGNITION)
  e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e9:SetRange(LOCATION_MZONE)
  e9:SetCountLimit(1)
  e9:SetCondition(s.noselfcon)
  e9:SetCost(s.equipcost)
  e9:SetTarget(s.equiptg)
  e9:SetOperation(s.equipop1)
  c:RegisterEffect(e9)
  aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop2,e9)
  -- Equipped monster gains effect
  local e10=Effect.CreateEffect(c)
  e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
  e10:SetRange(LOCATION_SZONE)
  e10:SetTargetRange(LOCATION_MZONE,0)
  e10:SetTarget(function(e,c) return c==e:GetHandler():GetEquipTarget() end)
  e10:SetLabelObject(e9)
  c:RegisterEffect(e10)
  --Granted Effect - Special Summon 1 "Witch" monster from hand or GY, or Special Summon 1 face-up "Grimmdancer, the Faceless Horror" from S/T zone
  local e11=Effect.CreateEffect(c)
  e11:SetDescription(aux.Stringid(id,5))
  e11:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e11:SetType(EFFECT_TYPE_QUICK_O)
  e11:SetCode(EVENT_FREE_CHAIN)
  e11:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
  e11:SetRange(LOCATION_MZONE)
  e11:SetCountLimit(1)
  --e11:SetCost(s.announcecost)
  e11:SetCondition(s.noselfcon)
  e11:SetTarget(s.sptg)
  e11:SetOperation(s.spop)
  c:RegisterEffect(e11)
  -- Equipped monster gains effect
  local e12=Effect.CreateEffect(c)
  e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
  e12:SetRange(LOCATION_SZONE)
  e12:SetTargetRange(LOCATION_MZONE,0)
  e12:SetTarget(function(e,c) return c==e:GetHandler():GetEquipTarget() end)
  e12:SetLabelObject(e11)
  c:RegisterEffect(e12)]]
end
s.listed_names={465389}
--Must first be Xyz Summoned
function s.splimit(e,se,sp,st)
  return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se)
end
--Gains 1000 ATK/DEF for each material attached
function s.atkval(e,c)
  return c:GetOverlayCount()*1000
end
--Once per turn, target Attack Position monster, attach as material
function s.attchfilter(c,tp)
  return c:IsPosition(POS_FACEUP_ATTACK) and not c:IsType(TYPE_TOKEN)
  and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.attchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) and chkc~=e:GetHandler() end
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.attchfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.attchfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
end
function s.attchop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
    Duel.Overlay(c,tc,true)
    Duel.BreakEffect()
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
      local sg=g:Select(tp,1,1,nil)
      Duel.HintSelection(sg)
      Duel.Destroy(sg,REASON_EFFECT)
    end
  end
end
--If attacks and monster wasn't destroyed, attach as material
--[[function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  e:SetLabelObject(bc)
  return c==Duel.GetAttacker() and bc and c:IsStatus(STATUS_OPPO_BATTLE) and bc:IsOnField() and bc:IsRelateToBattle()
end
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and not bc:IsImmuneToEffect(e) and c:IsLocation(LOCATION_MZONE) then
    Duel.Overlay(c,bc,true)
  end
end
--Cannot be destroyed by battle when it declares an attack
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
  local d=Duel.GetAttackTarget()
  if chk==0 then return d and d:IsControler(1-tp) end
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsFaceup() and c:IsRelateToEffect(e) then
    --When declares an attack cannot be destroyed by that battle
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
  end
end]]
--Target 1 other monster on the field, equip this card to it, gain control if don't control
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsMainPhase()
end
function s.eqfilter(c,tp,ft,mmz)
  return c:IsFaceup() and (ft>0 or c:IsControler(tp) or mmz)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  local mmz=c:GetSequence()<5
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and not chkc==c end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,ft,mmz) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp,ft,mmz)
  Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not (c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) then return end
  local tc=Duel.GetFirstTarget()
  if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
    Duel.SendtoGrave(c,REASON_EFFECT)
    return
  end
  Duel.Equip(tp,c,tc,true)
  --Equip to monster
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_EQUIP_LIMIT)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  e1:SetValue(s.eqlimit1)
  e1:SetLabelObject(tc)
  c:RegisterEffect(e1)
  if tc:IsControler(1-tp) then
    --Take control of equipped monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_SET_CONTROL)
    e2:SetValue(s.ctval)
    c:RegisterEffect(e2)
  end
end
function s.eqlimit1(e,c)
  return c==e:GetLabelObject()
end
function s.ctval(e,c)
  return e:GetHandlerPlayer()
end
--Makes sure only equipped monster has e9 & e11 effect and not self
--[[function s.noselfcon(e,tp,eg,ep,ev,re,r,rp)
  return not e:GetHandler():IsCode(465398)
end
--Granted Effect - discard 1 card, equip opponent's monster to this card, gains ATK equal to equipped monsters' ATK
function s.equipcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
  Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.equipfilter(c)
  return c:IsFaceup() and c:IsAbleToChangeControler()
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.equipfilter(chkc) end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.equipfilter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  local g=Duel.SelectTarget(tp,s.equipfilter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop1(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		s.equipop2(c,e,tp,tc)
	end
end
function s.equipop2(c,e,tp,tc)
  local atk=tc:GetTextAttack()
  if tc:IsFacedown() or atk<0 then atk=0 end
  if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return end
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_EQUIP)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
  e1:SetValue(atk)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  tc:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_EQUIP_LIMIT)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e2:SetValue(true)
  e2:SetReset(RESET_EVENT+RESETS_STANDARD)
  tc:RegisterEffect(e2)
end
--Granted Effect - Special Summon 1 "Witch" monster from hand or GY, or Special Summon 1 face-up "Grimmdancer, the Faceless Horror" from S/T zone
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.spfilter(c,e,tp)
  return (c:IsSetCard(0x197) and c:IsType(TYPE_MONSTER)) or (c:IsCode(465398) and c:IsFaceup() and c:IsLocation(LOCATION_SZONE)) and c:IsOriginalType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+-LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end]]
