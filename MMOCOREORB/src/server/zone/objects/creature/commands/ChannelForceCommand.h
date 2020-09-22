/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

#ifndef CHANNELFORCECOMMAND_H_
#define CHANNELFORCECOMMAND_H_

#include "server/zone/objects/creature/buffs/ChannelForceBuff.h"
#include "templates/params/creature/CreatureAttribute.h"

class ChannelForceCommand : public QueueCommand {
public:

	ChannelForceCommand(const String& name, ZoneProcessServer* server)
: QueueCommand(name, server) {

	}

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const {

		if (!checkStateMask(creature))
			return INVALIDSTATE;

		if (!checkInvalidLocomotions(creature))
			return INVALIDLOCOMOTION;

		if (creature->hasAttackDelay())
			return GENERALERROR;

		if (isWearingArmor(creature)) {
			return NOJEDIARMOR;
		}

		int forceBonus = 300;

		ManagedReference<PlayerObject*> playerObject = creature->getPlayerObject();
		if (playerObject == nullptr)
			return GENERALERROR;

		// Do not execute if the player's force bar is full.
		if (playerObject->getForcePower() >= playerObject->getForcePowerMax())
			return GENERALERROR;

		// To keep it from going over max...
		if ((playerObject->getForcePowerMax() - playerObject->getForcePower()) < forceBonus)
			forceBonus = (playerObject->getForcePowerMax() - playerObject->getForcePower());

		int health = creature->getHAM(CreatureAttribute::HEALTH);
		int action = creature->getHAM(CreatureAttribute::ACTION);
		int mind = creature->getHAM(CreatureAttribute::MIND);

		if ((health <= forceBonus) || (action <= forceBonus) || (mind <= forceBonus)) {
			creature->sendSystemMessage("@jedi_spam:channel_ham_too_low"); // Your body is too weakened to perform that action.
			return GENERALERROR;
		}

		int maxHealth = creature->getMaxHAM(CreatureAttribute::HEALTH);
		int maxAction = creature->getMaxHAM(CreatureAttribute::ACTION);
		int maxMind = creature->getMaxHAM(CreatureAttribute::MIND);

		if ((maxHealth - creature->getWounds(CreatureAttribute::HEALTH) <= forceBonus) || (maxAction - creature->getWounds(CreatureAttribute::ACTION) <= forceBonus) || (maxMind - creature->getWounds(CreatureAttribute::MIND) <= forceBonus)) {
			creature->sendSystemMessage("@jedi_spam:channel_ham_too_low"); // Your body is too weakened to perform that action.
			return GENERALERROR;
		}

		if (!creature->checkCooldownRecovery("channelforce")) {
			creature->sendSystemMessage("You need to recover for a moment, before channeling again.");
			return false;
		}

		creature->updateCooldownTimer("channelforce", 3000);

		// Give Force, and subtract HAM.
		playerObject->setForcePower(playerObject->getForcePower() + forceBonus);

		// Setup buffs.
		uint32 buffCRC = STRING_HASHCODE("channelforcebuff");
		Reference<Buff*> buff = creature->getBuff(buffCRC);
		int duration = ChannelForceBuff::FORCE_CHANNEL_DURATION_SECONDS;
		if (buff == nullptr) {
			buff = new ChannelForceBuff(creature, buffCRC, duration);

			Locker locker(buff);

			buff->setAttributeModifier(CreatureAttribute::HEALTH, -(forceBonus / 3));
			buff->setAttributeModifier(CreatureAttribute::ACTION, -(forceBonus / 3));
			buff->setAttributeModifier(CreatureAttribute::MIND, -(forceBonus / 3));

			creature->addBuff(buff);
		} else {
			Locker locker(buff, creature);

			buff->setAttributeModifier(CreatureAttribute::HEALTH,
									   buff->getAttributeModifierValue(CreatureAttribute::HEALTH)-(forceBonus / 3));
			buff->setAttributeModifier(CreatureAttribute::ACTION,
									   buff->getAttributeModifierValue(CreatureAttribute::ACTION)-(forceBonus / 3));
			buff->setAttributeModifier(CreatureAttribute::MIND,
									   buff->getAttributeModifierValue(CreatureAttribute::MIND)-(forceBonus / 3));

			creature->addMaxHAM(CreatureAttribute::HEALTH, -(forceBonus / 3));
			creature->addMaxHAM(CreatureAttribute::ACTION, -(forceBonus / 3));
			creature->addMaxHAM(CreatureAttribute::MIND, -(forceBonus / 3));

			creature->renewBuff(buffCRC, duration);
			Reference<ChannelForceBuff*> channelBuff = buff.castTo<ChannelForceBuff*>();
			if (channelBuff != nullptr)
				channelBuff->activateRegenTick();
		}

		return SUCCESS;
	}

	float getCommandDuration(CreatureObject* object, const UnicodeString& arguments) const {
		return 1.0;
	}

};

#endif //CHANNELFORCECOMMAND_H_
