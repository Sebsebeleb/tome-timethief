--
-- Created by IntelliJ IDEA.
-- User: Sebsebeleb
-- Date: 02/02/14
-- Time: 03:12
-- To change this template use File | Settings | File Templates.
--

newBirthDescriptor{
   type = "subclass",
   name = "Time Thief",
   desc = {
      "Blah",
      "#LIGHT_BLUE# * +4 Strength, +0 Dexterity, +1 Constitution",
      "#LIGHT_BLUE# * +0 Magic, +4 Willpower, +0 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +1",
   },
   power_source = { arcane = true, technique = true },
   random_rarity = 3,
   not_on_random_boss = ("no" == config.settings.tome.nullpack_npc_classes),
   stats = { dex=2, con=1, mag=4 },
   talents_types = {

      ["chronomancy/spacetime-weaving"]={true, 0.3},
      ["chronomancy/chronomancy"]={true, 0.1},
      ["chronomancy/past"]={true, 0.3},
      ["chronomancy/timephase"]={true, 0.3},
      ["chronomancy/hurtoclock"]={true, 0.3},
	  ["chronomancy/alive_today"]={true, 0.3},
	  ["chronomancy/ten_past_death"]={true, 0.3},

   },
   birth_example_particles = "temporal_focus",
   talents = {

      [ActorTalents.T_WEAPON_COMBAT] = 1,
      [ActorTalents.T_BACK_TO_THE_PAST] = 1,
      [ActorTalents.T_SHARED_MIND] = 1,
   },
   copy = {

	   resolvers.equip{ id=true,
		   {type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
		   {type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
		   {type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
	   },

      resolvers.generic(function(self) self:birth_create_alchemist_golem() end),
      innate_alchemy_golem = true,
      birth_create_alchemist_golem = function(self)
         -- We use a semi-nasty way of using the way golems are created for alchemist to create our ally.
         if not self.tthief_ally then
            local t = self:getTalentFromId(self.T_TWO_OF_ONE)
            t.invoke_ally(self, t)
         end
      end,

   },
   copy_add = {
      life_rating = 1,
   },
}

-- Add to Chronomancers
getBirthDescriptor("class","Chronomancer").descriptor_choices.subclass["Time Thief"] = "allow"