/obj/effect/proc_holder/spell/invoked/psydonlux_tamper
	name = "WEEP FOR THEM"
	overlay_state = "psydonweeps"
	releasedrain = 20
	chargedrain = 0
	chargetime = 0
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/psydonbleeds.ogg'
	invocation = "I BLEED, SO THAT YOU MIGHT ENDURE!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 1 MINUTES // 60 seconds cooldown
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/invoked/psydonlux_tamper/cast(list/targets, mob/living/user)
	if(!ishuman(targets[1]))
		to_chat(user, span_warning("I cannot merge my Lux with Luxless beings."))
		revert_cast()
		return FALSE
	
	var/mob/living/carbon/human/H = targets[1]
	
	if(H == user)
		to_chat(user, span_warning("I refuse to tamper with my own Lux."))
		revert_cast()
		return FALSE

	if(H.stat == DEAD)
		to_chat(user, span_warning("[H]'s Lux is gone. I can't do anything, anymore."))
		user.emote("cry")
		revert_cast()
		return FALSE	
	
	// Transfer wounds.
	if(ishuman(H) && ishuman(user))
		var/mob/living/carbon/human/C_target = H
		var/mob/living/carbon/human/C_caster = user
		var/list/datum/wound/tw_List = C_target.get_wounds()

		if(!tw_List.len)
			revert_cast()
			return FALSE

		//Transfer wounds from each bodypart.
		for(var/datum/wound/targetwound in tw_List)
			if (istype(targetwound, /datum/wound/dismemberment))
				continue				
			if (istype(targetwound, /datum/wound/facial))
				continue					
			if (istype(targetwound, /datum/wound/fracture/head))
				continue				
			if (istype(targetwound, /datum/wound/fracture/neck))
				continue
			if (istype(targetwound, /datum/wound/cbt/permanent))
				continue			
			var/obj/item/bodypart/c_BP = C_caster.get_bodypart(targetwound.bodypart_owner.body_zone)
			c_BP.add_wound(targetwound.type)
			var/obj/item/bodypart/t_BP = C_target.get_bodypart(targetwound.bodypart_owner.body_zone)
			t_BP.remove_wound(targetwound.type)


	// Visual effects
	user.visible_message(span_danger("[user] shoulders [H]'s wounds!"))
	playsound(get_turf(user), 'sound/magic/psydonbleeds.ogg', 50, TRUE)
	
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#487e97") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97") 
	new /obj/effect/temp_visual/psyheal_rogue(get_turf(user), "#487e97") 
	
	// Notify the user and target
	to_chat(user, span_warning("You feel awash with the merging of your Lux for a brief moment."))
	to_chat(H, span_info("You feel a strange stirring sensation pour over your Lux, stealing your wounds."))
	
	return TRUE

/obj/effect/proc_holder/spell/self/psydonrespite
	name = "RESPITE"
	desc = "Stand still to focus on mending your injuries."
	overlay_state = "RESPITE"
	releasedrain = 20
	chargedrain = 0
	chargetime = 0
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = null
	invocation = ". . ."
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 10 SECONDS // 60 seconds cooldown
	miracle = TRUE
	devotion_cost = 5

/obj/effect/proc_holder/spell/self/psydonrespite/cast(mob/living/user) // It's a very tame self-heal. Nothing too special.
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
		
	var/mob/living/carbon/human/H = user
	var/brute = H.getBruteLoss()
	var/burn = H.getFireLoss()
	var/conditional_buff = FALSE
	var/zcross_trigger = FALSE
	var/sit_bonus1 = 0
	var/sit_bonus2 = 0
	var/psicross_bonus = 0

	for(var/obj/item/clothing/neck/current_item in H.get_equipped_items(TRUE))
		if(current_item.type in list(/obj/item/clothing/neck/roguetown/zcross/aalloy, /obj/item/clothing/neck/roguetown/psicross, /obj/item/clothing/neck/roguetown/psicross/wood, /obj/item/clothing/neck/roguetown/psicross/aalloy, /obj/item/clothing/neck/roguetown/psicross/silver, /obj/item/clothing/neck/roguetown/psicross/g))
			switch(current_item.type) // Worn Psicross Piety bonus. For fun.
				if(/obj/item/clothing/neck/roguetown/psicross/wood)
					psicross_bonus = -2				
				if(/obj/item/clothing/neck/roguetown/psicross/aalloy)
					psicross_bonus = -4
				if(/obj/item/clothing/neck/roguetown/psicross)
					psicross_bonus = -5
				if(/obj/item/clothing/neck/roguetown/psicross/silver)
					psicross_bonus = -7
				if(/obj/item/clothing/neck/roguetown/psicross/g) // PURITY AFLOAT.
					psicross_bonus = -7
				if(/obj/item/clothing/neck/roguetown/zcross/aalloy)
					zcross_trigger = TRUE		
	if(brute > 100)
		sit_bonus1 = -2
	if(brute > 200)
		sit_bonus1 = -4	
	if(burn > 100)
		sit_bonus2 = -2			
	if(burn > 200)
		sit_bonus2 = -4					

	if(sit_bonus1 || sit_bonus2)				
		conditional_buff = TRUE

	var/bruthealval = -5 + psicross_bonus + sit_bonus1
	var/burnhealval = -5 + psicross_bonus + sit_bonus2

	to_chat(H, span_info("I take a moment to collect myself..."))
	if(zcross_trigger)
		user.visible_message(span_warning("[user] shuddered. Something's very wrong."), span_userdanger("Cold shoots through my spine. Something laughs at me for trying."))
		user.playsound_local(user, 'sound/misc/zizo.ogg', 25, FALSE)
		user.adjustBruteLoss(25)		
		return FALSE

	if(do_after(H, 50))
		playsound(H, 'sound/magic/psydonrespite.ogg', 100, TRUE)
		new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#e4e4e4") 
		new /obj/effect/temp_visual/psyheal_rogue(get_turf(H), "#e4e4e4") 
		H.adjustBruteLoss(bruthealval)
		H.adjustFireLoss(burnhealval)
		to_chat(H, span_info("In a moment of quiet contemplation, I feel bolstered by my faith."))
		if (conditional_buff)
			to_chat(user, span_info("My pain gives way to a sense of furthered clarity before returning again, dulled."))
		revert_cast()
		return TRUE
	else
		to_chat(H, span_warning("My thoughts and sense of quiet escape me."))
		
	return FALSE			
