--Sakashima's Student
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
    --Gains ATK equal to the combined ATK of all Spell monsters this card points to
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Cannot be destroyed by battle while pointing to a Spell monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.indcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Tribute 1 monster this card points to, return 1 face-up card opponent controls to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.thcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
--Check Link Materials for Spell monster
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsType,1,nil,TYPE_SPELL,lc,sumtype,tp)
end
--Gains ATK equal to the combined ATK of all Spell monsters this card points to
function s.atkval(e,c)
    local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsType,1,TYPE_SPELL,nil)
    return g:GetSum(Card.GetAttack)
end
--Cannot be destroyed by battle while pointing to a Spell monster
function s.indcon(e)
    return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_SPELL))>0
end
--Tribute 1 monster this card points to, return 1 face-up card opponent controls to hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local lg=e:GetHandler():GetLinkedGroup()
    if chk==0 then return #lg>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=lg:Select(tp,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        --No activation or effects of returned card until end of turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetTargetRange(1,1)
        e1:SetValue(s.aclimit)
        e1:SetLabelObject(tc)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.aclimit(e,re,tp)
    local tc=e:GetLabelObject()
    return re:GetHandler():IsCode(tc:GetOriginalCode())
end