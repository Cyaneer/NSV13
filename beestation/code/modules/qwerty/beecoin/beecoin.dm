/client/proc/get_beecoin_count()
	var/datum/DBQuery/query_get_beecoins = SSdbcore.NewQuery("SELECT beecoins FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	var/bc_count = 0
	if(query_get_beecoins.warn_execute())
		if(query_get_beecoins.NextRow())
			bc_count = query_get_beecoins.item[1]

	qdel(query_get_beecoins)
	return text2num(bc_count)

/client/proc/set_beecoin_count(bc_count, ann=TRUE)
	var/datum/DBQuery/query_set_beecoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET beecoins = '[bc_count]' WHERE ckey = '[ckey]'")
	query_set_beecoins.warn_execute()
	qdel(query_set_beecoins)
	if(ann)
		to_chat(src, "<span class='rose bold'>Your new beecoin balance is [bc_count]!</span>")

/client/proc/inc_beecoin_count(bc_count, ann=TRUE)
	var/datum/DBQuery/query_inc_beecoins = SSdbcore.NewQuery("UPDATE [format_table_name("player")] SET beecoins = beecoins + '[bc_count]' WHERE ckey = '[ckey]'")
	query_inc_beecoins.warn_execute()
	qdel(query_inc_beecoins)
	if(ann)
		if(bc_count >= 0)
			to_chat(src, "<span class='rose bold'>[bc_count] beecoins have been deposited to your account!</span>")
		else
			to_chat(src, "<span class='rose bold'>[abs(bc_count)] beecoins have been withdrawn from your account!</span>")







// PROCS FOR HANDLING CHECKING WHAT ITEMS USER HAS

/client
	var/list/beecoin_items = list()
	var/list/beecoin_items_sorted = list()

/client/proc/update_beecoin_items()
	beecoin_items = list()
	beecoin_items_sorted = list()

	var/datum/DBQuery/query_get_beecoin_purchases
	query_get_beecoin_purchases = SSdbcore.NewQuery("SELECT item_id,item_class FROM [format_table_name("beecoin_item_purchases")] WHERE ckey = '[ckey]'")

	if(!query_get_beecoin_purchases.warn_execute())
		return

	while (query_get_beecoin_purchases.NextRow())
		var/id = query_get_beecoin_purchases.item[1]
		var/class = query_get_beecoin_purchases.item[2]
		beecoin_items += id
		if (class)
			if (!(class in beecoin_items_sorted))
				beecoin_items_sorted[class] = list()
			beecoin_items_sorted[class] += id

	qdel(query_get_beecoin_purchases)

/client/proc/filter_unpurchased_items(list/L, class=null)
	var/list/purchased
	if (class)
		purchased = beecoin_items_sorted[class]
	else
		purchased = beecoin_items
	var/list/filtered = list()
	for (var/key in L)
		if (L[key].beecoin_locked && !(key in purchased))
			continue
		filtered[key] = L[key]
	return filtered

/proc/filter_beecoin_sprite_accessories(list/L)
	var/list/filtered = list()
	for (var/k in L)
		if (L[k].beecoin_locked)
			continue
		filtered[k] = L[k]
	return filtered
