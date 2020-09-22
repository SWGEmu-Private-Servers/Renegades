#ifndef RETRIEVERESOURCESCOMMAND_H_
#define RETRIEVERESOURCESCOMMAND_H_

#include "server/zone/objects/scene/SceneObject.h"
#include "server/zone/packets/harvester/HarvesterObjectMessage7.h"

class RetrieveResourcesCommand : public QueueCommand
{
public:
	RetrieveResourcesCommand(const String& name, ZoneProcessServer* server) : QueueCommand(name, server) {}

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const
	{

		if (!creature->isPlayerCreature())
			return GENERALERROR;

		if (!checkStateMask(creature))
			return INVALIDSTATE;

		if (!checkInvalidLocomotions(creature))
			return INVALIDLOCOMOTION;

		CreatureObject* player = cast<CreatureObject*>(creature);

		ManagedReference<SceneObject*> object = server->getZoneServer()->getObject(target);

		if (object == nullptr || !object->isInstallationObject())
			return GENERALERROR;

		InstallationObject* inso = cast<InstallationObject*>(object.get());
		StructureObject* structure = cast<StructureObject*>(object.get());
		try
		{
			Locker clocker(object, player);
			int distance = 20;
			if (!inso->isOnAdminList(player))
			{
				StringIdChatParameter msg("player_structure", "renegades_noperm");
				msg.setTT(structure->getDisplayedName());
				player->sendSystemMessage(msg);
				return GENERALERROR;
			}
			if (!inso->isInRange(player, distance))
			{
				StringIdChatParameter msg("player_structure", "renegades_toofar");
				msg.setTT(structure->getDisplayedName());
				msg.setDI(distance);
				player->sendSystemMessage(msg);
				return GENERALERROR;
			}

			inso->updateInstallationWork();
			SceneObject* inventory = player->getSlottedObject("inventory");
			int resCount = inso->getResourceContainerCountFromHopper();

			if (resCount == 0)
			{
				StringIdChatParameter msg("player_structure", "renegades_empty");
				msg.setTT(structure->getDisplayedName());
				player->sendSystemMessage(msg);
				return SUCCESS;
			}
			
			ManagedReference<ResourceContainer*> container;
			int oldQuantity, retrievedTotal = 0;
			for (int i = 0; i < resCount; i++)
			{
				container = inso->getContainerFromHopperByIndex(i);
				if (container != nullptr)
				{
					oldQuantity = container->getQuantity();
					if (oldQuantity > 0)
					{
						if (!inventory->isContainerFullRecursive())
						{
							Reference<ResourceSpawn*> resSpawn = container->getSpawnObject();
							Locker locker(resSpawn);

							ManagedReference<ResourceContainer*> newContainer = resSpawn->createResource(oldQuantity);
							if (inventory->transferObject(newContainer, -1, false))
							{
								inventory->broadcastObject(newContainer, true);
								inso->updateResourceContainerQuantity(container, container->getQuantity() - oldQuantity, true);
								retrievedTotal += oldQuantity;
							}
							else
							{
								newContainer->destroyObjectFromDatabase(true);
							}
						}
						else
						{
							StringIdChatParameter stringId("error_message", "inv_full");
							player->sendSystemMessage(stringId);
						}
					}
				}
			}
			StringIdChatParameter msg("player_structure", "renegades_retrieve");
			msg.setDI(retrievedTotal);
			msg.setTT(structure->getDisplayedName());
			player->sendSystemMessage(msg);
			inso->broadcastToOperators(new HarvesterObjectMessage7(inso));
		}

		catch (Exception &e){}

		return SUCCESS;
	}
};

#endif //RETRIEVERESOURCESCOMMAND_H_
