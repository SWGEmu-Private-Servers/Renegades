JediManager = require("managers.jedi.jedi_manager")
local ObjectManager = require("managers.object.object_manager")
local QuestManager = require("managers.quest.quest_manager")
require("utils.helpers")

jediManagerName = "CustomJediManager"

CustomJediManager = JediManager:new {
	screenplayName = jediManagerName,
	jediManagerName = jediManagerName,
	jediProgressionType = CUSTOMJEDIPROGRESSION,
	startingEvent = nil,
}

function CustomJediManager:onPlayerLoggedIn(pPlayer)
	if (pPlayer == nil) then
		return
	end

	if (VillageJediManagerCommon.isVillageEligible(pPlayer) and not CreatureObject(pPlayer):hasSkill("force_title_jedi_novice")) then
		awardSkill(pPlayer, "force_title_jedi_novice")
	end

	if (FsOutro:isOnOutro(pPlayer)) then
		FsOutro:onLoggedIn(pPlayer)
	end

	JediTrials:onPlayerLoggedIn(pPlayer)
end

function CustomJediManager:onPlayerLoggedOut(pPlayer)
	if (pPlayer == nil) then
		return
	end

	if (FsOutro:isOnOutro(pPlayer)) then
		FsOutro:onLoggedOut(pPlayer)
	end
end

