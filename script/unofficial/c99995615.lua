--Flicker
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--select card
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
--return banished card
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
            Duel.BreakEffect()
						for tc in aux.Next(g) do
							if not tc:IsImmuneToEffect(e) then
								tc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
								local e1=Effect.CreateEffect(e:GetHandler())
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetCode(EFFECT_SET_CONTROL)
								e1:SetValue(tc:GetOwner())
								e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
								tc:RegisterEffect(e1)
							end
            Duel.ReturnToField(tc)
        end
    end
	end
end
