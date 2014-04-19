--
-- Created by IntelliJ IDEA.
-- User: Sebsebeleb
-- Date: 02/02/14
-- Time: 03:12
-- To change this template use File | Settings | File Templates.
--

newBirthDescriptor{
   type = "subclass",
   name = "TimeThief",
   desc = {
      "Blah",
      "#LIGHT_BLUE# * +4 Strength, +0 Dexterity, +1 Constitution",
      "#LIGHT_BLUE# * +0 Magic, +4 Willpower, +0 Cunning",
      "#GOLD#Life per level:#LIGHT_BLUE# +1",
   },
   power_source = { arcane = true, technique = true },
   random_rarity = 3,
   not_on_random_boss = ("no" == config.settings.tome.nullpack_npc_classes),
   stats = { str=4, con=1, wil=4 },
   talents_types = {

      ["chronomancy/spacetime-weaving"]={true, 0.3},
      ["chronomancy/spacetime-folding"]={true, 0.3},
      ["chronomancy/temporal-combat"]={true, 0.3},
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
      [ActorTalents.T_BLESSING_OF_THE_PAST] = 1,
   },
   copy = {
      resolvers.equip{ id=true,
		       {type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
      },
   },
   copy_add = {
      life_rating = 1,
   },
}

-- Add to Chronomancers
getBirthDescriptor("class","Chronomancer").descriptor_choices.subclass["TimeThief"] = "allow"