--Idunn the False-Hearted Eternal
--Scripted by Narwhal
Duel.LoadScript("cstm_card_specific_functions.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If leaves the field, target 1 "Eternal" monster you control, double its ATK/DEF, lower all non-"Eternal" monsters ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetTarget(s.changetg)
    e2:SetOperation(s.changeop)
    c:RegisterEffect(e2)
    --Special Summon self and token
    c:RegisterEffect(Effect.CreateEternalSPEffect(c,id,0,CATEGORY_TOKEN,s.sptg,s.spop))
end
s.listed_names={TOKEN_ETERNAL_SHARD}
s.listed_series={0x200}
--Special Summon self and token
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ETERNAL_SHARD,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,2,RACE_FAIRY,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ETERNAL_SHARD,0x200,TYPES_TOKEN+TYPE_TUNER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.BreakEffect()
        local token=Duel.CreateToken(tp,TOKEN_ETERNAL_SHARD)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        --Cannot Special Summon non-Synchro non-Fairy monsters from Extra Deck
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetAbsoluteRange(tp,1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)) end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1,true)
        --Lizard check
        local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not (c:IsOriginalType(TYPE_SYNCHRO) and c:IsOriginalRace(RACE_FAIRY)) end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e2,true)
        Duel.SpecialSummonComplete()
    end
end
--If leaves the field, target 1 "Eternal" monster you control, double its ATK/DEF, lower all non-"Eternal" monsters ATK
function s.changetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(0x200) end
    if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsSetCard,0x200),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
    Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x200),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        --Double ATK
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(tc:GetAttack()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        --Double DEF
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(tc:GetDefense()*2)
        tc:RegisterEffect(e2)
        --Reduce ATK of non-"Eternal" monsters
        local atk=tc:GetBaseAttack()+tc:GetBaseDefense()
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetRange(LOCATION_MZONE)
        e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e3:SetTarget(function(_,c) return not c:IsSetCard(0x200) end)
        e3:SetValue(-atk)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e3)
    end
end