function CustomJediManager:canLearnSkill(pCreatureObject, skillName)
	if (tonumber(readScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed")) == 6) then
		return true
	end

	return false
end

function CustomJediManager:canSurrenderSkill(pPlayer, skillName)
	if skillName == "force_title_jedi_novice" and CreatureObject(pPlayer):getForceSensitiveSkillCount(true) > 0 then
		return false
	end

	if string.find(skillName, "force_sensitive_") and CreatureObject(pPlayer):hasSkill("force_title_jedi_rank_02") and CreatureObject(pPlayer):getForceSensitiveSkillCount(false) <= 24 then
		return false
	end

	if string.find(skillName, "force_discipline_") and CreatureObject(pPlayer):hasSkill("force_title_jedi_rank_03") and not CreatureObject(pPlayer):villageKnightPrereqsMet(skillName) then
		return false
	end

	return true
end

function CustomJediManager:checkForceStatusCommand(pCreatureObject)
	if (pCreatureObject == nil) then
		return
	end

	local suiManager = LuaSuiManager()
	local holosUsed = tonumber(readScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed"))

	if (holosUsed == nil) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You don't have any knowledge of the force. Perhaps you should seek out information, where ever you can find it...", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 0) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You don't have any knowledge of the force. Perhaps you should seek out information, where ever you can find it...", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 1) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 2) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.\n\nThere is no ignorance, there is knowledge.", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 3) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.\n\nThere is no ignorance, there is knowledge.\n\nThere is no passion, there is serenity.", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 4) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.\n\nThere is no ignorance, there is knowledge.\n\nThere is no passion, there is serenity.\n\nThere is no chaos, there is harmony.", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 5) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.\n\nThere is no ignorance, there is knowledge.\n\nThere is no passion, there is serenity.\n\nThere is no chaos, there is harmony.\n\nThere is no death, there is the Force.", "@ok", "CustomJediManager", "notifyOkPressed")
	elseif (holosUsed == 6) then
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Force Check", "You have learned:\n\nThere is no emotion, there is peace.\n\nThere is no ignorance, there is knowledge.\n\nThere is no passion, there is serenity.\n\nThere is no chaos, there is harmony.\n\nThere is no death, there is the Force.\n\nYou are now ready to begin your training.", "@ok", "CustomJediManager", "notifyOkPressed")
	end
end

function CustomJediManager:notifyOkPressed()
	-- Do nothing
end

function CustomJediManager:useItem(pSceneObject, itemType, pCreatureObject)
  if (pCreatureObject == nil or pSceneObject == nil) then
		return
	end

	if itemType == ITEMHOLOCRON then
		local suiManager = LuaSuiManager()
		local holosUsed = tonumber(readScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed"))

	if (holosUsed == nil) then -- Starting
		writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 1)
		CreatureObject(pCreatureObject):sendSystemMessage("There is no emotion, there is peace.")
		suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no emotion, there is peace.", "@ok", "CustomJediManager", "notifyOkPressed")

		SceneObject(pSceneObject):destroyObjectFromWorld()
		SceneObject(pSceneObject):destroyObjectFromDatabase()
	elseif (holosUsed == 0) then -- Starting after reset
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 1)
			CreatureObject(pCreatureObject):sendSystemMessage("There is no emotion, there is peace.")
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no emotion, there is peace.", "@ok", "CustomJediManager", "notifyOkPressed")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		elseif (holosUsed == 5) then
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 6)
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "Suddenly, you feel a strong presence, on Dathomir. Perhaps you should check it out.", "@ok", "CustomJediManager", "notifyOkPressed")
			CreatureObject(pCreatureObject):sendSystemMessage("Suddenly, you feel a strong presence, on Dathomir. Perhaps you should check it out.")
			VillageJediManagerCommon.setJediProgressionScreenPlayState(pCreatureObject, VILLAGE_JEDI_PROGRESSION_HAS_VILLAGE_ACCESS)
			CreatureObject(pCreatureObject):sendSystemMessage("@quest/force_sensitive/intro:force_sensitive")
			QuestManager.completeQuest(pCreatureObject, QuestManager.quests.FS_VILLAGE_ELDER)

			local pGhost = CreatureObject(pCreatureObject):getPlayerObject()
			PlayerObject(pGhost):setJediState(1)
			PlayerObject(pGhost):addWaypoint("dathomir", "Force Sensitive Village", "", 5306, -4145, WAYPOINTWHITE, true, true, 0)

			local skillManager = LuaSkillManager()
			skillManager:awardSkill(pCreatureObject, "force_title_jedi_novice")

			-- Unlock all branches
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_combat_prowess_ranged_accuracy")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_combat_prowess_ranged_speed")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_combat_prowess_melee_accuracy")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_combat_prowess_melee_speed")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_enhanced_reflexes_ranged_defense")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_enhanced_reflexes_melee_defense")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_enhanced_reflexes_vehicle_control")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_enhanced_reflexes_survival")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_crafting_mastery_experimentation")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_crafting_mastery_assembly")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_crafting_mastery_repair")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_crafting_mastery_technique")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_heightened_senses_healing")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_heightened_senses_surveying")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_heightened_senses_persuasion")
			VillageJediManagerCommon.unlockBranch(pCreatureObject, "force_sensitive_heightened_senses_luck")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		elseif (holosUsed == 4) then
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 5)
			CreatureObject(pCreatureObject):sendSystemMessage("There is no death, there is the Force.")
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no death, there is the Force.", "@ok", "CustomJediManager", "notifyOkPressed")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		elseif (holosUsed == 3) then
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 4)
			CreatureObject(pCreatureObject):sendSystemMessage("There is no chaos, there is harmony.")
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no chaos, there is harmony.", "@ok", "CustomJediManager", "notifyOkPressed")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		elseif (holosUsed == 2) then
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 3)
			CreatureObject(pCreatureObject):sendSystemMessage("There is no passion, there is serenity.")
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no passion, there is serenity.", "@ok", "CustomJediManager", "notifyOkPressed")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		elseif (holosUsed == 1) then
			writeScreenPlayData(pCreatureObject, "FSUnlockQuest", "holosUsed", 2)
			CreatureObject(pCreatureObject):sendSystemMessage("There is no ignorance, there is knowledge.")
			suiManager:sendMessageBox(pCreatureObject, pCreatureObject, "Ancient Knowledge", "There is no ignorance, there is knowledge.", "@ok", "CustomJediManager", "notifyOkPressed")

			SceneObject(pSceneObject):destroyObjectFromWorld()
			SceneObject(pSceneObject):destroyObjectFromDatabase()
		else
			CreatureObject(pCreatureObject):sendSystemMessage("@jedi_spam:holocron_no_effect")
		end
	end
end

function CustomJediManager:onFSTreeCompleted(pPlayer, branch)
	if (pPlayer == nil) then
		return
	end

	if (QuestManager.hasCompletedQuest(pPlayer, QuestManager.quests.OLD_MAN_FINAL) or VillageJediManagerCommon.hasJediProgressionScreenPlayState(pPlayer, VILLAGE_JEDI_PROGRESSION_COMPLETED_VILLAGE) or VillageJediManagerCommon.hasJediProgressionScreenPlayState(pPlayer, VILLAGE_JEDI_PROGRESSION_DEFEATED_MELLIACHAE)) then
		return
	end

	if (VillageJediManagerCommon.getLearnedForceSensitiveBranches(pPlayer) >= 6) then
		VillageJediManagerCommon.setJediProgressionScreenPlayState(pPlayer, VILLAGE_JEDI_PROGRESSION_COMPLETED_VILLAGE)
		FsOutro:startOldMan(pPlayer)
	end
end

return CustomJediManager
